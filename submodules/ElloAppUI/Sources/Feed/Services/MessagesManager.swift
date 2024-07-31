//
//  MessagesManager.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import UIKit
import ElloAppApi
import ElloAppCore
import Postbox

extension ElloAppChannel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension StoreMessage: Hashable {
    public static func == (lhs: StoreMessage, rhs: StoreMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class MessagesManager {
    private var feeds: Api.Feeds = .feedMessages(messages: [], chats: [])
    
    private var chatsOrGroups: [ElloAppChannel] = [] {
        didSet {
//            debugPrint(chatsOrGroups)
        }
    }
    
   private  var storeMessages: [StoreMessage] = [] {
        didSet {
//            debugPrint(storeMessages)
        }
    }
    
    func loadMessages(postbox: Postbox?) {
        _ = postbox?.transaction { [weak self] transaction in
            guard let self else {
                return
            }
            
            storeMessages.forEach { storeMessage in
                switch storeMessage.id {
                case .Id(let messageId):
                    if !transaction.messageExists(id: messageId) {
                        _ = transaction.addMessages([storeMessage], location: .Random)
                    }
                default:
                    _ = transaction.addMessages([storeMessage], location: .Random)
                }
            }
        }.start()
    }
    
    func feedItems(from feed: Api.Feeds) -> [FeedRootItem] {
        switch feed {
        case .feedMessages(messages: let messages, chats: let chats):
            let history = FeedHistory()
            chatsOrGroups = chats.compactMap { history.parse(chat: $0) as? ElloAppChannel }
            storeMessages = Array(Set(messages.compactMap { history.parse(message: $0) }))
            storeMessages.removeAll(where: { $0.media.first is ElloAppMediaAction })
            
            var feedItems: [FeedRootItem] = []
            let groups = Set(storeMessages.compactMap { $0.groupingKey })
            groups.forEach { groupingKey in
                let groupedMessages = storeMessages.filter { $0.groupingKey == groupingKey }
                    .sorted(by: {
                        if case .Id(let messageId) = $0.id, case .Id(let messageId2) = $1.id {
                            return messageId.id < messageId2.id
                        }
                        
                        return true
                    })
                var feedItem: FeedRootItem?
                groupedMessages.forEach {
                    if feedItem == nil {
                        feedItem = FeedRootItem(storeMessage: $0, channel: channel(by: $0.id.peerId))
                    } else {
                        if !$0.text.isEmpty {
                            feedItem?.text = $0.text
                        }
                        feedItem?.media.append(contentsOf: $0.media)
                    }
                }
                guard let feedItem else {
                    return
                }
                
                feedItems.append(feedItem)
            }
            
            let emptyGroupMessages = storeMessages.filter { $0.groupingKey == nil }
            emptyGroupMessages.forEach {
                feedItems.append(FeedRootItem(storeMessage: $0, channel: channel(by: $0.id.peerId)))
            }
            feedItems.sort(by: {
                if let index1 = $0.storeMessage?.index, let index2 = $1.storeMessage?.index {
                    return index1 > index2
                }
                
                return $0.isPinned && $0.timestamp > $1.timestamp
                
            })
            
            
            return feedItems
        }
    }
    
    func channel(by peerId: PeerId) -> ElloAppChannel? {
        chatsOrGroups.first(where: { $0.id == peerId })
    }
}

extension StoreMessage {
    var views: Int {
        (attributes.first(where: { $0 is ViewCountMessageAttribute }) as? ViewCountMessageAttribute)?.count ?? 0
    }
    
    var reactions: Int {
        (attributes.first(where: { $0 is ReactionsMessageAttribute }) as? ReactionsMessageAttribute)?.reactions.count ?? 0
    }
}
