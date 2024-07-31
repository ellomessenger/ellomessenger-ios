//
//  TransactionDetailsTitleCollectionViewCell.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import UIKit
import AvatarNode
import ELBase
import ElloAppApi
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppPresentationData


protocol UICollectionViewCellDiffable: UICollectionViewCell {
    func configure(item: AnyHashable)
}

class TransactionDetailsTitleCollectionViewCell: UICollectionViewCell, UICollectionViewCellDiffable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var paymentTypeLabel: UILabel!
    
    var transaction: TransactionItem?
    var requestService: RequestService?
    
    private let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 11.0))
    private var peerId: Int = 0
    
    func configure(item: AnyHashable) {
        guard let item = item as? TransactionDetailsTitleItem else { return }
        
        imageView.image = UIImage(named: item.iconName, in: Bundle(for: Self.self), with: nil)
        titleLabel.text = item.title
        paymentTypeLabel.text = item.paymentTypeTitle
        paymentTypeLabel.superview?.backgroundColor = UIColor(named: item.colorName, in: Bundle(for: Self.self), compatibleWith: nil)
        configureIcon(with: item)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleImageView.superview?.addSubnode(avatarNode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        avatarNode.frame = .init(origin: .zero, size: .init(width: 20, height: 20))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleImageView.image = nil
        titleImageView.superview?.backgroundColor = .white
        
    }
    

    private func configureIcon(with item: TransactionDetailsTitleItem) {
        guard let transactionItem = transaction else { return }
        self.peerId = transactionItem.peerId
        
        if (transactionItem.peerType != .depositOrWithdrawal) {
            guard let requestService else { return }
            
            _ = (requestService.accountContext.account.postbox.transaction { transaction -> Peer? in
                let peerId = PeerId(
                    namespace: Namespaces.Peer.CloudChannel,
                    id: PeerId.Id._internalFromInt64Value(Int64(transactionItem.peerId))
                )
                
                return transaction.getPeer(peerId)
                
            } |> deliverOnMainQueue).start { [weak self, peerId] channel in
                guard self?.peerId == peerId else { return }
                self?.configureSmallImageView(with: channel, transaction: transactionItem)
                
                guard let channel = channel as? ElloAppChannel else {
                    if (self?.titleLabel.text ?? "").isEmpty {
                        self?.titleLabel.text = "Unknown name"
                    }
                    
                    return
                }
                
                if (self?.titleLabel.text ?? "").isEmpty {
                    self?.titleLabel.text = channel.title
                }
            }
        } else {
            configureSmallImageView(with: nil, transaction: transactionItem)
        }
    }

    private func configureSmallImageView(with peer: Peer?, transaction: TransactionItem) {
        if let peer, let requestService {
            avatarNode.isHidden = false
            titleImageView.isHidden = false
            titleImageView.superview?.isHidden = false
            avatarNode.setPeer(
                context: requestService.accountContext,
                theme: defaultPresentationTheme,
                peer: EnginePeer(peer)
            )
        } else {
            avatarNode.isHidden = true
            
            switch transaction.peerType {
            case .loyaltyBonus, .loyaltyComission:
                titleImageView.superview?.isHidden = true
                return
            case .aiPacks, .aiSubscription, .aiTextPacks, .aiTextSubscription:
                titleImageView.isHidden = true
                if let image = UIImage(named: "Wallet/AIText", in: Bundle(for: Self.self), with: nil) {
                    titleImageView.superview?.backgroundColor = UIColor(patternImage: image)
                }
                return
            case .aiImagePacks, .aiImageSubscription:
                titleImageView.isHidden = true
                if let image = UIImage(named: "Wallet/AIPhoto", in: Bundle(for: Self.self), with: nil) {
                    titleImageView.superview?.backgroundColor = UIColor(patternImage: image)
                }
                return
            case .aiImageTextPack:
                titleImageView.isHidden = true
                if let image = UIImage(named: "Wallet/AIPhotoText", in: Bundle(for: Self.self), with: nil) {
                    titleImageView.superview?.backgroundColor = UIColor(patternImage: image)
                }
                return
            default:
                titleImageView.isHidden = false
            }
            
            switch transaction.paymentMethod {
            case .paypal:
                titleImageView.image = UIImage(named: "Wallet/payPal", in: Bundle(for: Self.self), with: nil)
                titleImageView.superview?.backgroundColor = UIColor(
                    named: "BgGrey", in: Bundle(for: Self.self), compatibleWith: nil
                )
            case .stripe, .unknown:
                titleImageView.image = UIImage(named: "Wallet/bank", in: Bundle(for: Self.self), with: nil)
                titleImageView.superview?.backgroundColor = UIColor(
                    named: "BgGrey", in: Bundle(for: Self.self), compatibleWith: nil
                )
            case .elloCard, .elloEarnCard:
//                titleImageView.image = UIImage(named: "Wallet/ello-card", in: Bundle(for: Self.self), with: nil)
//                titleImageView.superview?.backgroundColor = .blue
                titleImageView.superview?.isHidden = true
            case .apple:
                titleImageView.superview?.isHidden = true
            }
        }
    }

}
