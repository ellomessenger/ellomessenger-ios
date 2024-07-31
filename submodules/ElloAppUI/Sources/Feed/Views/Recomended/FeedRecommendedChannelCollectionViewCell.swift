//
//  FeedRecommendedChannelCollectionViewCell.swift
//  ElloAppUI
//
//

import UIKit
import ElloAppCore
import AvatarNode
import AccountContext
import ElloAppCore
import Postbox

class FeedRecommendedChannelCollectionViewCell: UICollectionViewCell {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var channelTypeIconImageView: UIImageView!
    @IBOutlet var adultIconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var subscribersLabel: UILabel!
    @IBOutlet var subscribeButton: UIButton!
    @IBOutlet var verifiedImageView: UIImageView!
    
    @IBAction func subscribeButtonTapped(_ sender: UIButton) {
    }
    
    let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 16.0))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.addSubnode(avatarNode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarNode.frame = avatarImageView.bounds
    }
    
    func configure(with item: AnyHashable, context: AccountContext?) {
        guard let item = item as? FoundPeer else { return }
        
        nameLabel.text = item.peer.debugDisplayTitle
        subscribersLabel.text = String(item.subscribers ?? 0) + " subscribers"
        if let context {
            avatarNode.setPeer(context: context, peer: EnginePeer(item.peer))
        }
        if let channel = item.peer as? ElloAppChannel {
            configurePayIcon(for: channel.payType)
            adultIconImageView.isHidden = !channel.isAdult
        } else {
            channelTypeIconImageView.isHidden = true
            adultIconImageView.isHidden = true
        }
        verifiedImageView.isHidden = !item.peer.isVerified
    }
    
    private func configurePayIcon(for payType: ElloAppChannelPayType) {
        switch payType {
        case .free:
            channelTypeIconImageView.isHidden = true
        case .onlineCourse:
            channelTypeIconImageView.isHidden = false
            channelTypeIconImageView.image = UIImage(named: "Chat List/PaidChannel/OnlineCourseIcon")
        case .subscription:
            channelTypeIconImageView.isHidden = false
            channelTypeIconImageView.image = UIImage(named: "Chat List/PaidChannel/SubscriptionIcon")
        }
    }
}
