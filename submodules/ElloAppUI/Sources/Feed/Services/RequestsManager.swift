//
//  RequestsManager.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import UIKit
import ElloAppApi
import ElloAppCore
import Postbox
import SwiftSignalKit
import AccountContext

final class RequestsManager {
    typealias UpdateFeedFilterItem = Api.functions.feeds.UpdateFeedFilterItem
    enum CommonError: Error, LocalizedError {
        case message(String)
        
        var errorDescription: String {
            switch self {
            case let .message(value): return value
            }
        }
    }
    private let actionDisposable = MetaDisposable()
    private let filtersDisposable = MetaDisposable()
    
    static let feedPageLimit = 50
    
    deinit {
        actionDisposable.dispose()
    }
}

// MARK: - Get Feed
extension RequestsManager {
    func getFeed(with context: AccountContext, page: Int, limit: Int, isFeedExplore: Bool = false, completionHandler: @escaping (_ feed: Api.Feeds) -> Void) {
        actionDisposable.set(
            (feedWith(context: context, page: page, limit: limit, isFeedExplore: isFeedExplore)
             |> deliverOnMainQueue)
            .start(next: { result in
                completionHandler(result)
            }, error: { error in
                debugPrint("error: \(error)")
            })
        )
    }
    
    private func feedWith(context: AccountContext, page: Int, limit: Int, isFeedExplore: Bool) -> Signal<Api.Feeds, CommonError> {
        let request = Api.functions.feeds.readHistory(page: Int32(page), limit: Int32(limit), isFeedExplore: isFeedExplore)
        return context.account.network.request(request)
        |> mapError{ error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.Feeds, CommonError> in
            return .single(result)
        }
    }
}
    
// MARK: - Get Feed Filters
extension RequestsManager {
    func getFilters(with context: AccountContext, completionHandler: @escaping (_ filters: Api.functions.feeds.FeedFilterResponse) -> Void) {
        debugPrint("getFilters")
        _ = (filtersWith(context: context)
             |> deliverOnMainQueue)
        .start(next: { result in
            debugPrint("IDS: \(result.all)")
            completionHandler(result)
        }, error: { error in
            debugPrint("error: \(error)")
        })
    }
    
    private func filtersWith(context: AccountContext) -> Signal<Api.functions.feeds.FeedFilterResponse, CommonError> {
        return context.account.network.request(Api.functions.feeds.getFeedFilter())
        |> mapError{ error -> CommonError in
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.functions.feeds.FeedFilterResponse, CommonError> in
            return .single(result)
        }
    }
}

// MARK: - Get Feed Update
extension RequestsManager {
    func updateFilters(with context: AccountContext, item: FeedFilterItem, completionHandler: @escaping (_ filters: Api.functions.feeds.UpdateFeedFilterResponse) -> Void) {
        debugPrint("updateFilters")
        _ = (updateFiltersWith(context: context, item: item)
             |> deliverOnMainQueue)
        .start(next: { result in
            completionHandler(result)
        }, error: { error in
            debugPrint("error: \(error)")
        })
    }
    
    private func updateFiltersWith(context: AccountContext, item: FeedFilterItem) -> Signal<Api.functions.feeds.UpdateFeedFilterResponse, CommonError> {
        return context.account.network.request(Api.functions.feeds.updateFeedFilter(with: item.toDictionary()))
        |> mapError{ error -> CommonError in
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.functions.feeds.UpdateFeedFilterResponse, CommonError> in
            return .single(result)
        }
    }
}

// MARK: - Get Feed Update
extension RequestsManager {
    func getChannels(with context: AccountContext, ids: [Int], completionHandler: @escaping (_ channels: [ElloAppChannel]) -> Void) {
        debugPrint("updateFilters")
        let ids = ids.compactMap { Api.InputChannel.inputChannel(channelId: Int64($0), accessHash: 0) }
        _ = (getChannelsWith(context: context, ids: ids)
             |> deliverOnMainQueue)
        .start(next: { result in
            let history = FeedHistory()
            let chatsOrGroups = result.compactMap { history.parse(chat: $0) as? ElloAppChannel }
            
            completionHandler(chatsOrGroups)
        }, error: { error in
            debugPrint("error: \(error)")
        })
    }
    
    private func getChannelsWith(context: AccountContext, ids: [Api.InputChannel]) -> Signal<[Api.Chat], CommonError> {
        return context.account.network.request(Api.functions.channels.getChannels(id: ids))
        |> mapError{ error -> CommonError in
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<[Api.Chat], CommonError> in
            switch result {
            case .chats(chats: let chats):
                return .single(chats)
            case .chatsSlice(_, chats: let chats):
                return .single(chats)
            }
        }
    }
}

// MARK: - Likes
extension RequestsManager {
    func addLike(with accountContext: AccountContext, messageId: Int, peerId: Int64) async throws -> LikesStatusItem {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LikesStatusItem, Error>) in
            _ = (accountContext.account.network.request(Api.likes.addLike(userId: accountContext
                .account.peerId.id._internalGetInt64Value(), messageId: messageId, peerType: .channel, peerId: peerId))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                debugPrint(error)
                return .message(error.errorDescription)
            }).start { statusItem in
                continuation.resume(returning: statusItem)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func removeLike(with accountContext: AccountContext, messageId: Int, peerId: Int64) async throws -> LikesStatusItem {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LikesStatusItem, Error>) in
            _ = (accountContext.account.network.request(Api.likes.removeLike(userId: accountContext
                .account.peerId.id._internalGetInt64Value(), messageId: messageId, peerType: .channel, peerId: peerId))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                debugPrint(error)
                return .message(error.errorDescription)
            }).start { statusItem in
                continuation.resume(returning: statusItem)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Recomendations
extension RequestsManager {
    func getRecomendations(with accountContext: AccountContext, query: String, isNew: Bool, isPaid: Bool, isCourse: Bool, isFree: Bool, country: String, category: String, genre: String, page: Int) async -> [FoundPeer] {
        await withCheckedContinuation { (continuation: CheckedContinuation<[FoundPeer], Never>) in
            _ = accountContext.engine.contacts.searchRemotePeers(
                query: query,
                isRecomended: true,
                isNew: isNew,
                isPaid: isPaid,
                isCourse: isCourse,
                isFree: isFree,
                country: country,
                category: category,
                genre: genre,
                page: page
            ).start(next: { result in
                continuation.resume(returning: result.1)
            })
        }
    }
}

// MARK: - Countries
extension RequestsManager {
    func getCountries(with accountContext: AccountContext) async -> [Country] {
        await withCheckedContinuation { (continuation: CheckedContinuation<[Country], Never>) in
            _ = accountContext.engine.localization.getCountriesList(
                accountManager: accountContext.sharedContext.accountManager,
                langCode: ""
            ).start(next: { result in
                continuation.resume(returning: result)
            })
        }
    }
}

// MARK: - Categories
extension RequestsManager {
    func getCategories(with accountContext: AccountContext) async -> [String] {
        await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
            _ = accountContext.engine.localization.channelsCategoriesList().start(next: { result in
                continuation.resume(returning: result)
            })
        }
    }
}

// MARK: - Sub genres
extension RequestsManager {
    func getGenres(with accountContext: AccountContext) async -> [String] {
        await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
            _ = accountContext.engine.localization.channelsGenresList().start(next: { result in
                continuation.resume(returning: result)
            })
        }
    }
}
