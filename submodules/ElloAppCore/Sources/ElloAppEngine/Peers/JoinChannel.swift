import Foundation
import Postbox
import ElloAppApi
import SwiftSignalKit
import MtProtoKit


public enum JoinChannelError {
    case generic
    case tooMuchJoined
    case tooMuchUsers
    case inviteRequestSent
}

public enum JoinPaidChannelError {
    case generic
    case tooMuchJoined
    case tooMuchUsers
    case inviteRequestSent
    case notEnoughMoney
}

func _internal_joinChannel(account: Account, peerId: PeerId, hash: String?) -> Signal<RenderedChannelParticipant?, JoinChannelError> {
    return account.postbox.loadedPeerWithId(peerId)
    |> take(1)
    |> castError(JoinChannelError.self)
    |> mapToSignal { peer -> Signal<RenderedChannelParticipant?, JoinChannelError> in
        if let inputChannel = apiInputChannel(peer) {
            let request: Signal<Api.Updates, MTRpcError>
            if let hash = hash {
                request = account.network.request(Api.functions.messages.importChatInvite(hash: hash))
            } else {
                request = account.network.request(Api.functions.channels.joinChannel(channel: inputChannel))
            }
            return request
            |> mapError { error -> JoinChannelError in
                switch error.errorDescription {
                    case "CHANNELS_TOO_MUCH":
                        return .tooMuchJoined
                    case "USERS_TOO_MUCH":
                        return .tooMuchUsers
                    case "INVITE_REQUEST_SENT":
                        return .inviteRequestSent
                    default:
                        return .generic
                }
            }
            |> mapToSignal { updates -> Signal<RenderedChannelParticipant?, JoinChannelError> in
                account.stateManager.addUpdates(updates)
                
                return account.network.request(Api.functions.channels.getParticipant(channel: inputChannel, participant: .inputPeerSelf))
                |> map(Optional.init)
                |> `catch` { _ -> Signal<Api.channels.ChannelParticipant?, JoinChannelError> in
                    return .single(nil)
                }
                |> mapToSignal { result -> Signal<RenderedChannelParticipant?, JoinChannelError> in
                    guard let result = result else {
                        return .fail(.generic)
                    }
                    return account.stateManager.standalonePollDifference()
                    |> take(1)
                    |> castError(JoinChannelError.self)
                    |> mapToSignal { _ -> Signal<RenderedChannelParticipant?, JoinChannelError> in
                        return account.postbox.transaction { transaction -> RenderedChannelParticipant? in
                            var peers: [PeerId: Peer] = [:]
                            var presences: [PeerId: PeerPresence] = [:]
                            guard let peer = transaction.getPeer(account.peerId) else {
                                return nil
                            }
                            peers[account.peerId] = peer
                            if let presence = transaction.getPeerPresence(peerId: account.peerId) {
                                presences[account.peerId] = presence
                            }
                            let updatedParticipant: ChannelParticipant
                            switch result {
                            case let .channelParticipant(participant, _, _):
                                updatedParticipant = ChannelParticipant(apiParticipant: participant)
                            }
                            if case let .member(_, _, maybeAdminInfo, _, _) = updatedParticipant {
                                if let adminInfo = maybeAdminInfo {
                                    if let peer = transaction.getPeer(adminInfo.promotedBy) {
                                        peers[peer.id] = peer
                                    }
                                }
                            }
                            
//                            if let channel = transaction.getPeer(peerId) as? ElloAppChannel, case .broadcast = channel.info {
//                                let notificationSettings = transaction.getPeerNotificationSettings(peerId) as? ElloAppPeerNotificationSettings ?? ElloAppPeerNotificationSettings.defaultSettings
//                                transaction.updateCurrentPeerNotificationSettings([peerId: notificationSettings.withUpdatedMuteState(.muted(until: Int32.max))])
//                            }
                            
//                            _ = (account.stateManager.standalonePollDifference()
//                                 |> delay(1.0, queue: Queue.mainQueue())
//                            ).start()
                            
                            return RenderedChannelParticipant(participant: updatedParticipant, peer: peer, peers: peers, presences: presences)
                        }
                        |> castError(JoinChannelError.self)
                    }
                }
            }
        } else {
            return .fail(.generic)
        }
    }
}

func _internal_joinPaidChannel(account: Account, peerId: PeerId) -> Signal<RenderedChannelParticipant?, JoinPaidChannelError> {
    return account.postbox.loadedPeerWithId(peerId)
    |> take(1)
    |> castError(JoinPaidChannelError.self)
    |> mapToSignal { peer -> Signal<RenderedChannelParticipant?, JoinPaidChannelError> in
        if let inputChannel = apiInputChannel(peer) {
            let request: Signal<PaidSubscriptionItem, MTRpcError>
            request = account.network.request(Api.paidSubscription.subscribe(peerId: Int(peerId.id._internalGetInt64Value()), peerType: 4))
            return request
            |> mapError { error -> JoinPaidChannelError in
                switch error.errorDescription {
                case "CHANNELS_TOO_MUCH":
                    return .tooMuchJoined
                case "USERS_TOO_MUCH":
                    return .tooMuchUsers
                case "INVITE_REQUEST_SENT":
                    return .inviteRequestSent
                case let errorText where (errorText?.contains("not enough money") ?? false):
                    return .notEnoughMoney
                default:
                    return .generic
                }
            }
            |> mapToSignal { updates -> Signal<RenderedChannelParticipant?, JoinPaidChannelError> in
                return account.network.request(Api.functions.channels.getParticipant(channel: inputChannel, participant: .inputPeerSelf))
                |> map(Optional.init)
                |> `catch` { _ -> Signal<Api.channels.ChannelParticipant?, JoinPaidChannelError> in
                    return .single(nil)
                }
                |> mapToSignal { result -> Signal<RenderedChannelParticipant?, JoinPaidChannelError> in
                    guard let result = result else {
                        return .fail(.generic)
                    }
                    return account.stateManager.standalonePollDifference()
                    |> take(1)
                    |> castError(JoinPaidChannelError.self)
                    |> mapToSignal { _ -> Signal<RenderedChannelParticipant?, JoinPaidChannelError> in
                        return account.postbox.transaction { transaction -> RenderedChannelParticipant? in
                            var peers: [PeerId: Peer] = [:]
                            var presences: [PeerId: PeerPresence] = [:]
                            guard let peer = transaction.getPeer(account.peerId) else {
                                return nil
                            }
                            peers[account.peerId] = peer
                            if let presence = transaction.getPeerPresence(peerId: account.peerId) {
                                presences[account.peerId] = presence
                            }
                            let updatedParticipant: ChannelParticipant
                            switch result {
                            case let .channelParticipant(participant, _, _):
                                updatedParticipant = ChannelParticipant(apiParticipant: participant)
                            }
                            if case let .member(_, _, maybeAdminInfo, _, _) = updatedParticipant {
                                if let adminInfo = maybeAdminInfo {
                                    if let peer = transaction.getPeer(adminInfo.promotedBy) {
                                        peers[peer.id] = peer
                                    }
                                }
                            }
                            
//                            if let channel = transaction.getPeer(peerId) as? ElloAppChannel, case .broadcast = channel.info {
//                                let notificationSettings = transaction.getPeerNotificationSettings(peerId) as? ElloAppPeerNotificationSettings ?? ElloAppPeerNotificationSettings.defaultSettings
//                                transaction.updateCurrentPeerNotificationSettings([peerId: notificationSettings.withUpdatedMuteState(.muted(until: Int32.max))])
//                            }
                            
                            return RenderedChannelParticipant(participant: updatedParticipant, peer: peer, peers: peers, presences: presences)
                        }
                        |> castError(JoinPaidChannelError.self)
                    }
                }
            }
        } else {
            return .fail(.generic)
        }
    }
}
