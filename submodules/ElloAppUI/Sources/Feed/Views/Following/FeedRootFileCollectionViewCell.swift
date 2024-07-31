//
//  FeedRootFileCollectionViewCell.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import UIKit
import AccountContext

class FeedRootFileCollectionViewCell: UICollectionViewCell {
    @IBOutlet var fileContainerView: UIView!
    
    private let audioNode = ChatMessageInteractiveFileNode()
    private var arguments: FeedContentFileItem?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fileContainerView.addSubnode(audioNode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        
        audioNode.frame = CGRect(
            x: 0,
            y: 4,
            width: fileContainerView.bounds.width,
            height: fileContainerView.bounds.height - 8
        )
        
        updateImageNodeSize()
    }
    
    // MARK: - Additional Methods
    func configure(with feedType: FeedContentManager.FeedType) {
        guard case .file(let arguments) = feedType else {
            return
        }
        self.arguments = arguments
        
        audioNode.activateLocalContent = {
//            guard let playlist = arguments.getPlaylist() else {
//                return
//            }
            
//            arguments.setPlaylist(playlist: playlist)
            arguments.openFile()
        }
    }
    
    private func updateImageNodeSize() {
        arguments?.arguments { [weak self] arguments in
            guard let self else {
                return
            }
            
            self.audioNode.asyncLayout()(arguments)
                .1(fileContainerView.frame.size)
                .1(fileContainerView.bounds.width)
                .1(true, .None, nil)
        }
    }
}
