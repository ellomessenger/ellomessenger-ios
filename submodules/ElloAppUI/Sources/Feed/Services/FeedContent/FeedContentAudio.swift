//
//  FeedContentAudio.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import Foundation
import Postbox
import AccountContext
import ElloAppPresentationData
import ElloAppCore
import SwiftSignalKit
import Display
import UIKit
import ElloAppUIPreferences

extension FeedContentAudioItem: Hashable {
    static func == (lhs: FeedContentAudioItem, rhs: FeedContentAudioItem) -> Bool {
        lhs.message == rhs.message && lhs.media.isEqual(to: rhs.media) && lhs.peerId == rhs.peerId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(message)
        hasher.combine(media)
        hasher.combine(peerId)
    }
}

class FeedContentAudioItem {
    let message: FeedRootItem
    let media: ElloAppMediaFile
    let accountContext: AccountContext
    let presentationData: PresentationData
    let peerId: PeerId
    var controller: ViewController?
    
    init(message: FeedRootItem, media: ElloAppMediaFile, accountContext: AccountContext, presentationData: PresentationData, peerId: PeerId, controller: ViewController? = nil) {
        self.message = message
        self.media = media
        self.accountContext = accountContext
        self.presentationData = presentationData
        self.peerId = peerId
        self.controller = controller
    }
    
    func openAudio() {
        guard let messageId = message.messageId else {
            return
        }
        
        let location = ChatLocation.peer(id: peerId)
        _ = (accountContext.account.postbox.messageAtId(messageId)
             |> deliverOnMainQueue).start { [weak self] message in
            guard let message, let self, let controller else {
                return
            }
            
            let navigationController = controller.navigationController as! NavigationController
            let chatParams = OpenChatMessageParams(
                context: accountContext,
                chatLocation: location,
                chatLocationContextHolder: nil,
                message: message,
                standalone: false,
                reverseMessageGalleryOrder: true,
                navigationController: navigationController,
                dismissInput: { },
                present: {_,_ in },
                transitionNode: {_,_ in return nil },
                addToTransitionSurface: {_ in },
                openUrl: {_ in },
                openPeer: {_,_ in },
                callPeer: {_,_ in },
                enqueueMessage: {_ in },
                sendSticker: nil,
                sendEmoji: nil,
                setupTemporaryHiddenMedia: {_,_,_ in },
                chatAvatarHiddenMedia: {_,_ in })
            
            _ = accountContext.sharedContext.openChatMessage(chatParams)
        }
    }
    
    func arguments(completionHandler: @escaping (ChatMessageInteractiveFileNode.Arguments) -> Void) {
        guard let messageId = message.messageId else {
            return
        }
        
        let accountPeerSignal = accountContext.account.postbox.loadedPeerWithId(accountContext.account.peerId) |> take(1)
        let messageIdSignal = accountContext.account.postbox.messageAtId(messageId)
        _ = (combineLatest(queue: .mainQueue(), accountPeerSignal, messageIdSignal)
             |> deliverOnMainQueue).start { [weak self] accountPeer, message in
            guard let message, let self else {
                return
            }
            
            let chatMessageAssociatedData = ChatMessageItemAssociatedData(
                automaticDownloadPeerType: .channel,
                automaticDownloadNetworkType: .cellular,
                isRecentActions: false,
                availableReactions: nil,
                defaultReaction: nil,
                isPremium: false,
                accountPeer: EnginePeer(accountPeer)
            )
            
            let arguments = ChatMessageInteractiveFileNode.Arguments(
                context: accountContext,
                presentationData: ChatPresentationData(presentationData: presentationData),
                message: message,
                topMessage: message,
                associatedData: chatMessageAssociatedData,
                chatLocation: ChatLocation.peer(id: peerId),
                attributes: ChatMessageEntryAttributes(),
                isPinned: false,
                forcedIsEdited: false,
                file: media,
                automaticDownload: true,
                incoming: true,
                isRecentActions: false,
                forcedResourceStatus: nil,
                dateAndStatusType: nil,
                displayReactions: false,
                messageSelection: nil,
                layoutConstants: ChatMessageItemLayoutConstants.default,
                constrainedSize: CGSize(width: 100, height: 100),
                controllerInteraction: chatControllerInteraction()
            )
            completionHandler(arguments)
        }
    }
    
    func getPlaylist() -> PeerMessagesMediaPlaylist? {
        guard let messageId = message.messageId else {
            return nil
        }
        
        let location = PeerMessagesPlaylistLocation.messages(chatLocation: .peer(id: message.id.peerId), tagMask: .music, at: messageId)
        return PeerMessagesMediaPlaylist(
            context: accountContext,
            location: location,
            chatLocationContextHolder: Atomic<ChatLocationContextHolder?>(value: nil)
        )
    }
    
    func setPlaylist(playlist: PeerMessagesMediaPlaylist) {
        accountContext.sharedContext.mediaManager.setPlaylist(
            (accountContext.account, playlist),
            type: .music,
            control: SharedMediaPlayerControlAction.playback(.play)
        )
    }
    
    func chatControllerInteraction() -> ChatControllerInteraction {
        ChatControllerInteraction(
            openMessage: { message, _ in
                //            if let openMessageImpl = openMessageImpl {
                //                return openMessageImpl(message.id)
                //            } else {
                return false
                //            }
            }, openPeer: { _, _, _, _, _ in
            }, openPeerMention: { _ in
            }, openMessageContextMenu: { _, _, _, _, _, _ in
            }, openMessageReactionContextMenu: { _, _, _, _ in
            }, updateMessageReaction: { _, _ in
            }, activateMessagePinch: { _ in
            }, openMessageContextActions: { _, _, _, _ in
            }, navigateToMessage: { _, _ in
            }, navigateToMessageStandalone: { _ in
            }, tapMessage: nil, clickThroughMessage: {
            }, toggleMessagesSelection: { _, _ in
            }, sendCurrentMessage: { _ in
            }, sendMessage: { _ in
            }, sendSticker: { _, _, _, _, _, _, _, _, _ in
                return false
            }, sendEmoji: { _, _ in
            }, sendGif: { _, _, _, _, _ in
                return false
            }, sendBotContextResultAsGif: { _, _, _, _, _ in
                return false
            }, requestMessageActionCallback: { _, _, _, _ in
            }, requestMessageActionUrlAuth: { _, _ in
            }, activateSwitchInline: { _, _ in
            }, openUrl: { _, _, _, _ in
            }, shareCurrentLocation: {
            }, shareAccountContact: {
            }, sendBotCommand: { _, _ in
            }, openInstantPage: { _, _ in
            }, openWallpaper: { _ in
            }, openTheme: {_ in
            }, openHashtag: { _, _ in
            }, updateInputState: { _ in
            }, updateInputMode: { _ in
            }, openMessageShareMenu: { _ in
            }, presentController: { _, _ in
            }, presentControllerInCurrent: { _, _ in
            }, navigationController: {
                return nil
            }, chatControllerNode: {
                return nil
            }, presentGlobalOverlayController: { _, _ in
            }, callPeer: { _, _ in
            }, longTap: { _, _ in
            }, openCheckoutOrReceipt: { _ in
            }, openSearch: {
            }, setupReply: { _ in
            }, canSetupReply: { _ in
                return .none
            }, navigateToFirstDateMessage: { _, _ in
            }, requestRedeliveryOfFailedMessages: { _ in
            }, addContact: { _ in
            }, rateCall: { _, _, _ in
            }, requestSelectMessagePollOptions: { _, _ in
            }, requestOpenMessagePollResults: { _, _ in
            }, openAppStorePage: {
            }, displayMessageTooltip: { _, _, _, _ in
            }, seekToTimecode: { _, _, _ in
            }, scheduleCurrentMessage: {
            }, sendScheduledMessagesNow: { _ in
            }, editScheduledMessagesTime: { _ in
            }, performTextSelectionAction: { _, _, _ in
            }, displayImportedMessageTooltip: { _ in
            }, displaySwipeToReplyHint: {
            }, dismissReplyMarkupMessage: { _ in
            }, openMessagePollResults: { _, _ in
            }, openPollCreation: { _ in
            }, displayPollSolution: { _, _ in
            }, displayPsa: { _, _ in
            }, displayDiceTooltip: { _ in
            }, animateDiceSuccess: { _, _ in
            }, displayPremiumStickerTooltip: { _, _ in
            }, openPeerContextMenu: { _, _, _, _, _ in
            }, openMessageReplies: { _, _, _ in
            }, openReplyThreadOriginalMessage: { _ in
            }, openMessageStats: { _ in
            }, editMessageMedia: { _, _ in
            }, copyText: { _ in
            }, displayUndo: { _ in
            }, isAnimatingMessage: { _ in
                return false
            }, getMessageTransitionNode: {
                return nil
            }, updateChoosingSticker: { _ in
            }, commitEmojiInteraction: { _, _, _, _ in
            }, openLargeEmojiInfo: { _, _, _ in
            }, openJoinLink: { _ in
            }, openWebView: { _, _, _, _ in
            }, requestMessageUpdate: { _ in
            }, cancelInteractiveKeyboardGestures: {
            }, dismissTextInput: {
            },
            automaticMediaDownloadSettings: MediaAutoDownloadSettings.defaultSettings,
            pollActionState: ChatInterfacePollActionState(),
            stickerSettings: ChatInterfaceStickerSettings(loopAnimatedStickers: false),
            presentationContext: ChatPresentationContext(context: accountContext, backgroundNode: nil)
        )
    }
}
