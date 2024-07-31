//
//  FeedRootLiveMapCollectionViewCell.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import UIKit
import ElloAppApi
import ElloAppCore
import AvatarNode
import AccountContext
import ElloAppPresentationData
import Postbox
import Display
import SwiftSignalKit
import LiveLocationTimerNode

class FeedRootLiveMapCollectionViewCell: UICollectionViewCell {
    let imageNode = TransformImageNode()
    let timerNode = ChatMessageLiveLocationTimerNode()
    var feedContentPhotoItem: FeedContentLiveMapItem?
    
    @IBOutlet var mapContainerView: UIView!
    @IBOutlet var timerContainerView: UIView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageNode.contentMode = .scaleAspectFill
        mapContainerView.addSubview(imageNode.view)
        timerContainerView.addSubview(timerNode.view)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()
        
        imageNode.frame = mapContainerView.bounds
        timerNode.frame = timerContainerView.bounds
        
        updateImageNodeSize()
    }
    
    // MARK: - Additional Methods
    func configure(with feedType: FeedContentManager.FeedType) {
        guard case .liveMap(let signal, let arguments) = feedType else {
            return
        }
        
        self.feedContentPhotoItem = arguments
        imageNode.imageUpdated = { [weak self] image in
            guard let image else {
                return
            }
            self?.imageNode.backgroundColor = averageColor(from: image)
        }
        imageNode.setSignal(signal)
        
        guard let feedContentPhotoItem else {
            return
        }
        
        let beginTimestamp = Double(feedContentPhotoItem.message.timestamp)
        let timeout = Double(feedContentPhotoItem.media.liveBroadcastingTimeout ?? 0)
        timerNode.update(
            backgroundColor: .clear,
            foregroundColor: UIColor(hex: 0x0A49A5),
            textColor: UIColor(hex: 0x0A49A5),
            beginTimestamp: beginTimestamp,
            timeout: timeout,
            strings: feedContentPhotoItem.presentationData.strings
        )
    }
    
    private func updateImageNodeSize() {
        guard let feedContentPhotoItem else {
            return
        }
        
        imageNode.asyncLayout()(feedContentPhotoItem.arguments())()
    }
}
