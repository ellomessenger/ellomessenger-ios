//
//  TransactionDetailsCollectionViewCell.swift
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

class TransactionDetailsCollectionViewCell: UICollectionViewCell, UICollectionViewCellDiffable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var coinsImageView: UIImageView!
    
    var transaction: TransactionItem?
    var requestService: RequestService?
    
    private let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 11.0))
    private var peerId: Int = 0
    
    func configure(item: AnyHashable) {
        guard let item = item as? TransactionDetailsItem else { return }
        descriptionImageView.isHidden = true
        imageView.image = UIImage(named: item.iconName, in: Bundle(for: Self.self), with: nil)
        titleLabel.text = item.title
        descriptionLabel.text = item.value
        coinsImageView.isHidden = true
        
        switch item {
        case .channel:
            configureIcon(with: item)
        case .balance, .commission:
//            coinsImageView.isHidden = false
            fallthrough
        default:
            descriptionImageView.isHidden = true
            avatarNode.isHidden = true
        }
    }
    
    private func configureIcon(with item: TransactionDetailsItem) {
        guard let transactionItem = transaction else { return }
        self.peerId = transactionItem.peerId
        
        if (.channelsSubscription == transactionItem.peerType) {
            guard let requestService else { return }
            
            _ = (requestService.accountContext.account.postbox.transaction { transaction -> Peer? in
                let peerId = PeerId(
                    namespace: Namespaces.Peer.CloudChannel,
                    id: PeerId.Id._internalFromInt64Value(Int64(transactionItem.peerId))
                )
                
                return transaction.getPeer(peerId)
                
            } |> deliverOnMainQueue).start { [weak self, peerId] channel in
                guard self?.peerId == peerId else { return }
                self?.configureSmallImageView(with: channel)
            }
        }
    }

    private func configureSmallImageView(with peer: Peer?) {
        if let peer, let requestService {
            avatarNode.isHidden = false
            descriptionImageView.isHidden = false
            avatarNode.setPeer(
                context: requestService.accountContext,
                peer: EnginePeer(peer)
            )
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionImageView.superview?.addSubnode(avatarNode)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarNode.frame = .init(origin: .zero, size: .init(width: 20, height: 20))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        descriptionImageView.isHidden = true
        avatarNode.isHidden = true
    }
}
