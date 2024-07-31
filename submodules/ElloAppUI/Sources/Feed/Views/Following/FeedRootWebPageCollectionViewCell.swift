//
//  FeedRootMediaCollectionViewCell.swift
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

class FeedRootWebPageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    
    var imageNode = TransformImageNode()
    var media: Media?
    var feedContentPhotoItem: FeedContentPhotoItem?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageNode.imageUpdated = { [weak self] image in
            guard let image else {
                return
            }
            
            self?.imageView.backgroundColor = averageColor(from: image)
            self?.imageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageNode.reset()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageNode.frame = imageView.bounds
        
        guard let imageSize = feedContentPhotoItem?.arguments().imageSize else { return }
            
        imageViewHeightConstraint.constant = imageSize.fittedToWidthOrSmaller(imageView.bounds.width).height
        
        updateImageNodeSize()
    }
    
    // MARK: - Additional Methods
    func configure(with arguments: FeedContentWebPageItem, feedType: FeedContentManager.FeedType?) {
        if case let .image(signal: signal, arguments: imageArguments) = feedType {
            feedContentPhotoItem = imageArguments
            media = imageArguments.media
            imageNode.setSignal(signal)
        }
        
        titleLabel?.text = arguments.media.title
        subtitleLabel?.text = arguments.media.text
        
        layoutIfNeeded()
    }
    
    private func updateImageNodeSize() {
        guard let feedContentPhotoItem else {
            return
        }
        
        imageNode.asyncLayout()(feedContentPhotoItem.arguments())()
    }
}
