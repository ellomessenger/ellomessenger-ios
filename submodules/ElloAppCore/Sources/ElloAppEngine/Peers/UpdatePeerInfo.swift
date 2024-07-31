import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit


public enum UpdatePeerTitleOrDescriptionError {
    case generic
    case elloContaining(String)
}

func _internal_updatePeerTitle(account: Account, peerId: PeerId, title: String) -> Signal<Void, UpdatePeerTitleOrDescriptionError> {
    return account.postbox.transaction { transaction -> Signal<Void, UpdatePeerTitleOrDescriptionError> in
        if let peer = transaction.getPeer(peerId) {
            if let peer = peer as? ElloAppChannel, let inputChannel = apiInputChannel(peer) {
                return account.network.request(Api.functions.channels.editTitle(channel: inputChannel, title: title))
                    |> mapError { error -> UpdatePeerTitleOrDescriptionError in
                        if error.errorCode == 2 {
                            return .elloContaining(error.errorDescription)
                        }
                        
                        return .generic
                    }
                    |> mapToSignal { result -> Signal<Void, UpdatePeerTitleOrDescriptionError> in
                        account.stateManager.addUpdates(result)
                        
                        return account.postbox.transaction { transaction -> Void in
                            if let apiChat = apiUpdatesGroups(result).first, let updatedPeer = parseElloAppGroupOrChannel(chat: apiChat) {
                                updatePeers(transaction: transaction, peers: [updatedPeer], update: { _, updated in
                                    return updated
                                })
                            }
                        } |> mapError { _ -> UpdatePeerTitleOrDescriptionError in }
                    }
            } else if let peer = peer as? ElloAppGroup {
                return account.network.request(Api.functions.messages.editChatTitle(chatId: peer.id.id._internalGetInt64Value(), title: title))
                    |> mapError { error -> UpdatePeerTitleOrDescriptionError in
                        if error.errorCode == 2 {
                            return .elloContaining(error.errorDescription)
                        }
                        
                        return .generic
                    }
                    |> mapToSignal { result -> Signal<Void, UpdatePeerTitleOrDescriptionError> in
                        account.stateManager.addUpdates(result)
                        
                        return account.postbox.transaction { transaction -> Void in
                            if let apiChat = apiUpdatesGroups(result).first, let updatedPeer = parseElloAppGroupOrChannel(chat: apiChat) {
                                updatePeers(transaction: transaction, peers: [updatedPeer], update: { _, updated in
                                    return updated
                                })
                            }
                        } |> mapError { _ -> UpdatePeerTitleOrDescriptionError in }
                    }
            } else {
                return .fail(.generic)
            }
        } else {
            return .fail(.generic)
        }
    } |> mapError { _ -> UpdatePeerTitleOrDescriptionError in } |> switchToLatest
}

func _internal_updatePeerDescription(account: Account, peerId: PeerId, description: String?) -> Signal<Void, UpdatePeerTitleOrDescriptionError> {
    return account.postbox.transaction { transaction -> Signal<Void, UpdatePeerTitleOrDescriptionError> in
        if let peer = transaction.getPeer(peerId) {
            if (peer is ElloAppChannel || peer is ElloAppGroup), let inputPeer = apiInputPeer(peer) {
                return account.network.request(Api.functions.messages.editChatAbout(peer: inputPeer, about: description ?? ""))
                |> mapError { error -> UpdatePeerTitleOrDescriptionError in
                    if error.errorCode == 2 {
                        return .elloContaining(error.errorDescription)
                    }
                    
                    return .generic
                }
                |> mapToSignal { result -> Signal<Void, UpdatePeerTitleOrDescriptionError> in
                    return account.postbox.transaction { transaction -> Void in
                        if case .boolTrue = result {
                            transaction.updatePeerCachedData(peerIds: Set([peerId]), update: { _, current in
                                if let current = current as? CachedChannelData {
                                    return current.withUpdatedAbout(description)
                                } else if let current = current as? CachedGroupData {
                                    return current.withUpdatedAbout(description)
                                } else {
                                    return current
                                }
                            })
                        }
                    }
                    |> mapError { _ -> UpdatePeerTitleOrDescriptionError in }
                }
            } else {
                return .fail(.generic)
            }
        } else {
            return .fail(.generic)
        }
    } |> mapError { _ -> UpdatePeerTitleOrDescriptionError in } |> switchToLatest
}
