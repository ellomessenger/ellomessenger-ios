//
//  FeedNotificationView.swift
//  _idx_ELFeedUI_26FB37DA_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppCore
import AvatarNode
import AccountContext
import Postbox
import ElloAppPresentationData

class FeedNotificationView: UIControl {
    @IBOutlet weak var stackView: UIStackView!
    
    func updateLayout(context: AccountContext, presentationData: PresentationData, channels: [Peer]) {
        let avatarsCount = min(channels.count, 3)
        stackView.arrangedSubviews.forEach { $0.isHidden = true }
        
        for index in 0..<avatarsCount {
            let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 14.0))
            avatarNode.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            avatarNode.cornerRadius = 10
            avatarNode.borderColor = UIColor.white.cgColor
            avatarNode.clipsToBounds = true
            avatarNode.borderWidth = 1
            
            let avatarContainerView = stackView.arrangedSubviews[index]
            avatarContainerView.subviews.first?.removeFromSuperview()
            avatarContainerView.layer.zPosition = CGFloat(avatarsCount - index)
            avatarContainerView.addSubview(avatarNode.view)
            avatarContainerView.isHidden = false
            
            avatarNode.setPeer(context: context, theme: presentationData.theme, peer: EnginePeer(channels[index]), clipStyle: .none)
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
}
