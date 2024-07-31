//
//  FeedRootMapCollectionViewCell.swift
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

class FeedRootMapCollectionViewCell: UICollectionViewCell {
    let imageNode = TransformImageNode()
    var feedContentPhotoItem: FeedContentMapItem?
    
    @IBOutlet var mapContainerView: UIView!
    @IBOutlet var addressLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapContainerView.addSubview(imageNode.view)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageNode.frame = mapContainerView.bounds
        
        updateImageNodeSize()
    }
    
    // MARK: - Additional Methods
    func configure(with feedType: FeedContentManager.FeedType) {
        guard case .map(let signal, let arguments) = feedType else {
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
        arguments.getAddress { [weak self] address in
            self?.addressLabel.text = address
        }
    }
    
    private func updateImageNodeSize() {
        guard let feedContentPhotoItem else {
            return
        }
        
        imageNode.asyncLayout()(feedContentPhotoItem.arguments())()
    }
}
