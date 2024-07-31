
import Postbox
import ElloAppApi
import SwiftSignalKit

func _internal_exportMessageLink(account: Account, peerId: PeerId, messageId: MessageId, isThread: Bool = false) -> Signal<String?, NoError> {
    return account.postbox.transaction { transaction -> (Peer, MessageId)? in
        let peer: Peer? = transaction.getPeer(messageId.peerId)
        if let peer = peer {
            return (peer, messageId)
        } else {
            return nil
        }
    }
    |> mapToSignal { data -> Signal<String?, NoError> in
        guard let (peer, sourceMessageId) = data else {
            return .single(nil)
        }
        if let input = apiInputChannel(peer) {
            var flags: Int32 = 0
            flags |= 1 << 0
            if isThread {
                flags |= 1 << 1
            }
            return account.network.request(Api.functions.channels.exportMessageLink(flags: flags, channel: input, id: sourceMessageId.id)) 
            |> mapError { _ in return }
            |> map { res in
                switch res {
                    case let .exportedMessageLink(link, _):
                        return link
                }
            } |> `catch` { _ -> Signal<String?, NoError> in
                guard let peer = peer as? ElloAppChannel,
                      let userName = peer.username
                else {
                    return .single(nil)
                }
                
                let urlString = "https://ello.team/\(userName)/\(messageId.id)"
                return .single(urlString)
            }
        } else {
            return .single(nil)
        }
    }
}

/// Add own shareLink message https://elloapp.atlassian.net/wiki/spaces/EM/pages/53608463/Share+Link
func _internal_shareMessageLink(account: Account, peerId: PeerId, messageId: MessageId) -> Signal<String?, NoError> {
    return account.postbox.transaction { transaction -> SharedLinkItem.PeerType? in
        let peer: Peer? = transaction.getPeer(messageId.peerId)
        switch peer {
        case is ElloAppChannel:
            return .channel
        case is ElloAppGroup:
            return .group
        default:
            return .none
        }
    }
    |> mapToSignal { peerType -> Signal<String?, NoError> in
        guard let peerType else {
            return .single(nil)
        }
        return account.network.request(Api.shareLink.generateLink(peerId: Int(peerId.id._internalGetInt64Value()), peerType: peerType, messageId: Int(messageId.id)))
        |> mapError { _ in return }
        |> map { hashItem -> String? in
            return "ello.team/" + hashItem.hash
        } |> `catch` { _ -> Signal<String?, NoError> in
            return .single(nil)
        }
    }
}
