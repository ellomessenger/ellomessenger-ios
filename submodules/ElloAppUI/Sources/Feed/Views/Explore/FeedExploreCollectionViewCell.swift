//
//  FeedExploreCollectionViewCell.swift
//  ElloAppUI
//
//

import UIKit
import AccountContext
import Postbox
import DirectMediaImageCache
import SwiftSignalKit
import ElloAppCore
import ElloAppStringFormatting

class FeedExploreCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var durationLabel: UILabel!
    
    var cache: DirectMediaImageCache?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func configure(with storeMessage: StoreMessage, context: AccountContext) {
        cache = DirectMediaImageCache(account: context.account)
        guard case let .Id(messageId) = storeMessage.id else {
            return
        }
        
//        _ = context.engine.messages.getMessagesLoadIfNecessary([messageId], strategy: .cloud(skipLocal: false)).start(next: { messages in
//            print(messages)
//        })
//        _ = context.engine.messages.downloadMessage(messageId: messageId).start(next: { message in
//            print(message)
//        })
        
        let messageIdSignal = context.account.postbox.messageAtId(messageId)
        _ = (messageIdSignal |> deliverOnMainQueue).start(next: { [weak self] message in
            guard let self else { return }
            guard let message else { return }
            guard let media = message.media.first else { return }
            
            if let media = media as? ElloAppMediaFile, let duration = media.duration {
                durationLabel.superview?.isHidden = false
                durationLabel.text = stringForDuration(duration)
            } else {
                durationLabel.superview?.isHidden = true
            }
            
            let result = self.cache?.getImage(
                message: message,
                media: message.media.first!,
                width: Int(UIScreen.main.bounds.width),
                possibleWidths: [Int(UIScreen.main.bounds.width)],
                synchronous: false
            )
            
            if let image = result?.image {
                self.imageView.image = image
            }
            
            if let signal = result?.loadSignal {
                _ = (signal |> deliverOnMainQueue).start(next: { image in
                    self.imageView.image = image
                })
            }
        })
    }
}
