//
//  FeedChannel.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import UIKit
import Postbox
import ElloAppCore

struct FeedRootItem {
    var id: StoreMessageId
    var messageId: MessageId? {
        switch id {
        case .Id(let messageId):
            return messageId
        default:
            return nil
        }
    }
    var timestamp: Int32
    var authorId: PeerId?
    var text: String
    var media: [Media]
    var channel: ElloAppChannel?
    var storeMessage: StoreMessage?
    
    var views: Int
    var reactions: Int
    var replyAttribute: ReplyThreadMessageAttribute?
    var isPinned: Bool {
        storeMessage?.tags.contains(.pinned) ?? false
    }
    var isLiked: Bool
}

extension FeedRootItem: Hashable {
    static func == (lhs: FeedRootItem, rhs: FeedRootItem) -> Bool {
        if lhs.id.peerId != rhs.id.peerId {
            return false
        }
        if lhs.messageId != rhs.messageId {
            return false
        }
        if lhs.messageId != rhs.messageId {
            return false
        }
        if lhs.messageId != rhs.messageId {
            return false
        }
        if !areMediaArraysEqual(lhs.media, rhs.media) {
            return false
        }
        if lhs.channel != rhs.channel {
            return false
        }
        if lhs.views != rhs.views {
            return false
        }
        if lhs.reactions != rhs.reactions {
            return false
        }
        if lhs.isLiked != rhs.isLiked {
            return false
        }
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.peerId)
        hasher.combine(messageId)
        hasher.combine(timestamp)
        hasher.combine(authorId)
        hasher.combine(text)
        hasher.combine(views)
        hasher.combine(reactions)
        hasher.combine(isLiked)
    }
}

extension FeedRootItem {
    init(storeMessage: StoreMessage, channel: ElloAppChannel?) {
        id = storeMessage.id
        timestamp = storeMessage.timestamp
        authorId = storeMessage.authorId
        text = storeMessage.text
        media = storeMessage.media
        self.channel = channel
        self.storeMessage = storeMessage
        views = storeMessage.views
//        reactions = storeMessage.reactions
        reactions = storeMessage.likes
        replyAttribute = storeMessage.attributes.first(where: { $0 is ReplyThreadMessageAttribute }) as? ReplyThreadMessageAttribute
        isLiked = storeMessage.isLiked
    }
}
