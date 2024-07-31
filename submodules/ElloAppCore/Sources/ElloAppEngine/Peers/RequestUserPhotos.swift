
import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit


public struct ElloAppPeerPhoto {
    public let image: ElloAppMediaImage
    public let reference: ElloAppMediaImageReference?
    public let date: Int32
    public let index: Int
    public let totalCount: Int
    public let messageId: MessageId?
    public init(image: ElloAppMediaImage, reference: ElloAppMediaImageReference?, date: Int32, index: Int, totalCount: Int, messageId: MessageId?) {
        self.image = image
        self.reference = reference
        self.date = date
        self.index = index
        self.totalCount = totalCount
        self.messageId = messageId
    }
}

func _internal_requestPeerPhotos(postbox: Postbox, network: Network, peerId: PeerId) -> Signal<[ElloAppPeerPhoto], NoError> {
    return postbox.transaction{ transaction -> Peer? in
        return transaction.getPeer(peerId)
    }
    |> mapToSignal { peer -> Signal<[ElloAppPeerPhoto], NoError> in
        if let peer = peer as? ElloAppUser, let inputUser = apiInputUser(peer) {
            return network.request(Api.functions.photos.getUserPhotos(userId: inputUser, offset: 0, maxId: 0, limit: 100))
            |> map {Optional($0)}
            |> mapError {_ in}
            |> `catch` { _ -> Signal<Api.photos.Photos?, NoError> in
                return .single(nil)
            }
            |> map { result -> [ElloAppPeerPhoto] in
                if let result = result {
                    let totalCount:Int
                    let photos: [Api.Photo]
                    switch result {
                        case let .photos(photosValue, _):
                            photos = photosValue
                            totalCount = photos.count
                        case let .photosSlice(count, photosValue, _):
                            photos = photosValue
                            totalCount = Int(count)
                    }
                    
                    var images: [ElloAppPeerPhoto] = []
                    for i in 0 ..< photos.count {
                        if let image = elloappMediaImageFromApiPhoto(photos[i]), let reference = image.reference {
                            var date: Int32 = 0
                            switch photos[i] {
                                case let .photo(_, _, _, _, apiDate, _, _, _):
                                    date = apiDate
                                case .photoEmpty:
                                    break
                            }
                            images.append(ElloAppPeerPhoto(image: image, reference: reference, date: date, index: i, totalCount: totalCount, messageId: nil))
                        }
                    }
                    
                    return images
                } else {
                    return []
                }
            }
        } else if let peer = peer, let inputPeer = apiInputPeer(peer) {
            return network.request(Api.functions.messages.search(flags: 0, peer: inputPeer, q: "", fromId: nil, topMsgId: nil, filter: .inputMessagesFilterChatPhotos, minDate: 0, maxDate: 0, offsetId: 0, addOffset: 0, limit: 1000, maxId: 0, minId: 0, hash: 0))
            |> map(Optional.init)
            |> `catch` { _ -> Signal<Api.messages.Messages?, NoError> in
                return .single(nil)
            }
            |> mapToSignal { result -> Signal<[ElloAppPeerPhoto], NoError> in
                if let result = result {
                    let messages: [Api.Message]
                    let chats: [Api.Chat]
                    let users: [Api.User]
                    switch result {
                        case let .channelMessages(_, _, _, _, apiMessages, apiChats, apiUsers):
                            messages = apiMessages
                            chats = apiChats
                            users = apiUsers
                        case let .messages(apiMessages, apiChats, apiUsers):
                            messages = apiMessages
                            chats = apiChats
                            users = apiUsers
                        case let .messagesSlice(_, _, _, _, apiMessages, apiChats, apiUsers):
                            messages = apiMessages
                            chats = apiChats
                            users = apiUsers
                        case .messagesNotModified:
                            messages = []
                            chats = []
                            users = []
                    }
                    
                    return postbox.transaction { transaction -> [Message] in
                        var peers: [PeerId: Peer] = [:]
                        
                        for user in users {
                            if let user = ElloAppUser.merge(transaction.getPeer(user.peerId) as? ElloAppUser, rhs: user) {
                                peers[user.id] = user
                            }
                        }
                        
                        for chat in chats {
                            if let groupOrChannel = parseElloAppGroupOrChannel(chat: chat) {
                                peers[groupOrChannel.id] = groupOrChannel
                            }
                        }
                        
                        var renderedMessages: [Message] = []
                        for message in messages {
                            if let message = StoreMessage(apiMessage: message), let renderedMessage = locallyRenderedMessage(message: message, peers: peers) {
                                renderedMessages.append(renderedMessage)
                            }
                        }
                        
                        return renderedMessages
                    } |> map { messages -> [ElloAppPeerPhoto] in
                        var photos: [ElloAppPeerPhoto] = []
                        var index:Int = 0
                        for message in messages {
                            if let media = message.media.first as? ElloAppMediaAction {
                                switch media.action {
                                    case let .photoUpdated(image):
                                        if let image = image {
                                            photos.append(ElloAppPeerPhoto(image: image, reference: image.reference, date: message.timestamp, index: index, totalCount: messages.count, messageId: message.id))
                                        }
                                    default:
                                        break
                                }
                            }
                            index += 1
                        }
                        return photos
                    }
                    
                } else {
                    return .single([])
                }
            }
        } else {
            return .single([])
        }
    }
}
