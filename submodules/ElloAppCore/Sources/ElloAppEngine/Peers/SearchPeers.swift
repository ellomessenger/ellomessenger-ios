import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit


public struct FoundPeer: Equatable {
    public let peer: Peer
    public let subscribers: Int32?
    
    public init(peer: Peer, subscribers: Int32?) {
        self.peer = peer
        self.subscribers = subscribers
    }
    
    public static func ==(lhs: FoundPeer, rhs: FoundPeer) -> Bool {
        return lhs.peer.isEqual(rhs.peer) && lhs.subscribers == rhs.subscribers
    }
}

extension FoundPeer: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(peer.id)
        hasher.combine(subscribers)
    }
}

func _internal_searchPeers(account: Account, query: String, isRecomended: Bool, isNew: Bool, isPaid: Bool, isCourse: Bool, isFree: Bool, country: String, category: String, genre: String, page: Int) -> Signal<([FoundPeer], [FoundPeer]), NoError> {
    let searchResult = account.network.request(Api.functions.contacts.search(q: query, limit: 20, isRecomended: isRecomended, isNew: isNew, isPaid: isPaid, isCourse: isCourse, isFree: isFree, country: country, category: category, genre: genre, page: page), automaticFloodWait: false)
    |> map(Optional.init)
    |> `catch` { _ in
        return Signal<Api.contacts.Found?, NoError>.single(nil)
    }
    let processedSearchResult = searchResult
    |> mapToSignal { result -> Signal<([FoundPeer], [FoundPeer]), NoError> in
        if let result = result {
            switch result {
            case let .found(myResults, results, chats, users):
                return account.postbox.transaction { transaction -> ([FoundPeer], [FoundPeer]) in
                    var peers: [PeerId: Peer] = [:]
                    var subscribers: [PeerId: Int32] = [:]
                    for user in users {
                        if let user = ElloAppUser.merge(transaction.getPeer(user.peerId) as? ElloAppUser, rhs: user) {
                            peers[user.id] = user
                        }
                    }
                    
                    for chat in chats {
                        if let groupOrChannel = parseElloAppGroupOrChannel(chat: chat) {
                            peers[groupOrChannel.id] = groupOrChannel
                            switch chat {
                                /*feed*/
                                case let .channel(_, _, _, _, _, _, _, _, _, _, _, participantsCount, _, _, _, _, _, _, _):
                                    if let participantsCount = participantsCount {
                                        subscribers[groupOrChannel.id] = participantsCount
                                    }
                                default:
                                    break
                            }
                        }
                    }
                    
                    updatePeers(transaction: transaction, peers: Array(peers.values), update: { _, updated in
                        return updated
                    })
                    
                    var renderedMyPeers: [FoundPeer] = []
                    for result in myResults {
                        let peerId: PeerId = result.peerId
                        if let peer = peers[peerId] {
                            if let group = peer as? ElloAppGroup, group.migrationReference != nil {
                                continue
                            }
                            renderedMyPeers.append(FoundPeer(peer: peer, subscribers: subscribers[peerId]))
                        }
                    }
                    
                    var renderedPeers: [FoundPeer] = []
                    for result in results {
                        let peerId: PeerId = result.peerId
                        if let peer = peers[peerId] {
                            if let group = peer as? ElloAppGroup, group.migrationReference != nil {
                                continue
                            }
                            renderedPeers.append(FoundPeer(peer: peer, subscribers: subscribers[peerId]))
                        }
                    }
                    
                    return (renderedMyPeers, renderedPeers)
                }
            }
        } else {
            return .single(([], []))
        }
    }
    
    return processedSearchResult
}

