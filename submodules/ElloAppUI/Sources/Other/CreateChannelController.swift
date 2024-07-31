import Foundation
import UIKit
import Display
import SwiftSignalKit
import Postbox
import ElloAppCore
import ElloAppPresentationData
import LegacyComponents
import ItemListUI
import PresentationDataUtils
import AccountContext
import AlertUI
import PresentationDataUtils
import LegacyUI
import ItemListAvatarAndNameInfoItem
import WebSearchUI
import PeerInfoUI
import MapResourceToAvatarSizes
import LegacyMediaPickerUI
import ContextUI
import ELBase
import AppBundle

private struct CreateChannelArguments {
    let context: AccountContext
    
    let updateEditingName: (ItemListAvatarAndNameInfoItemName) -> Void
    let updateEditingDescriptionText: (String) -> Void
    let done: () -> Void
    let changeProfilePhoto: () -> Void
    let focusOnDescription: () -> Void
    let updateCurrentAgehood: (CurrentAgehood) -> Void
    let tapAgePolicy: () -> Void
    let updateCategory: () -> Void
    let updateGenre: () -> Void
    let updateSubgenre: () -> Void
    let updateCountry: () -> Void
}

private enum CreateChannelSection: Int32 {
    case info
    case description
    case agehood
    case policy
    case category
    case country
}

private enum CreateChannelEntryTag: ItemListItemTag {
    case info
    case description
    case category
    case genre
    case subgenre
    case country
    
    func isEqual(to other: ItemListItemTag) -> Bool {
        guard let other = other as? CreateChannelEntryTag else {
            return false
        }
        
        return other == self
    }
}

private enum CreateChannelEntry: ItemListNodeEntry {
    case channelInfo(PresentationTheme, PresentationStrings, PresentationDateTimeFormat, Peer?, ItemListAvatarAndNameInfoItemState, ItemListAvatarAndNameInfoItemUpdatingAvatar?)
    case setProfilePhoto(PresentationTheme, String)
    
    case descriptionHeader(String)
    case descriptionSetup(PresentationTheme, String, String)
    case descriptionFooter(PresentationTheme, String)
    
    case adulthood(PresentationTheme, String, selected: Bool)
    case childhood(PresentationTheme, String, selected: Bool)
    case agehoodFooterTitle(PresentationTheme, String)
    
    case policyInfo(PresentationTheme, String)
    
    case categoryHeaderTitle(PresentationTheme, String)
    case categoryItem(PresentationTheme, String)
    
    case genreHeaderTitle(PresentationTheme, String)
    case genreItem(PresentationTheme, String)
    
    case subgenreHeaderTitle(PresentationTheme, String)
    case subgenreItem(PresentationTheme, String)
    
    case countryHeaderTitle(PresentationTheme, String)
    case countyItem(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
        case .channelInfo, .setProfilePhoto:
            return CreateChannelSection.info.rawValue
        case .descriptionFooter, .descriptionSetup, .descriptionHeader:
            return CreateChannelSection.description.rawValue
        case .childhood, .adulthood, .agehoodFooterTitle:
            return CreateChannelSection.agehood.rawValue
        case .policyInfo:
            return CreateChannelSection.policy.rawValue
        case .categoryHeaderTitle, .categoryItem: fallthrough
        case .genreHeaderTitle, .genreItem: fallthrough
        case .subgenreHeaderTitle, .subgenreItem: fallthrough
        case .countryHeaderTitle, .countyItem:
            return CreateChannelSection.category.rawValue
//        case .countryHeaderTitle, .countyItem:
//            return CreateChannelSection.country.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .channelInfo: 0
        case .setProfilePhoto: 1
        case .descriptionHeader: 2
        case .descriptionSetup: 3
        case .descriptionFooter: 4
        case .adulthood: 5
        case .childhood: 6
        case .agehoodFooterTitle: 7
        case .policyInfo: 8
        case .categoryHeaderTitle: 9
        case .categoryItem: 10
        case .genreHeaderTitle: 11
        case .genreItem: 12
        case .subgenreHeaderTitle: 13
        case .subgenreItem: 14
        case .countryHeaderTitle: 15
        case .countyItem: 16
        }
    }
    
    static func ==(lhs: CreateChannelEntry, rhs: CreateChannelEntry) -> Bool {
        switch lhs {
        case let .channelInfo(lhsTheme, lhsStrings, lhsDateTimeFormat, lhsPeer, lhsEditingState, lhsAvatar):
            if case let .channelInfo(rhsTheme, rhsStrings, rhsDateTimeFormat, rhsPeer, rhsEditingState, rhsAvatar) = rhs {
                if lhsTheme !== rhsTheme {
                    return false
                }
                if lhsStrings !== rhsStrings {
                    return false
                }
                if lhsDateTimeFormat != rhsDateTimeFormat {
                    return false
                }
                if let lhsPeer = lhsPeer, let rhsPeer = rhsPeer {
                    if !lhsPeer.isEqual(rhsPeer) {
                        return false
                    }
                } else if (lhsPeer != nil) != (rhsPeer != nil) {
                    return false
                }
                if lhsEditingState != rhsEditingState {
                    return false
                }
                if lhsAvatar != rhsAvatar {
                    return false
                }
                return true
            } else {
                return false
            }
        case let .setProfilePhoto(lhsTheme, lhsText):
            if case let .setProfilePhoto(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .descriptionHeader(lhsText):
            if case let .descriptionHeader(rhsText) = rhs, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .descriptionSetup(lhsTheme, lhsText, lhsValue):
            if case let .descriptionSetup(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .descriptionFooter(lhsTheme, lhsText):
            if case let .descriptionFooter(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .adulthood(lhsTheme, lhsText, lhsSelected):
            if case let .adulthood(rhsTheme, rhsText, rhsSelected) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsSelected == rhsSelected {
                return true
            } else {
                return false
            }
        case let .childhood(lhsTheme, lhsText, lhsSelected):
            if case let .childhood(rhsTheme, rhsText, rhsSelected) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsSelected == rhsSelected {
                return true
            } else {
                return false
            }
        case let .agehoodFooterTitle(lhsTheme, lhsText):
            if case let .agehoodFooterTitle(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .policyInfo(lhsTheme, lhsText):
            if case let .policyInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .categoryHeaderTitle(lhsTheme, lhsText):
            if case let .categoryHeaderTitle(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .categoryItem(lhsTheme, lhsText):
            if case let .categoryItem(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .genreHeaderTitle(lhsTheme, lhsText):
            if case let .genreHeaderTitle(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .genreItem(lhsTheme, lhsText):
            if case let .genreItem(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .subgenreHeaderTitle(lhsTheme, lhsText):
            if case let .subgenreHeaderTitle(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .subgenreItem(lhsTheme, lhsText):
            if case let .subgenreItem(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .countryHeaderTitle(lhsTheme, lhsText):
            if case let .countryHeaderTitle(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .countyItem(lhsTheme, lhsText):
            if case let .countyItem(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        }
    }
    
    static func <(lhs: CreateChannelEntry, rhs: CreateChannelEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! CreateChannelArguments
        switch self {
        case let .channelInfo(_, _, dateTimeFormat, peer, state, avatar):
            return ItemListAvatarAndNameInfoItem(
                accountContext: arguments.context,
                presentationData: presentationData,
                dateTimeFormat: dateTimeFormat,
                mode: .editSettings,
                peer: peer.flatMap(EnginePeer.init),
                presence: nil,
                memberCount: nil,
                state: state,
                sectionId: ItemListSectionId(self.section),
                style: .blocks(withTopInset: false, withExtendedBottomInset: false),
                editingNameUpdated: { editingName in
                    arguments.updateEditingName(editingName)
                }, editingNameCompleted: {
                    arguments.focusOnDescription()
                }, avatarTapped: {
                    arguments.changeProfilePhoto()
                }, 
                updatingImage: avatar, 
                tag: CreateChannelEntryTag.info)
        case let .setProfilePhoto(_, text):
            return ItemListActionItem(presentationData: presentationData, title: text, kind: .generic, alignment: .natural, sectionId: ItemListSectionId(self.section), style: .blocks, action: {
                arguments.changeProfilePhoto()
            })
        case let .descriptionHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, accessoryText: ItemListSectionHeaderAccessoryText(value: "255", color: .generic, icon: nil), sectionId: self.section)
        case let .descriptionSetup(_, placeholder, text):
            return ItemListMultilineInputItem(
                presentationData: presentationData,
                text: text,
                placeholder: placeholder,
                maxLength: ItemListMultilineInputItemTextLimit(value: 255, display: true),
                sectionId: self.section,
                style: .blocks,
                textUpdated: { updatedText in
                    arguments.updateEditingDescriptionText(updatedText)
                },
                shouldUpdateText: { $0.count <= 255 },
                tag: CreateChannelEntryTag.description
            )
        case let .descriptionFooter(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .adulthood(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, multilineTitle: true, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: section) {
                arguments.updateCurrentAgehood(.adulthood)
            }
        case let .childhood(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, multilineTitle: true, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: section) {
                arguments.updateCurrentAgehood(.childhood)
            }
        case let .agehoodFooterTitle(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: section)
        case let .policyInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .markdownWithParams(text: text, weight: .regular, linkWeight: .semibold, size: 14), sectionId: section) { _ in
                arguments.tapAgePolicy()
            }
        case let .categoryHeaderTitle(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: true, sectionId: self.section)
        case let .categoryItem(_, text):
            return ItemListDisclosureItem(presentationData: presentationData, title: text, label: "", sectionId: section, style: .blocks, disclosureStyle: .arrowDown, action: {
                arguments.updateCategory()
            }, tag: CreateChannelEntryTag.category)
        case let .genreHeaderTitle(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: true, sectionId: self.section)
        case let .genreItem(_, text):
            return ItemListDisclosureItem(presentationData: presentationData, title: text, label: "", sectionId: section, style: .blocks, disclosureStyle: .arrowDown, action: {
                arguments.updateGenre()
            }, tag: CreateChannelEntryTag.genre)
        case let .subgenreHeaderTitle(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: true, sectionId: self.section)
        case let .subgenreItem(_, text):
            return ItemListDisclosureItem(presentationData: presentationData, title: text, label: "", sectionId: section, style: .blocks, disclosureStyle: .arrowDown, action: {
                arguments.updateSubgenre()
            }, tag: CreateChannelEntryTag.subgenre)
        case let .countryHeaderTitle(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: true, sectionId: self.section)
        case let .countyItem(_, text):
            return ItemListDisclosureItem(presentationData: presentationData, title: text, label: "", sectionId: section, style: .blocks, disclosureStyle: .arrowDown, action: {
                arguments.updateCountry()
            }, tag: CreateChannelEntryTag.country)
        }
    }
}

private enum CurrentAgehood {
    case adulthood
    case childhood
}

private struct CreateChannelState: Equatable {
    let musicCategory = "Music"
    
    var creating: Bool
    var editingName: ItemListAvatarAndNameInfoItemName
    var editingDescriptionText: String
    var avatar: ItemListAvatarAndNameInfoItemUpdatingAvatar?
    var selectedAgehood: CurrentAgehood
    var editingCategory: String
    var editingGenre: String
    var editingSubgenre: String
    var editingCountry: String
    var isPrivate: Bool
    
    static func ==(lhs: CreateChannelState, rhs: CreateChannelState) -> Bool {
        if lhs.creating != rhs.creating {
            return false
        }
        if lhs.editingName != rhs.editingName {
            return false
        }
        if lhs.editingDescriptionText != rhs.editingDescriptionText {
            return false
        }
        if lhs.avatar != rhs.avatar {
            return false
        }
        if lhs.selectedAgehood != rhs.selectedAgehood {
            return false
        }
        if lhs.editingCategory != rhs.editingCategory {
            return false
        }
        if lhs.editingGenre != rhs.editingGenre {
            return false
        }
        if lhs.editingSubgenre != rhs.editingSubgenre {
            return false
        }
        if lhs.editingCountry != rhs.editingCountry {
            return false
        }
        if lhs.isPrivate != rhs.isPrivate {
            return false
        }
        return true
    }
}

private func createChannelEntries(presentationData: PresentationData, state: CreateChannelState, payType: ElloAppChannelPayType) -> [CreateChannelEntry] {
    var entries: [CreateChannelEntry] = []
    
    let groupInfoState = ItemListAvatarAndNameInfoItemState(editingName: state.editingName, updatingName: nil)
    
    // TODO: Check is need description
    let peer = ElloAppGroup(id: PeerId(namespace: .max, id: PeerId.Id._internalFromInt64Value(0)), title: state.editingName.composedTitle, userName: nil, description: nil, photo: [], participantCount: 0, role: .creator(rank: nil), membership: .Member, flags: [], defaultBannedRights: nil, migrationReference: nil, creationDate: 0, version: 0)
    
    entries.append(.channelInfo(presentationData.theme, presentationData.strings, presentationData.dateTimeFormat, peer, groupInfoState, state.avatar))
    
    entries.append(.descriptionHeader(presentationData.strings.Channel_About_Title.uppercased()))
    entries.append(.descriptionSetup(presentationData.theme, presentationData.strings.Channel_Edit_AboutItem, state.editingDescriptionText))
//    entries.append(.descriptionInfo(presentationData.theme, presentationData.strings.Channel_About_Help))
    
    entries.append(
        .descriptionFooter(
            presentationData.theme,
            payType == .onlineCourse ? presentationData.strings.CreateOnlineCourse_AgeHood_Header : presentationData.strings.CreateChannel_AgeHood_Header
        )
    )
    entries.append(.adulthood(presentationData.theme, presentationData.strings.CreateChannel_AgeHood_Adult, selected: state.selectedAgehood == .adulthood))
    entries.append(.childhood(presentationData.theme, presentationData.strings.CreateChannel_AgeHood_Child, selected: state.selectedAgehood == .childhood))
    if state.isPrivate {
        entries.append(.agehoodFooterTitle(presentationData.theme, presentationData.strings.CreateChannel_AgeHood_Footer))
    }
    
    entries.append(.policyInfo(presentationData.theme, presentationData.strings.CreateChannel_AgePolicy))
    
    entries.append(.categoryHeaderTitle(presentationData.theme, presentationData.strings.CreateChannel_Category_Header.uppercased()))
    entries.append(.categoryItem(presentationData.theme, state.editingCategory))
    
    if state.editingCategory == state.musicCategory {
        entries.append(.genreHeaderTitle(presentationData.theme, presentationData.strings.CreateChannel_Genre_Header.uppercased()))
        entries.append(.genreItem(presentationData.theme, state.editingGenre))
        
        entries.append(.subgenreHeaderTitle(presentationData.theme, presentationData.strings.CreateChannel_Subgenre_Header.uppercased()))
        entries.append(.subgenreItem(presentationData.theme, state.editingSubgenre))
    }
    
    entries.append(.countryHeaderTitle(presentationData.theme, presentationData.strings.CreateChannel_Country_Header.uppercased()))
    entries.append(.countyItem(presentationData.theme, state.editingCountry))
    
    return entries
}

public func createChannelController(context: AccountContext, on navigationController: NavigationController, updatedAddressName: String, filteredPeerIds: [PeerId], price: Double? = nil, payType: ElloAppChannelPayType, startDate: Int64? = nil, endDate: Int64? = nil) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    
    // TODO: Check is need description
    let type: ItemListAvatarAndNameInfoItemTitleType = if startDate != nil {
        .onlineCourse
    } else {
        .channel
    }
    
    let genrePlaceholder = presentationData.strings.CreateChannel_Genre_Placeholder
    let subgenrePlaceholder = presentationData.strings.CreateChannel_Subgenre_Placeholder
    let initialState = CreateChannelState(
        creating: false,
        editingName: ItemListAvatarAndNameInfoItemName.title(title: "", description: "", type: type),
        editingDescriptionText: "",
        avatar: nil,
        selectedAgehood: .childhood,
        editingCategory: presentationData.strings.CreateChannel_Category_Placeholder,
        editingGenre: genrePlaceholder,
        editingSubgenre: subgenrePlaceholder,
        editingCountry: presentationData.strings.CreateChannel_Country_Placeholder,
        isPrivate: updatedAddressName.isEmpty)
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let stateValue = Atomic(value: initialState)
    let updateState: ((CreateChannelState) -> CreateChannelState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
//    var replaceControllerImpl: ((ViewController) -> Void)?
    var pushControllerImpl: ((ViewController) -> Void)?
    var presentControllerImpl: ((ViewController, Any?) -> Void)?
    var endEditingImpl: (() -> Void)?
    var focusOnDescriptionImpl: (() -> Void)?
    var presentContextController: ((_ items: [ContextMenuItem]) -> Void)?
    
    let actionsDisposable = DisposableSet()
    
    let currentAvatarMixin = Atomic<TGMediaAvatarMenuMixin?>(value: nil)
    
    let uploadedAvatar = Promise<UploadedPeerPhotoData>()
    var uploadedVideoAvatar: (Promise<UploadedPeerPhotoData?>, Double?)? = nil
    
    var countriesList: [Country] = []
    var categoriesList: [String] = []
    var genresList: [String] = []
    
    let arguments = CreateChannelArguments(context: context, updateEditingName: { editingName in
        updateState { current in
            var current = current
            switch editingName {
            case let .title(title, description, type):
                current.editingName = .title(title: String(title.prefix(255)), description: String(description.prefix(255)), type: type)
            case let .personName(firstName, lastName, _):
                current.editingName = .personName(firstName: String(firstName.prefix(255)), lastName: String(lastName.prefix(255)), phone: "")
            }
            return current
        }
    }, updateEditingDescriptionText: { text in
        updateState { current in
            var current = current
            current.editingDescriptionText = String(text.prefix(255))
            return current
        }
    }, done: {
        let (creating, title, description, agehood, category, genre, subgenre, country) = stateValue.with { state -> (Bool, composedTitle: String, editingDescriptionText: String, CurrentAgehood, category: String, genre: String, subgenre: String, country: String) in
            let genre: String
            let subgenre: String
            if state.editingCategory == state.musicCategory {
                genre = state.editingGenre == genrePlaceholder ? "" : state.editingGenre
                subgenre = state.editingSubgenre == genrePlaceholder ? "" : state.editingSubgenre
            } else {
                genre = ""
                subgenre = ""
            }
            return (
                state.creating,
                state.editingName.composedTitle,
                state.editingDescriptionText,
                state.selectedAgehood,
                state.editingCategory,
                genre,
                subgenre,
                state.editingCountry
            )
        }
        
        if !creating && !title.isEmpty {
            updateState { current in
                var current = current
                current.creating = true
                return current
            }
            
            endEditingImpl?()
            let countryCode = countriesList.first(where: { $0.name == country })?.countryCodes.first?.code
            actionsDisposable.add((context.engine.peers.createChannel(title: title, 
                                                                      description: description.isEmpty ? nil : description,
                                                                      payType: payType,
                                                                      cost: price,
                                                                      category: category,
                                                                      country: countryCode ?? "US",
                                                                      adult: agehood == .adulthood,
                                                                      startDate: startDate,
                                                                      endDate: endDate,
                                                                      genre: genre,
                                                                      subGenre: subgenre,
                                                                      name: updatedAddressName)
            |> deliverOnMainQueue).start(next: { peerId in
                let updatingAvatar = stateValue.with {
                    return $0.avatar
                }
                if let _ = updatingAvatar {
                    let _ = context.engine.peers.updatePeerPhoto(peerId: peerId, 
                                                                 photo: uploadedAvatar.get(), 
                                                                 video: uploadedVideoAvatar?.0.get(),
                                                                 videoStartTimestamp: uploadedVideoAvatar?.1,
                                                                 mapResourceToAvatarSizes: { resource, representations in
                        return mapResourceToAvatarSizes(postbox: context.account.postbox, resource: resource, representations: representations)
                    }).start()
                }
                
//                let controller = channelVisibilityController(context: context, peerId: peerId, mode: .initialSetup, upgradedToSupergroup: { _, f in f() })
                _ = (context.engine.peers.updateAddressName(domain: .peer(peerId), name: updatedAddressName)
                     |> timeout(10, queue: Queue.mainQueue(), alternate: .fail(.generic))
                     |> deliverOnMainQueue
                     |> afterDisposed {
                    Queue.mainQueue().async {
                        updateState { current in
                            var current = current
                            current.creating = false
                            return current
                        }
                    }
                }).start(error: { [weak navigationController] error in
                    guard let navigationController else { return }
                    
                    context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, chatController: nil, context: context, chatLocation: .peer(id: peerId), keepStack: .never, animated: true))
                }, completed: { [weak navigationController] in
                    guard let navigationController else { return }
                    
                    if !filteredPeerIds.isEmpty {
                        _ = (context.engine.peers.addChannelMembers(peerId: peerId, memberIds: filteredPeerIds)
                             |> deliverOnMainQueue
                        ).start()
                    }
                    
                    context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, 
                                                                                                  chatController: nil,
                                                                                                  context: context,
                                                                                                  chatLocation: .peer(id: peerId),
                                                                                                  keepStack: .never,
                                                                                                  animated: true))
                })
                
//                replaceControllerImpl?(controller)
            }, error: { error in
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                let text: String?
                switch error {
                case .generic, .tooMuchLocationBasedGroups:
                    text = presentationData.strings.Login_UnknownError
                case .tooMuchJoined:
                    pushControllerImpl?(oldChannelsController(context: context, intent: .create))
                    return
                case .restricted:
                    text = presentationData.strings.Common_ActionNotAllowedError
                case .serverProvided(let errorDescription):
                    text = errorDescription
                }
                
                if let text = text {
                    presentControllerImpl?(textAlertController(context: context, 
                                                               title: nil,
                                                               text: text,
                                                               actions: [TextAlertAction(type: .defaultAction,
                                                                                         title: presentationData.strings.Common_OK,
                                                                                         action: {})]), nil)
                }
            }))
        }
    }, changeProfilePhoto: {
        endEditingImpl?()
        
        let title = stateValue.with { state -> String in
            return state.editingName.composedTitle
        }
        
        let _ = (context.engine.data.get(
            ElloAppEngine.EngineData.Item.Peer.Peer(id: context.account.peerId),
            ElloAppEngine.EngineData.Item.Configuration.SearchBots()
        )
        |> deliverOnMainQueue).start(next: { peer, searchBotsConfiguration in
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            
            let legacyController = LegacyController(presentation: .custom, theme: presentationData.theme)
            legacyController.statusBar.statusBarStyle = .Ignore
            
            let emptyController = LegacyEmptyController(context: legacyController.context)!
            let navigationController = makeLegacyNavigationController(rootController: emptyController)
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.navigationBar.transform = CGAffineTransform(translationX: -1000.0, y: 0.0)
            
            legacyController.bind(controller: navigationController)
            
            endEditingImpl?()
            presentControllerImpl?(legacyController, nil)
            
            let completedChannelPhotoImpl: (UIImage) -> Void = { image in
                if let data = image.jpegData(compressionQuality: 0.6) {
                    let resource = LocalFileMediaResource(fileId: Int64.random(in: Int64.min ... Int64.max))
                    context.account.postbox.mediaBox.storeResourceData(resource.id, data: data)
                    let representation = ElloAppMediaImageRepresentation(dimensions: PixelDimensions(width: 640, height: 640), resource: resource, progressiveSizes: [], immediateThumbnailData: nil)
                    uploadedAvatar.set(context.engine.peers.uploadedPeerPhoto(resource: resource))
                    uploadedVideoAvatar = nil
                    updateState { current in
                        var current = current
                        current.avatar = .imageWithEditIcon(representation)
                        return current
                    }
                }
            }
            
            let completedChannelVideoImpl: (UIImage, Any?, TGVideoEditAdjustments?) -> Void = { image, asset, adjustments in
                if let data = image.jpegData(compressionQuality: 0.6) {
                    let photoResource = LocalFileMediaResource(fileId: Int64.random(in: Int64.min ... Int64.max))
                    context.account.postbox.mediaBox.storeResourceData(photoResource.id, data: data)
                    let representation = ElloAppMediaImageRepresentation(dimensions: PixelDimensions(width: 640, height: 640), resource: photoResource, progressiveSizes: [], immediateThumbnailData: nil)
                    updateState { state in
                        var state = state
                        state.avatar = .image(representation, true)
                        return state
                    }
                    
                    var videoStartTimestamp: Double? = nil
                    if let adjustments = adjustments, adjustments.videoStartValue > 0.0 {
                        videoStartTimestamp = adjustments.videoStartValue - adjustments.trimStartValue
                    }
                    
                    let signal = Signal<ElloAppMediaResource?, UploadPeerPhotoError> { subscriber in
                        let entityRenderer: LegacyPaintEntityRenderer? = adjustments.flatMap { adjustments in
                            if let paintingData = adjustments.paintingData, paintingData.hasAnimation {
                                return LegacyPaintEntityRenderer(account: context.account, adjustments: adjustments)
                            } else {
                                return nil
                            }
                        }
                        let uploadInterface = LegacyLiveUploadInterface(context: context)
                        let signal: SSignal
                        if let asset = asset as? AVAsset {
                            signal = TGMediaVideoConverter.convert(asset, adjustments: adjustments, watcher: uploadInterface, entityRenderer: entityRenderer)!
                        } else if let url = asset as? URL, let data = try? Data(contentsOf: url, options: [.mappedRead]), let image = UIImage(data: data), let entityRenderer = entityRenderer {
                            let durationSignal: SSignal = SSignal(generator: { subscriber in
                                let disposable = (entityRenderer.duration()).start(next: { duration in
                                    subscriber.putNext(duration)
                                    subscriber.putCompletion()
                                })
                                
                                return SBlockDisposable(block: {
                                    disposable.dispose()
                                })
                            })
                            signal = durationSignal.map(toSignal: { duration -> SSignal in
                                if let duration = duration as? Double {
                                    return TGMediaVideoConverter.renderUIImage(image, duration: duration, adjustments: adjustments, watcher: nil, entityRenderer: entityRenderer)!
                                } else {
                                    return SSignal.single(nil)
                                }
                            })
                           
                        } else {
                            signal = SSignal.complete()
                        }
                        
                        let signalDisposable = signal.start(next: { next in
                            if let result = next as? TGMediaVideoConversionResult {
                                if let image = result.coverImage, let data = image.jpegData(compressionQuality: 0.7) {
                                    context.account.postbox.mediaBox.storeResourceData(photoResource.id, data: data)
                                }
                                
                                if let timestamp = videoStartTimestamp {
                                    videoStartTimestamp = max(0.0, min(timestamp, result.duration - 0.05))
                                }
                                
                                var value = stat()
                                if stat(result.fileURL.path, &value) == 0 {
                                    if let data = try? Data(contentsOf: result.fileURL) {
                                        let resource: ElloAppMediaResource
                                        if let liveUploadData = result.liveUploadData as? LegacyLiveUploadInterfaceResult {
                                            resource = LocalFileMediaResource(fileId: liveUploadData.id)
                                        } else {
                                            resource = LocalFileMediaResource(fileId: Int64.random(in: Int64.min ... Int64.max))
                                        }
                                        context.account.postbox.mediaBox.storeResourceData(resource.id, data: data, synchronous: true)
                                        subscriber.putNext(resource)
                                    }
                                }
                                subscriber.putCompletion()
                            }
                        }, error: { _ in
                        }, completed: nil)
                        
                        let disposable = ActionDisposable {
                            signalDisposable?.dispose()
                        }
                        
                        return ActionDisposable {
                            disposable.dispose()
                        }
                    }
                    
                    uploadedAvatar.set(context.engine.peers.uploadedPeerPhoto(resource: photoResource))
                    
                    let promise = Promise<UploadedPeerPhotoData?>()
                    promise.set(signal
                    |> `catch` { _ -> Signal<ElloAppMediaResource?, NoError> in
                        return .single(nil)
                    }
                    |> mapToSignal { resource -> Signal<UploadedPeerPhotoData?, NoError> in
                        if let resource = resource {
                            return context.engine.peers.uploadedPeerVideo(resource: resource) |> map(Optional.init)
                        } else {
                            return .single(nil)
                        }
                    } |> afterNext { next in
                        if let next = next, next.isCompleted {
                            updateState { state in
                                var state = state
                                state.avatar = .image(representation, false)
                                return state
                            }
                        }
                    })
                    uploadedVideoAvatar = (promise, videoStartTimestamp)
                }
            }
            
            let mixin = TGMediaAvatarMenuMixin(context: legacyController.context, parentController: emptyController, hasSearchButton: true, hasDeleteButton: stateValue.with({ $0.avatar }) != nil, hasViewButton: false, personalPhoto: false, isVideo: false, saveEditedPhotos: false, saveCapturedMedia: false, signup: false)!
            let _ = currentAvatarMixin.swap(mixin)
            mixin.requestSearchController = { assetsController in
                let controller = WebSearchController(context: context, peer: peer, chatLocation: nil, configuration: searchBotsConfiguration, mode: .avatar(initialQuery: title, completion: { result in
                    assetsController?.dismiss()
                    completedChannelPhotoImpl(result)
                }))
                presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
            }
            mixin.didFinishWithImage = { image in
                if let image = image {
                    completedChannelPhotoImpl(image)
                }
            }
            mixin.didFinishWithVideo = { image, asset, adjustments in
                if let image = image, let asset = asset {
                    completedChannelVideoImpl(image, asset, adjustments)
                }
            }
            if stateValue.with({ $0.avatar }) != nil {
                mixin.didFinishWithDelete = {
                    updateState { current in
                        var current = current
                        current.avatar = nil
                        return current
                    }
                    uploadedAvatar.set(.never())
                }
            }
            mixin.didDismiss = { [weak legacyController] in
                let _ = currentAvatarMixin.swap(nil)
                legacyController?.dismiss()
            }
            let menuController = mixin.present()
            if let menuController = menuController {
                menuController.customRemoveFromParentViewController = { [weak legacyController] in
                    legacyController?.dismiss()
                }
            }
        })
    }, focusOnDescription: {
        focusOnDescriptionImpl?()
    }, updateCurrentAgehood: { agehoodState in
        updateState { current in
            var current = current
            current.selectedAgehood = agehoodState
            return current
        }
    }, tapAgePolicy: {
        let controller = CreateChannelAgePolicyController.controller(with: getAppBundle())
        let adopt = AdaptingController(viewController: controller)
        controller?.onTapBack = { [weak navigationController] in
            _ = navigationController?.popViewController(animated: true)
        }
        
        pushControllerImpl?(adopt)
    }, updateCategory: {
        var items: [ContextMenuItem] = []
        for category in categoriesList {
            let menuActionItem = ContextMenuActionItem(text: category, textColor: .primary, icon: { _ in nil }, action: { _, f in
                updateState { current in
                    var current = current
                    current.editingCategory = category
                    return current
                }
                
                f(.default)
            })
            let contextMenuItem = ContextMenuItem.action(menuActionItem)
            items.append(contextMenuItem)
        }
        presentContextController?(items)
    }, updateGenre: {
        var items: [ContextMenuItem] = []
        for genre in genresList {
            let menuActionItem = ContextMenuActionItem(text: genre, textColor: .primary, icon: { _ in nil }, action: { _, f in
                updateState { current in
                    var current = current
                    current.editingGenre = genre
                    return current
                }
                
                f(.default)
            })
            let contextMenuItem = ContextMenuItem.action(menuActionItem)
            items.append(contextMenuItem)
        }
        presentContextController?(items)
    }, updateSubgenre: {
        var items: [ContextMenuItem] = []
        for genre in genresList {
            let menuActionItem = ContextMenuActionItem(text: genre, textColor: .primary, icon: { _ in nil }, action: { _, f in
                updateState { current in
                    var current = current
                    current.editingSubgenre = genre
                    return current
                }
                
                f(.default)
            })
            let contextMenuItem = ContextMenuItem.action(menuActionItem)
            items.append(contextMenuItem)
        }
        presentContextController?(items)
    }, updateCountry: {
        func flag(country: String) -> String {
            let base: UInt32 = 127397
            var s = ""
            for v in country.unicodeScalars {
                s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
            }
            return String(s)
        }
        
        var items: [ContextMenuItem] = []
        for country in countriesList {
            let flagEmoji = flag(country: country.localizedName ?? "")
            let menuActionItem = ContextMenuActionItem(
                text: flagEmoji + " " + country.name,
                textColor: .primary,
                textLayout: .singleLine,
                icon: { _ in return nil },
                action: { _, f in
                    updateState { current in
                        var current = current
                        current.editingCountry = country.name
                        return current
                    }
                    
                    f(.default)
                })
            let contextMenuItem = ContextMenuItem.action(menuActionItem)
            items.append(contextMenuItem)
        }
        
        presentContextController?(items)
    })
    
    let signal = combineLatest(context.sharedContext.presentationData, statePromise.get())
        |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
            
            let rightNavigationButton: ItemListNavigationButton
            if state.creating {
                rightNavigationButton = ItemListNavigationButton(content: .none, style: .activity, enabled: false, action: {})
            } else {
                let isFilledTitle = !state.editingName.composedTitle.isEmpty
                let isSelectedCategory = state.editingCategory != presentationData.strings.CreateChannel_Category_Placeholder
                let isSelectedCountry = state.editingCountry != presentationData.strings.CreateChannel_Country_Placeholder
                rightNavigationButton = ItemListNavigationButton(
                    content: .text(presentationData.strings.Common_Create),
                    style: .bold,
                    enabled: isFilledTitle && isSelectedCategory && isSelectedCountry,
                    action: {
                        arguments.done()
                    })
            }
            
            let title: String
            switch payType {
            case .free:
                if updatedAddressName.isEmpty {
                    title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_Private
                } else {
                    title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_Public
                }
            case .subscription:
                title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_Subscription
            case .onlineCourse:
                title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_OnlineCourse
            }
            
            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(title), leftNavigationButton: nil, rightNavigationButton: rightNavigationButton, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: createChannelEntries(presentationData: presentationData, state: state, payType: payType), style: .blocks, focusItemTag: CreateChannelEntryTag.info)
            
            return (controllerState, (listState, arguments))
        } |> afterDisposed {
            actionsDisposable.dispose()
        }
    
    _ = (context.engine.localization.getCountriesList(accountManager: context.sharedContext.accountManager, langCode: "", forceUpdate: true)
         |> deliverOnMainQueue)
    .start(next: { countries in
        countriesList = countries
//        updateState { current in
//            var current = current
//            current.editingCountry = countries.first?.name ?? "Select Country"
//            return current
//        }
    })
    
    _ = (context.engine.localization.channelsCategoriesList()
         |> deliverOnMainQueue)
    .start(next: { categories in
        categoriesList = categories
//        updateState { current in
//            var current = current
//            current.editingCategory = categoriesList.first ?? "Select Category"
//            return current
//        }
    })
    
    _ = (context.engine.localization.channelsGenresList()
         |> deliverOnMainQueue)
    .start(next: { genres in
        genresList = genres
    })
    
    let controller = ItemListController(context: context, state: signal)
//    replaceControllerImpl = { [weak controller] value in
        // Simulator Navigation hack
//        #if DEBUG
//        let nc = (controller?.navigationController as? NavigationController)
//        _ = nc?.popViewController(animated: false)
//        _ = nc?.popViewController(animated: false)
//        pushControllerImpl?()
//        #else
//        (controller?.navigationController as? NavigationController)?.replaceAllButRootController(value, animated: true)
//        #endif
//    }
    
    pushControllerImpl = { [weak controller] value in
        controller?.push(value)
    }
    presentControllerImpl = { [weak controller] c, a in
        controller?.present(c, in: .window(.root), with: a)
    }
    controller.willDisappear = { _ in
        endEditingImpl?()
    }
    controller.didAppear = { _ in
        
    }
    endEditingImpl = { [weak controller] in
        controller?.view.endEditing(true)
    }
    focusOnDescriptionImpl = { [weak controller] in
        guard let controller = controller else {
            return
        }
        controller.forEachItemNode { itemNode in
            if let itemNode = itemNode as? ItemListMultilineInputItemNode, let itemTag = itemNode.tag, itemTag.isEqual(to: CreateChannelEntryTag.description) {
                itemNode.focus()
            }
        }
    }
    presentContextController = { [weak controller] items in
        final class LocationContentSource: ContextLocationContentSource {
            private let controller: ViewController
            private let location: CGPoint
            
            init(controller: ViewController, location: CGPoint) {
                self.controller = controller
                self.location = location
            }
            
            func transitionInfo() -> ContextControllerLocationViewInfo? {
                ContextControllerLocationViewInfo(location: location, contentAreaInScreenSpace: UIScreen.main.bounds)
            }
        }
        
        guard let controller else { return }
        
        let location = ContextContentSource.location(
            LocationContentSource(controller: controller, location: CGPoint(x: 0, y: 100))
        )
        
        let contextController = ContextController(account: context.account, presentationData: context.sharedContext.currentPresentationData.with { $0 }, source: location, items: .single(ContextController.Items(content: .list(items))), gesture: nil)
        controller.presentInGlobalOverlay(contextController)
    }
    return controller
}
