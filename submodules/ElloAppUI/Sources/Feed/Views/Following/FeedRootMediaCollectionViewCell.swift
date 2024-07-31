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

class FeedRootMediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
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
        
        updateImageNodeSize()
    }
    
    // MARK: - Additional Methods
    func configure(with feedType: FeedContentManager.FeedType, media: Media?) {
        guard case .image(let signal, let arguments) = feedType else {
            return
        }
        
        self.feedContentPhotoItem = arguments
        self.media = media
        imageNode.setSignal(signal)
    }
    
    private func updateImageNodeSize() {
        guard let feedContentPhotoItem else {
            return
        }
        
        imageNode.asyncLayout()(feedContentPhotoItem.arguments())()
    }
}

class FeedRootVideoCollectionViewCell: FeedRootMediaCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageNode.contentMode = .scaleAspectFit
        
        let imageView = UIImageView(image: UIImage(named: "feed_play"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor)
        ])
    }
    
    override func configure(with feedType: FeedContentManager.FeedType, media: Media?) {
        guard case .video(let signal, let arguments) = feedType else {
            return
        }
        
        self.feedContentPhotoItem = arguments
        self.media = media
        
        imageNode.setSignal(signal)
    }
}
