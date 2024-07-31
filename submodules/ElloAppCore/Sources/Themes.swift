import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi

#if os(macOS)
let elloappThemeFormat = "macos"
let elloappThemeFileExtension = "palette"
#else
let elloappThemeFormat = "ios"
let elloappThemeFileExtension = "tgios-theme"
#endif

public func elloappThemes(postbox: Postbox, network: Network, accountManager: AccountManager<ElloAppAccountManagerTypes>?, forceUpdate: Bool = false) -> Signal<[ElloAppTheme], NoError> {
    let fetch: ([ElloAppTheme]?, Int64?) -> Signal<[ElloAppTheme], NoError> = { current, hash in
        network.request(Api.functions.account.getThemes(format: elloappThemeFormat, hash: hash ?? 0))
        |> retryRequest
        |> mapToSignal { result -> Signal<([ElloAppTheme], Int64), NoError> in
            switch result {
                case let .themes(hash, themes):
                    let result = themes.compactMap { ElloAppTheme(apiTheme: $0) }
                    if result == current {
                        return .complete()
                    } else {
                        return .single((result, hash))
                    }
                case .themesNotModified:
                    return .complete()
            }
        }
        |> mapToSignal { items, hash -> Signal<[ElloAppTheme], NoError> in
            if let accountManager = accountManager {
                let _ = accountManager.transaction { transaction in
                    transaction.updateSharedData(SharedDataKeys.themeSettings, { current in
                        var updated = current?.get(ThemeSettings.self) ?? ThemeSettings(currentTheme: nil)
                        for theme in items {
                            if theme.id == updated.currentTheme?.id {
                                updated = ThemeSettings(currentTheme: theme)
                                break
                            }
                        }
                        return PreferencesEntry(updated)
                    })
                }.start()
            }
            
            return postbox.transaction { transaction -> [ElloAppTheme] in
                var entries: [OrderedItemListEntry] = []
                for item in items {
                    var intValue = Int32(entries.count)
                    let id = MemoryBuffer(data: Data(bytes: &intValue, count: 4))
                    if let entry = CodableEntry(ElloAppThemeNativeCodable(item)) {
                        entries.append(OrderedItemListEntry(id: id, contents: entry))
                    }
                }
                transaction.replaceOrderedItemListItems(collectionId: Namespaces.OrderedItemList.CloudThemes, items: entries)
                if let entry = CodableEntry(CachedThemesConfiguration(hash: hash)) {
                    transaction.putItemCacheEntry(id: ItemCacheEntryId(collectionId: Namespaces.CachedItemCollection.cachedThemesConfiguration, key: ValueBoxKey(length: 0)), entry: entry)
                }
                return items
            }
        } |> then(
            postbox.combinedView(keys: [PostboxViewKey.orderedItemList(id: Namespaces.OrderedItemList.CloudThemes)])
            |> map { view -> [ElloAppTheme] in
                if let view = view.views[.orderedItemList(id: Namespaces.OrderedItemList.CloudThemes)] as? OrderedItemListView {
                    return view.items.compactMap { $0.contents.get(ElloAppThemeNativeCodable.self)?.value }
                } else {
                    return []
                }
            }
        )
    }
    
    if forceUpdate {
        return fetch(nil, nil)
    } else {
        return postbox.transaction { transaction -> ([ElloAppTheme], Int64?) in
            let configuration = transaction.retrieveItemCacheEntry(id: ItemCacheEntryId(collectionId: Namespaces.CachedItemCollection.cachedThemesConfiguration, key: ValueBoxKey(length: 0)))?.get(CachedThemesConfiguration.self)
            let items = transaction.getOrderedListItems(collectionId: Namespaces.OrderedItemList.CloudThemes)
            return (items.compactMap { $0.contents.get(ElloAppThemeNativeCodable.self)?.value }, configuration?.hash)
        }
        |> mapToSignal { current, hash -> Signal<[ElloAppTheme], NoError> in
            return .single(current)
            |> then(fetch(current, hash))
        }
    }
}

public enum GetThemeError {
    case generic
    case unsupported
    case slugInvalid
}

public func getTheme(account: Account, slug: String) -> Signal<ElloAppTheme, GetThemeError> {
    return account.network.request(Api.functions.account.getTheme(format: elloappThemeFormat, theme: .inputThemeSlug(slug: slug), documentId: 0))
    |> mapError { error -> GetThemeError in
        if error.errorDescription == "THEME_FORMAT_INVALID" {
            return .unsupported
        }
        if error.errorDescription == "THEME_SLUG_INVALID" {
            return .slugInvalid
        }
        return .generic
    }
    |> mapToSignal { theme -> Signal<ElloAppTheme, GetThemeError> in
        return .single(ElloAppTheme(apiTheme: theme))
    }
}

public enum ThemeUpdatedResult {
    case updated(ElloAppTheme)
    case notModified
}

private func checkThemeUpdated(network: Network, theme: ElloAppTheme) -> Signal<ThemeUpdatedResult, GetThemeError> {
    let id = theme.settings != nil ? 0 : theme.file?.id?.id
    guard let documentId = id else {
        return .fail(.generic)
    }
    return network.request(Api.functions.account.getTheme(format: elloappThemeFormat, theme: .inputTheme(id: theme.id, accessHash: theme.accessHash), documentId: documentId))
    |> mapError { _ -> GetThemeError in return .generic }
    |> map { theme -> ThemeUpdatedResult in
        return .updated(ElloAppTheme(apiTheme: theme))
    }
}

private func saveUnsaveTheme(account: Account, accountManager: AccountManager<ElloAppAccountManagerTypes>, theme: ElloAppTheme, unsave: Bool) -> Signal<Void, NoError> {
    return account.postbox.transaction { transaction -> Signal<Void, NoError> in
        let entries = transaction.getOrderedListItems(collectionId: Namespaces.OrderedItemList.CloudThemes)
        var items = entries.compactMap { $0.contents.get(ElloAppThemeNativeCodable.self)?.value }
        items = items.filter { $0.id != theme.id }
        if !unsave {
            items.insert(theme, at: 0)
        }
        var updatedEntries: [OrderedItemListEntry] = []
        for item in items {
            var intValue = Int32(updatedEntries.count)
            let id = MemoryBuffer(data: Data(bytes: &intValue, count: 4))
            if let entry = CodableEntry(ElloAppThemeNativeCodable(item)) {
                updatedEntries.append(OrderedItemListEntry(id: id, contents: entry))
            }
        }
        transaction.replaceOrderedItemListItems(collectionId: Namespaces.OrderedItemList.CloudThemes, items: updatedEntries)
        
        return account.network.request(Api.functions.account.saveTheme(theme: Api.InputTheme.inputTheme(id: theme.id, accessHash: theme.accessHash), unsave: unsave ? Api.Bool.boolTrue : Api.Bool.boolFalse))
        |> `catch` { _ -> Signal<Api.Bool, NoError> in
            return .complete()
        }
        |> mapToSignal { _ -> Signal<Void, NoError> in
            return elloappThemes(postbox: account.postbox, network: account.network, accountManager: accountManager, forceUpdate: true)
            |> take(1)
            |> mapToSignal { _ -> Signal<Void, NoError> in
                return .complete()
            }
        }
    } |> switchToLatest
}

private func installTheme(account: Account, theme: ElloAppTheme?, baseTheme: ElloAppBaseTheme? = nil, autoNight: Bool) -> Signal<Never, NoError> {
    var flags: Int32 = 0
    if autoNight {
        flags |= 1 << 0
    }
    
    let inputTheme: Api.InputTheme?
    if let theme = theme {
        inputTheme = .inputTheme(id: theme.id, accessHash: theme.accessHash)
        flags |= 1 << 1
    } else {
        inputTheme = nil
    }
    
    flags |= 1 << 2
    
    let inputBaseTheme: Api.BaseTheme?
    if let baseTheme = baseTheme {
        inputBaseTheme = baseTheme.apiBaseTheme
    } else {
        inputBaseTheme = nil
    }
    
    return account.network.request(Api.functions.account.installTheme(flags: flags, theme: inputTheme, format: elloappThemeFormat, baseTheme: inputBaseTheme))
    |> `catch` { _ -> Signal<Api.Bool, NoError> in
        return .complete()
    }
    |> mapToSignal { _ -> Signal<Never, NoError> in
        return .complete()
    }
}

public enum UploadThemeResult {
    case progress(Float)
    case complete(ElloAppMediaFile)
}

public enum UploadThemeError {
    case generic
}

private struct UploadedThemeData {
    fileprivate let content: UploadedThemeDataContent
}

private enum UploadedThemeDataContent {
    case result(MultipartUploadResult)
    case error
}

private func uploadedTheme(postbox: Postbox, network: Network, resource: MediaResource) -> Signal<UploadedThemeData, NoError> {
    return multipartUpload(network: network, postbox: postbox, source: .resource(.standalone(resource: resource)), encrypt: false, tag: ElloAppMediaResourceFetchTag(statsCategory: .file), hintFileSize: nil, hintFileIsLarge: false, forceNoBigParts: false)
    |> map { result -> UploadedThemeData in
        return UploadedThemeData(content: .result(result))
    }
    |> `catch` { _ -> Signal<UploadedThemeData, NoError> in
        return .single(UploadedThemeData(content: .error))
    }
}

private func uploadedThemeThumbnail(postbox: Postbox, network: Network, data: Data) -> Signal<UploadedThemeData, NoError> {
    return multipartUpload(network: network, postbox: postbox, source: .data(data), encrypt: false, tag: ElloAppMediaResourceFetchTag(statsCategory: .image), hintFileSize: nil, hintFileIsLarge: false, forceNoBigParts: false)
    |> map { result -> UploadedThemeData in
        return UploadedThemeData(content: .result(result))
    }
    |> `catch` { _ -> Signal<UploadedThemeData, NoError> in
        return .single(UploadedThemeData(content: .error))
    }
}

private func uploadTheme(account: Account, resource: MediaResource, thumbnailData: Data? = nil) -> Signal<UploadThemeResult, UploadThemeError> {
    let fileName = "theme.\(elloappThemeFileExtension)"
    let mimeType = "application/x-tgtheme-\(elloappThemeFormat)"
    
    let uploadedThumbnail: Signal<UploadedThemeData?, UploadThemeError>
    if let thumbnailData = thumbnailData {
        uploadedThumbnail = uploadedThemeThumbnail(postbox: account.postbox, network: account.network, data: thumbnailData)
        |> mapError { _ -> UploadThemeError in }
        |> map(Optional.init)
    } else {
        uploadedThumbnail = .single(nil)
    }
    
    return uploadedThumbnail
    |> mapToSignal { thumbnailResult -> Signal<UploadThemeResult, UploadThemeError> in
        return uploadedTheme(postbox: account.postbox, network: account.network, resource: resource)
        |> mapError { _ -> UploadThemeError in }
        |> mapToSignal { result -> Signal<UploadThemeResult, UploadThemeError> in
            switch result.content {
                case .error:
                    return .fail(.generic)
                case let .result(resultData):
                    switch resultData {
                        case let .progress(progress):
                            return .single(.progress(progress))
                        case let .inputFile(file):
                            var flags: Int32 = 0
                            var thumbnailFile: Api.InputFile?
                            if let thumbnailResult = thumbnailResult?.content, case let .result(result) = thumbnailResult, case let .inputFile(file) = result {
                                thumbnailFile = file
                                flags |= 1 << 0
                            }
                            return account.network.request(Api.functions.account.uploadTheme(flags: flags, file: file, thumb: thumbnailFile, fileName: fileName, mimeType: mimeType))
                            |> mapError { _ in return UploadThemeError.generic }
                            |> mapToSignal { document -> Signal<UploadThemeResult, UploadThemeError> in
                                if let file = elloappMediaFileFromApiDocument(document) {
                                    return .single(.complete(file))
                                } else {
                                    return .fail(.generic)
                                }
                            }
                        default:
                            return .fail(.generic)
                    }
            }
        }
    }
}

public enum CreateThemeError {
    case generic
    case slugInvalid
    case slugOccupied
}

public enum CreateThemeResult {
    case result(ElloAppTheme)
    case progress(Float)
}

public func createTheme(account: Account, title: String, resource: MediaResource? = nil, thumbnailData: Data? = nil, settings: [ElloAppThemeSettings]?) -> Signal<CreateThemeResult, CreateThemeError> {
    var flags: Int32 = 0
    
    var inputSettings: [Api.InputThemeSettings]?
    if let _ = resource {
        flags |= 1 << 2
    }
    if let settings = settings {
        flags |= 1 << 3
        inputSettings = settings.map { $0.apiInputThemeSettings }
    }
    
    if let resource = resource {
        return uploadTheme(account: account, resource: resource, thumbnailData: thumbnailData)
        |> mapError { _ in return CreateThemeError.generic }
        |> mapToSignal { result -> Signal<CreateThemeResult, CreateThemeError> in
            switch result {
                case let .complete(file):
                    if let resource = file.resource as? CloudDocumentMediaResource {
                        return account.network.request(Api.functions.account.createTheme(flags: flags, slug: "", title: title, document: .inputDocument(id: resource.fileId, accessHash: resource.accessHash, fileReference: Buffer(data: resource.fileReference)), settings: inputSettings))
                        |> mapError { error in
                            if error.errorDescription == "THEME_SLUG_INVALID" {
                                return .slugInvalid
                            } else if error.errorDescription == "THEME_SLUG_OCCUPIED" {
                                return .slugOccupied
                            }
                            return .generic
                        }
                        |> mapToSignal { apiTheme -> Signal<CreateThemeResult, CreateThemeError> in
                            let theme = ElloAppTheme(apiTheme: apiTheme)
                            return account.postbox.transaction { transaction -> CreateThemeResult in
                                let entries = transaction.getOrderedListItems(collectionId: Namespaces.OrderedItemList.CloudThemes)
                                var items = entries.compactMap { $0.contents.get(ElloAppThemeNativeCodable.self)?.value }
                                items.insert(theme, at: 0)
                                var updatedEntries: [OrderedItemListEntry] = []
                                for item in items {
                                    var intValue = Int32(updatedEntries.count)
                                    let id = MemoryBuffer(data: Data(bytes: &intValue, count: 4))
                                    if let entry = CodableEntry(ElloAppThemeNativeCodable(item)) {
                                        updatedEntries.append(OrderedItemListEntry(id: id, contents: entry))
                                    }
                                }
                                transaction.replaceOrderedItemListItems(collectionId: Namespaces.OrderedItemList.CloudThemes, items: updatedEntries)
                                return .result(theme)
                            }
                            |> castError(CreateThemeError.self)
                        }
                    }
                    else {
                        return .fail(.generic)
                    }
                case let .progress(progress):
                    return .single(.progress(progress))
            }
        }
    } else {
        return account.network.request(Api.functions.account.createTheme(flags: flags, slug: "", title: title, document: .inputDocumentEmpty, settings: inputSettings))
            |> mapError { error in
                if error.errorDescription == "THEME_SLUG_INVALID" {
                    return .slugInvalid
                } else if error.errorDescription == "THEME_SLUG_OCCUPIED" {
                    return .slugOccupied
                }
                return .generic
            }
            |> mapToSignal { apiTheme -> Signal<CreateThemeResult, CreateThemeError> in
                var theme = ElloAppTheme(apiTheme: apiTheme)
                theme = ElloAppTheme(id: theme.id, accessHash: theme.accessHash, slug: theme.slug, emoticon: nil, title: theme.title, file: theme.file, settings: settings, isCreator: theme.isCreator, isDefault: theme.isDefault, installCount: theme.installCount)

                return account.postbox.transaction { transaction -> CreateThemeResult in
                    let entries = transaction.getOrderedListItems(collectionId: Namespaces.OrderedItemList.CloudThemes)
                    var items = entries.compactMap { $0.contents.get(ElloAppThemeNativeCodable.self)?.value }
                    items.insert(theme, at: 0)
                    var updatedEntries: [OrderedItemListEntry] = []
                    for item in items {
                        var intValue = Int32(updatedEntries.count)
                        let id = MemoryBuffer(data: Data(bytes: &intValue, count: 4))
                        if let entry = CodableEntry(ElloAppThemeNativeCodable(item)) {
                            updatedEntries.append(OrderedItemListEntry(id: id, contents: entry))
                        }
                    }
                    transaction.replaceOrderedItemListItems(collectionId: Namespaces.OrderedItemList.CloudThemes, items: updatedEntries)
                    return .result(theme)
                }
                |> castError(CreateThemeError.self)
        }
    }
}

public func updateTheme(account: Account, accountManager: AccountManager<ElloAppAccountManagerTypes>, theme: ElloAppTheme, title: String?, slug: String?, resource: MediaResource?, thumbnailData: Data? = nil, settings: [ElloAppThemeSettings]?) -> Signal<CreateThemeResult, CreateThemeError> {
    guard title != nil || slug != nil || resource != nil else {
        return .complete()
    }
    var flags: Int32 = 0
    if let slug = slug, !slug.isEmpty {
        flags |= 1 << 0
    }
    if let _ = title {
        flags |= 1 << 1
    }
    if let _ = resource {
        flags |= 1 << 2
    }
    var inputSettings: [Api.InputThemeSettings]?
    if let settings = settings {
        flags |= 1 << 3
        inputSettings = settings.map { $0.apiInputThemeSettings }
    }
    let uploadSignal: Signal<UploadThemeResult?, UploadThemeError>
    if let resource = resource {
        uploadSignal = uploadTheme(account: account, resource: resource, thumbnailData: thumbnailData)
        |> map(Optional.init)
    } else {
        uploadSignal = .single(nil)
    }
    return uploadSignal
    |> mapError { _ -> CreateThemeError in
        return .generic
    }
    |> mapToSignal { result -> Signal<CreateThemeResult, CreateThemeError> in
        let inputDocument: Api.InputDocument?
        if let status = result {
            switch status {
                case let .complete(file):
                    if let resource = file.resource as? CloudDocumentMediaResource {
                        inputDocument = .inputDocument(id: resource.fileId, accessHash: resource.accessHash, fileReference: Buffer(data: resource.fileReference))
                    } else {
                        return .fail(.generic)
                    }
                case let .progress(progress):
                    return .single(.progress(progress))
            }
        } else {
            inputDocument = nil
        }
        
        return account.network.request(Api.functions.account.updateTheme(flags: flags, format: elloappThemeFormat, theme: .inputTheme(id: theme.id, accessHash: theme.accessHash), slug: slug, title: title, document: inputDocument, settings: inputSettings))
        |> mapError { error in
            if error.errorDescription == "THEME_SLUG_INVALID" {
                return .slugInvalid
            } else if error.errorDescription == "THEME_SLUG_OCCUPIED" {
                return .slugOccupied
            }
            return .generic
        }
        |> mapToSignal { apiTheme -> Signal<CreateThemeResult, CreateThemeError> in
            let theme = ElloAppTheme(apiTheme: apiTheme)
            let updatedTheme = ElloAppTheme(id: theme.id, accessHash: theme.accessHash, slug: theme.slug, emoticon: nil, title: theme.title, file: theme.file, settings: settings, isCreator: theme.isCreator, isDefault: theme.isDefault, installCount: theme.installCount)

            let _ = accountManager.transaction { transaction in
                transaction.updateSharedData(SharedDataKeys.themeSettings, { current in
                    var updated = current?.get(ThemeSettings.self) ?? ThemeSettings(currentTheme: nil)
                    if updatedTheme.id == updated.currentTheme?.id {
                        updated = ThemeSettings(currentTheme: updatedTheme)
                    }
                    return PreferencesEntry(updated)
                })
            }.start()
            return account.postbox.transaction { transaction -> CreateThemeResult in
                let entries = transaction.getOrderedListItems(collectionId: Namespaces.OrderedItemList.CloudThemes)
                let items = entries.map { entry -> ElloAppTheme in
                    let theme = entry.contents.get(ElloAppThemeNativeCodable.self)!.value
                    if theme.id == updatedTheme.id {
                        return updatedTheme
                    } else {
                        return theme
                    }
                }
                var updatedEntries: [OrderedItemListEntry] = []
                for item in items {
                    var intValue = Int32(updatedEntries.count)
                    let id = MemoryBuffer(data: Data(bytes: &intValue, count: 4))
                    if let entry = CodableEntry(ElloAppThemeNativeCodable(item)) {
                        updatedEntries.append(OrderedItemListEntry(id: id, contents: entry))
                    }
                }
                transaction.replaceOrderedItemListItems(collectionId: Namespaces.OrderedItemList.CloudThemes, items: updatedEntries)
                return .result(updatedTheme)
            }
            |> castError(CreateThemeError.self)
        }
    }
}

public func saveThemeInteractively(account: Account, accountManager: AccountManager<ElloAppAccountManagerTypes>, theme: ElloAppTheme) -> Signal<Void, NoError> {
    return saveUnsaveTheme(account: account, accountManager: accountManager, theme: theme, unsave: false)
}

public func deleteThemeInteractively(account: Account, accountManager: AccountManager<ElloAppAccountManagerTypes>, theme: ElloAppTheme) -> Signal<Void, NoError> {
    return saveUnsaveTheme(account: account, accountManager: accountManager, theme: theme, unsave: true)
}

public func applyTheme(accountManager: AccountManager<ElloAppAccountManagerTypes>, account: Account, theme: ElloAppTheme?, autoNight: Bool = false) -> Signal<Never, NoError> {
    return accountManager.transaction { transaction -> Signal<Never, NoError> in
        transaction.updateSharedData(SharedDataKeys.themeSettings, { _ in
            return PreferencesEntry(ThemeSettings(currentTheme: theme))
        })
        
        if let theme = theme {
            return installTheme(account: account, theme: theme, autoNight: autoNight)
        } else {
            return .complete()
        }
    }
    |> switchToLatest
}

func managedThemesUpdates(accountManager: AccountManager<ElloAppAccountManagerTypes>, postbox: Postbox, network: Network) -> Signal<Void, NoError> {
    let currentTheme = Atomic<ElloAppTheme?>(value: nil)
    return accountManager.sharedData(keys: [SharedDataKeys.themeSettings])
    |> map { sharedData -> ElloAppTheme? in
        let themeSettings = sharedData.entries[SharedDataKeys.themeSettings]?.get(ThemeSettings.self) ?? ThemeSettings(currentTheme: nil)
        return themeSettings.currentTheme
    }
    |> filter { theme in
        return theme?.id != currentTheme.with({ $0 })?.id
    }
    |> mapToSignal { theme -> Signal<Void, NoError> in
        let _ = currentTheme.swap(theme)
        if let theme = theme {
            let poll = Signal<Void, NoError> { subscriber in
                let actualTheme = currentTheme.with { $0 } ?? theme
                return checkThemeUpdated(network: network, theme: actualTheme).start(next: { result in
                    if case let .updated(updatedTheme) = result {
                        let _ = currentTheme.swap(theme)
                        let _ = accountManager.transaction { transaction in
                            transaction.updateSharedData(SharedDataKeys.themeSettings, { _ in
                                return PreferencesEntry(ThemeSettings(currentTheme: updatedTheme))
                            })
                        }.start()
                        let _ = postbox.transaction { transaction in
                            let entries = transaction.getOrderedListItems(collectionId: Namespaces.OrderedItemList.CloudThemes)
                            
                            var success = true
                            var mappedItems: [ElloAppTheme] = []
                            for entry in entries {
                                if let theme = entry.contents.get(ElloAppThemeNativeCodable.self)?.value {
                                    if theme.id == updatedTheme.id {
                                        mappedItems.append(updatedTheme)
                                    } else {
                                        mappedItems.append(theme)
                                    }
                                } else {
                                    success = false
                                    break
                                }
                            }
                            if success {
                                var updatedEntries: [OrderedItemListEntry] = []
                                for item in mappedItems {
                                    var intValue = Int32(updatedEntries.count)
                                    let id = MemoryBuffer(data: Data(bytes: &intValue, count: 4))
                                    if let entry = CodableEntry(ElloAppThemeNativeCodable(item)) {
                                        updatedEntries.append(OrderedItemListEntry(id: id, contents: entry))
                                    }
                                }
                                transaction.replaceOrderedItemListItems(collectionId: Namespaces.OrderedItemList.CloudThemes, items: updatedEntries)
                            } else {
                                let _ = (elloappThemes(postbox: postbox, network: network, accountManager: accountManager, forceUpdate: true)
                                |> take(1)).start()
                            }
                        }.start()
                    }
                    subscriber.putCompletion()
                })
            }
            return (poll |> then(.complete() |> suspendAwareDelay(1.0 * 60.0 * 60.0, queue: Queue.concurrentDefaultQueue()))) |> restart
        } else {
            return .complete()
        }
    }
}

private func areThemesEqual(_ lhs: ElloAppTheme, _ rhs: ElloAppTheme) -> Bool {
    if lhs.title != rhs.title {
        return false
    }
    if lhs.slug != rhs.slug {
        return false
    }
    if lhs.file?.id != rhs.file?.id {
        return false
    }
    if lhs.settings != rhs.settings {
        return false
    }
    return true
}

public func actualizedTheme(account: Account, accountManager: AccountManager<ElloAppAccountManagerTypes>, theme: ElloAppTheme) -> Signal<ElloAppTheme, NoError> {
    var currentTheme = theme
    return accountManager.sharedData(keys: [SharedDataKeys.themeSettings])
    |> mapToSignal { sharedData -> Signal<ElloAppTheme, NoError> in
        let themeSettings = sharedData.entries[SharedDataKeys.themeSettings]?.get(ThemeSettings.self) ?? ThemeSettings(currentTheme: nil)
        if let updatedTheme = themeSettings.currentTheme, updatedTheme.id == theme.id {
            if !areThemesEqual(updatedTheme, currentTheme) {
                currentTheme = updatedTheme
                return .single(updatedTheme)
            } else {
                return .single(currentTheme)
            }
        } else {
            return account.postbox.combinedView(keys: [PostboxViewKey.orderedItemList(id: Namespaces.OrderedItemList.CloudThemes)])
            |> map { view -> [ElloAppTheme] in
                if let view = view.views[.orderedItemList(id: Namespaces.OrderedItemList.CloudThemes)] as? OrderedItemListView {
                    return view.items.compactMap { $0.contents.get(ElloAppThemeNativeCodable.self)?.value }
                } else {
                    return []
                }
            }
            |> map { themes -> ElloAppTheme in
                let updatedTheme = themes.first(where: { $0.id == theme.id })
                if let updatedTheme = updatedTheme {
                    if !areThemesEqual(updatedTheme, currentTheme) {
                        currentTheme = updatedTheme
                        return updatedTheme
                    } else {
                        return currentTheme
                    }
                } else {
                    return currentTheme
                }
            }
        }
    }
}
