import Foundation
import Postbox
import SwiftSignalKit

func _internal_storedMessageFromSearchPeer(account: Account, peer: Peer) -> Signal<PeerId, NoError> {
    return account.postbox.transaction { transaction -> PeerId in
        if transaction.getPeer(peer.id) == nil {
            updatePeers(transaction: transaction, peers: [peer], update: { previousPeer, updatedPeer in
                return updatedPeer
            })
        }
        if let group = transaction.getPeer(peer.id) as? ElloAppGroup, let migrationReference = group.migrationReference {
            return migrationReference.peerId
        }
        return peer.id
    }
}

func _internal_storedMessageFromSearchPeers(account: Account, peers: [Peer]) -> Signal<Never, NoError> {
    return account.postbox.transaction { transaction -> Void in
        for peer in peers {
            if transaction.getPeer(peer.id) == nil {
                updatePeers(transaction: transaction, peers: [peer], update: { previousPeer, updatedPeer in
                    return updatedPeer
                })
            }
        }
    }
    |> ignoreValues
}

func _internal_storeMessageFromSearch(transaction: Transaction, message: Message) {
    if transaction.getMessage(message.id) == nil {
        for (_, peer) in message.peers {
            if transaction.getPeer(peer.id) == nil {
                updatePeers(transaction: transaction, peers: [peer], update: { previousPeer, updatedPeer in
                    return updatedPeer
                })
            }
        }
        
        let storeMessage = StoreMessage(id: .Id(message.id), globallyUniqueId: message.globallyUniqueId, groupingKey: message.groupingKey, threadId: message.threadId, timestamp: message.timestamp, flags: StoreMessageFlags(message.flags), tags: message.tags, globalTags: message.globalTags, localTags: message.localTags, forwardInfo: message.forwardInfo.flatMap(StoreMessageForwardInfo.init), authorId: message.author?.id, text: message.text, attributes: message.attributes, media: message.media, likes: 0)
        
        let _ = transaction.addMessages([storeMessage], location: .Random)
    }
}
