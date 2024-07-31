//
//  FeedContentPhoto.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import UIKit
import AccountContext
import Display
import ElloAppCore
import Postbox
import SwiftSignalKit

extension FeedContentPhotoItem: Hashable {
    static func == (lhs: FeedContentPhotoItem, rhs: FeedContentPhotoItem) -> Bool {
        lhs.media.isEqual(to: rhs.media)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(media.id)
    }
}

class FeedContentPhotoItem {
    private let defaultSize = CGSize(width: 128, height: 128)
    
    let message: FeedRootItem
    let media: Media
    let accountContext: AccountContext
    var controller: ViewController?
    
    init(message: FeedRootItem, media: Media, accountContext: AccountContext, controller: ViewController? = nil) {
        self.message = message
        self.media = media
        self.accountContext = accountContext
        self.controller = controller
    }
    
    func arguments() -> TransformImageArguments {
        let mediaSize = size(for: media)
        var corners = ImageCorners()
        if let media = media as? ElloAppMediaFile, media.isInstantVideo {
            corners = ImageCorners(radius: mediaSize.width / 2)
        }
        return TransformImageArguments(
            corners: corners,
            imageSize: mediaSize,
            boundingSize: mediaSize,
            intrinsicInsets: UIEdgeInsets()
        )
    }
    
    private func size(for media: Media?) -> CGSize {
        guard let media else {
            return defaultSize
        }
        
        var pixelDemensions: PixelDimensions?
        switch media {
        case let media as ElloAppMediaImage:
            pixelDemensions = largestImageRepresentation(media.representations)?.dimensions
        case let media as ElloAppMediaFile:
            pixelDemensions = media.dimensions
        default:
            return defaultSize
        }
        
        let mediaSize = pixelDemensions?.cgSize ?? defaultSize
        return mediaSize
    }
    
    func openFile() {
        guard let messageId = message.messageId else {
            return
        }
        
        _ = (accountContext.account.postbox.messageAtId(messageId)
             |> deliverOnMainQueue).start { [weak self] message in
            guard let message, let self, let controller else {
                return
            }
            
            let navigationController = controller.navigationController as! NavigationController
            let chatParams = OpenChatMessageParams(
                context: accountContext,
                chatLocation: nil,
                chatLocationContextHolder: nil,
                message: message,
                standalone: false,
                reverseMessageGalleryOrder: false,
                navigationController: navigationController,
                dismissInput: { },
                present: { [weak self] c, a in
                    self?.controller?.present(c, in: .window(.root), with: a, blockInteraction: true)
                },
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

            let status = accountContext.sharedContext.openChatMessage(chatParams)
            debugPrint(status)
        }
    }
}
