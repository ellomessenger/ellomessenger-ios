//
//  SubscriptionChannelView.swift
//  _idx_ELProfileUI_41162252_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppApi
import AccountContext
import AvatarNode
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppPresentationData

class SubscriptionChannelCell: UITableViewCell {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceValueLabel: UILabel!
    @IBOutlet private weak var statusStackView: UIStackView!
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var validTillLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    private var subscriptionItem: PaidSubscriptionItem?
    internal var context: AccountContext?
    
    private var menuItems: [UIAction] {
        guard let subscriptionItem else { return [] }
        
        let image = subscriptionItem.isActive
        ? UIImage(systemName: "xmark.circle")
        : UIImage(
            named: "Subscriptions/menu-subscribe",
            in: Bundle(for: Self.self),
            compatibleWith: nil
        )
        let title = subscriptionItem.isActive ? "CancelSubscription".localized : "Subscribe".localized
        return [
            UIAction(
                title: title,
                image: image
            ) { [weak self] _ in
                self?.onMenuTapHandle?(subscriptionItem)
            }
        ]
    }
    
    var onMenuTapHandle: EventClosure<PaidSubscriptionItem>?
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
    }
    
    // MARK: - Additional Methods
    func subscriptionItem(_ subscriptionItem: PaidSubscriptionItem, context: AccountContext?) {
        self.subscriptionItem = subscriptionItem
        self.context = context
        
        avatarImageView?.image = UIImage(
            named: "Subscriptions/avatar-placeholder",
            in: Bundle(for: Self.self),
            compatibleWith: nil
        )
        
        statusStackView.backgroundColor = subscriptionItem.isActive
        ? UIColor(named: "Green", in: Bundle(for: Self.self), compatibleWith: nil)
        : UIColor(named: "Gray", in: Bundle(for: Self.self), compatibleWith: nil)
        
        statusImageView.image = subscriptionItem.isActive
        ? UIImage(systemName: "checkmark.circle.fill")
        : UIImage(systemName: "xmark.circle.fill")
        
        statusLabel.text = subscriptionItem.isActive
        ? "Active".localized
        : "Cancelled".localized
        
        priceValueLabel?.text = subscriptionItem.amount.stringFinanceFormatWithDollar
        if let expireAt = subscriptionItem.expireAt {
            let date = Date(timeIntervalSince1970: TimeInterval(expireAt))
            validTillLabel.text = date.stringWithFormat(.MMMddyyyy)
        } else {
            validTillLabel.text = "Indefinite".localized
        }
        
        updateAsyncData()
        configureButtonMenu()
    }
    
    private func updateAsyncData() {
        guard let context else { return }
        guard let subscriptionItem else { return }
        
        _ = (context.account.postbox.transaction { transaction -> ElloAppChannel? in
            let peerId = PeerId(
                namespace: Namespaces.Peer.CloudChannel,
                id: PeerId.Id._internalFromInt64Value(Int64(subscriptionItem.peerId))
            )
            
            return transaction.getPeer(peerId) as? ElloAppChannel
        }
             |> deliverOnMainQueue
        ).start(next: { [weak self] peer in
            guard let peer else {
                self?.nameLabel?.text = "DELETED"
                
                return
            }
            guard let context = self?.context else { return }
            
            self?.nameLabel?.text = peer.title
            let avatarNode = AvatarNode(font: UIFont())
            _ = avatarNode.imageNode.ready.start { [peerId = subscriptionItem.peerId, weak self] _ in
                guard peerId == self?.subscriptionItem?.peerId else { return }
                
                if avatarNode.unroundedImage != nil {
                    self?.avatarImageView.image = avatarNode.unroundedImage
                }
            }
            
            avatarNode.setPeer(context: context, theme: defaultPresentationTheme, peer: EnginePeer(peer), clipStyle: .none)
        })
    }
    
    private func configureButtonMenu() {
        actionButton.menu = UIMenu(children: menuItems)
        actionButton.showsMenuAsPrimaryAction = true
    }
}

// MARK: - New configuration 
extension SubscriptionChannelCell {
    func subscriptionItem(_ subscriptionItem: AccountInfoViewController.PayedSubscription, context: AccountContext?) {
        self.context = context
        
        avatarImageView?.image = UIImage(
            named: "Subscriptions/avatar-placeholder",
            in: Bundle(for: Self.self),
            compatibleWith: nil
        )
        
        statusStackView.backgroundColor = subscriptionItem.isActive
        ? UIColor(named: "Green", in: Bundle(for: Self.self), compatibleWith: nil)
        : UIColor(named: "Gray", in: Bundle(for: Self.self), compatibleWith: nil)
        
        statusImageView.image = subscriptionItem.isActive
        ? UIImage(systemName: "checkmark.circle.fill")
        : UIImage(systemName: "xmark.circle.fill")
        
        statusLabel.text = subscriptionItem.isActive
        ? "Active".localized
        : "Cancelled".localized
        
        priceValueLabel?.text = String(format: "%ld", subscriptionItem.price)
        if let expireAt = subscriptionItem.endDate {
            let date = Date(timeIntervalSince1970: TimeInterval(expireAt / 1000))
            validTillLabel.text = date.stringWithFormat(.MMMddyyyy)
        } else {
            validTillLabel.text = "Indefinite".localized
        }
        nameLabel.text = subscriptionItem.title
        actionButton.isHidden = true
        getImage(subscriptionItem)
    }
    
    func getImage(_ item: AccountInfoViewController.PayedSubscription) {
        guard let context else { return }
        
        _ = (context.account.postbox.transaction { transaction -> ElloAppChannel? in
            let peerId = item.peerId
            
            return transaction.getPeer(peerId) as? ElloAppChannel
        }
             |> deliverOnMainQueue
        ).start(next: { [weak self] peer in
            
            guard let peer else { return }
            guard let context = self?.context else { return }
            
            let avatarNode = AvatarNode(font: UIFont())
            _ = avatarNode.imageNode.ready.start { [peerId = item.peerId, weak self] _ in
                guard peerId == item.peerId else { return }
                
                if avatarNode.unroundedImage != nil {
                    self?.avatarImageView.image = avatarNode.unroundedImage
                }
            }
            
            avatarNode.setPeer(context: context, theme: defaultPresentationTheme, peer: EnginePeer(peer), clipStyle: .none)
        })
    }
}
