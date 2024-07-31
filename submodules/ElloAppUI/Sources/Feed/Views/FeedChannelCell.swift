//
//  FeedChannelCell.swift
//  _idx_ELFeedUI_26FB37DA_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppCore
import AvatarNode

class FeedChannelCell: UITableViewCell {
    // MARK: - Public
    var channel: FeedChannel? {
        didSet {
            setupData()
        }
    }
    var onChange: EventClosure<(channelId: Int, enabled: Bool)>?
    
    // MARK: - Private
    
    @IBOutlet private weak var avatarIV: UIImageView!
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var descriptionL: UILabel?
    
    @IBOutlet private weak var payedV: UIImageView!
    @IBOutlet private weak var adultV: UIView?
    @IBOutlet private weak var mutedV: UIView?
    @IBOutlet private weak var activeSwitch: UISwitch!
    
    let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 14.0))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarIV.addSubnode(avatarNode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarNode.frame = avatarIV.bounds
    }
    
    private func setupData() {
        guard let channel else {
            return
        }
        
        titleL?.text = channel.title
        descriptionL?.text = channel.description
        activeSwitch.isOn = channel.isActive
//        payedV?.isHidden = !channel.isPayed
        adultV?.isHidden = !channel.channel.isAdult
        mutedV?.isHidden = !channel.isMuted
        
        configurePaidIcon()
    }
    
    private func configurePaidIcon() {
        guard let channel = channel?.channel else { return }
        
        switch channel.payType {
        case .free:
            payedV.image = nil
        case .onlineCourse:
            payedV.image = UIImage(named: "Chat List/PaidChannel/OnlineCourseIcon")
        case .subscription:
            payedV.image = UIImage(named: "Chat List/PaidChannel/SubscriptionIcon")
        }
        
        payedV.isHidden = payedV.image == nil
    }
}

// MARK: - Actions

extension FeedChannelCell {
    
    @IBAction private func switchDidChange(_ sender: UISwitch) {
        guard let channel else {
            return
        }
        
        onChange?((channel.id, sender.isOn))
    }
}
