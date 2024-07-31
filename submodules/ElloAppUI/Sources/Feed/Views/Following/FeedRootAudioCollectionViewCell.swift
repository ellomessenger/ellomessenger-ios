//
//  FeedRootAudioCollectionViewCell.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import UIKit
import AccountContext

class FeedRootAudioCollectionViewCell: UICollectionViewCell {
    private var audioNode: ChatMessageInteractiveFileNode?
    private var arguments: FeedContentAudioItem?
    
    @IBOutlet var playerContainerView: UIView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerContainerView.layoutIfNeeded()
        
        audioNode?.frame = CGRect(
            x: 0,
            y: 4,
            width: playerContainerView.bounds.width,
            height: playerContainerView.bounds.height - 8
        )
        
        updateImageNodeSize()
    }
    
    // MARK: - Additional Methods
    func configure(with feedType: FeedContentManager.FeedType) {
        self.audioNode = ChatMessageInteractiveFileNode()
        guard let audioNode else { return }
        
        playerContainerView.addSubnode(audioNode)
        guard case .audio(let arguments) = feedType else {
            return
        }
        self.arguments = arguments
        
        audioNode.activateLocalContent = {
//            guard let playlist = arguments.getPlaylist() else {
//                return
//            }
            
//            arguments.setPlaylist(playlist: playlist)
            arguments.openAudio()
        }
    }
    
    private func updateImageNodeSize() {
        arguments?.arguments { [weak self] arguments in
            guard let self else {
                return
            }
            
            self.audioNode?.asyncLayout()(arguments)
                .1(playerContainerView.frame.size)
                .1(playerContainerView.bounds.width)
                .1(true, .None, nil)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        audioNode?.removeFromSupernode()
        audioNode = nil
    }
}
