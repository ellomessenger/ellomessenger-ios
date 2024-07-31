//
//  TransactionHistoryTableViewCell.swift
//  _idx_ELProfileUI_F5FB5BFD_ios_min14.0
//
//

import UIKit
import ElloAppApi
import Postbox
import ElloAppCore
import SwiftSignalKit
import AvatarNode
import ElloAppPresentationData

class TransactionHistoryTableViewCell: UITableViewCell {
    @IBOutlet var bigImageView: UIImageView!
    @IBOutlet var smallImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    private var requestService: RequestService?
    private let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 11.0))
    private var peerId: Int = 0
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        smallImageView.image = nil
        smallImageView.superview?.backgroundColor = .white
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        smallImageView.superview?.addSubnode(avatarNode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        avatarNode.frame = .init(origin: .zero, size: .init(width: 20, height: 20))
    }
    
    // MARK: - Additional Methods
    func configure(item: WalletTransaction, requestService: RequestService?) {
        self.requestService = requestService
        self.peerId = item.transaction.peerId
        
        configureTitleLabel(with: item)
        configureSubtitleLabel(with: item.transaction)
        configureBigImageView(with: item.transaction)
        configureAmountLabel(with: item.transaction)
    }
    
    private func configureBigImageView(with transaction: TransactionItem) {
        bigImageView.image = switch transaction.type {
        case .all, .transfer:
            switch transaction.peerType {
            case .aiPacks, .aiSubscription, .aiImagePacks, .aiImageSubscription, .aiTextPacks, .aiTextSubscription, .aiImageTextPack:
                UIImage(named: "Wallet/transaction_history-ai", in: Bundle(for: Self.self), with: nil)
            default:
                if transaction.amount >= 0 {
                    UIImage(named: "Wallet/transaction_history-deposit", in: Bundle(for: Self.self), with: nil)
                } else {
                    UIImage(named: "Wallet/transaction_history-withdraw", in: Bundle(for: Self.self), with: nil)
                }
            }
        case .deposit:
            switch transaction.peerType {
            case .channelsSubscription:
                UIImage(named: "Wallet/transaction_history-subscription_channel-income", in: Bundle(for: Self.self), with: nil)
            case .courseSubscription:
                UIImage(named: "Wallet/transaction_history-online_course-income", in: Bundle(for: Self.self), with: nil)
            case .depositOrWithdrawal, .none:
                UIImage(named: "Wallet/transaction_history-deposit", in: Bundle(for: Self.self), with: nil)
            case .mediaPurchase, .aiPacks, .aiSubscription, .transfer, .aiImagePacks, .aiImageSubscription, .aiTextPacks, .aiTextSubscription, .aiImageTextPack:
                UIImage(named: "Wallet/transaction_history-ai", in: Bundle(for: Self.self), with: nil)
            case .loyaltyComission:
                UIImage(named: "Wallet/transaction_history-referral", in: Bundle(for: Self.self), with: nil)
            case .loyaltyBonus:
                UIImage(named: "Wallet/transaction_history-referral", in: Bundle(for: Self.self), with: nil)
            }
        case .withdraw:
            switch transaction.peerType {
            case .channelsSubscription:
                UIImage(named: "Wallet/transaction_history-subscription_channel-expenses", in: Bundle(for: Self.self), with: nil)
            case .courseSubscription:
                UIImage(named: "Wallet/transaction_history-online_course-expenses", in: Bundle(for: Self.self), with: nil)
            case .depositOrWithdrawal, .none:
                UIImage(named: "Wallet/transaction_history-withdraw", in: Bundle(for: Self.self), with: nil)
            case .mediaPurchase, .aiPacks, .aiSubscription, .transfer, .aiImagePacks, .aiImageSubscription, .aiTextPacks, .aiTextSubscription, .aiImageTextPack:
                UIImage(named: "Wallet/transaction_history-ai", in: Bundle(for: Self.self), with: nil)
            case .loyaltyComission:
                UIImage(named: "Wallet/transaction_history-referral", in: Bundle(for: Self.self), with: nil)
            case .loyaltyBonus:
                UIImage(named: "Wallet/transaction_history-referral", in: Bundle(for: Self.self), with: nil)
            }
        }
    }
    
    private func configureSmallImageView(with peer: Peer?, transaction: TransactionItem, defaultText:String? = nil) {
        if let peer, let requestService {
            avatarNode.setPeer(context: requestService.accountContext, peer: EnginePeer(peer))
            avatarNode.isHidden = false
            smallImageView.isHidden = false
            smallImageView.superview?.isHidden = false
        } else {
            avatarNode.isHidden = true
            switch transaction.peerType {
            case .aiPacks, .aiSubscription, .aiTextPacks, .aiTextSubscription:
                smallImageView.isHidden = true
                if let image = UIImage(named: "Wallet/AIText", in: Bundle(for: Self.self), with: nil) {
                    smallImageView.superview?.isHidden = false
                    smallImageView.superview?.backgroundColor = UIColor(patternImage: image)
                }
                return
            case .aiImagePacks, .aiImageSubscription:
                smallImageView.isHidden = true
                if let image = UIImage(named: "Wallet/AIPhoto", in: Bundle(for: Self.self), with: nil) {
                    smallImageView.superview?.isHidden = false
                    smallImageView.superview?.backgroundColor = UIColor(patternImage: image)
                }
                return
            case .aiImageTextPack:
                smallImageView.isHidden = true
                if let image = UIImage(named: "Wallet/AIPhotoText", in: Bundle(for: Self.self), with: nil) {
                    smallImageView.superview?.isHidden = false
                    smallImageView.superview?.backgroundColor = UIColor(patternImage: image)
                }
                return
            case .loyaltyBonus, .loyaltyComission:
                avatarNode.isHidden = true
                smallImageView.isHidden = true
                smallImageView.superview?.isHidden = true
                return
            case .channelsSubscription, .courseSubscription:
                avatarNode.setCustomLetters([defaultText?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).first?.uppercased() ?? ""])
                avatarNode.isHidden = false
                smallImageView.isHidden = false
                smallImageView.superview?.isHidden = false
                return
            default:
                avatarNode.isHidden = true
                smallImageView.isHidden = false
                smallImageView.superview?.isHidden = false
            }
            
            switch transaction.paymentMethod {
            case .paypal:
                smallImageView.image = UIImage(named: "Wallet/payPal", in: Bundle(for: Self.self), with: nil)
                smallImageView.superview?.isHidden = false
                smallImageView.superview?.backgroundColor = UIColor(
                    named: "BgLightGrey", in: Bundle(for: Self.self), compatibleWith: nil
                )
            case .stripe, .unknown:
                smallImageView.image = UIImage(named: "Wallet/bank", in: Bundle(for: Self.self), with: nil)
                smallImageView.superview?.isHidden = false
                smallImageView.superview?.backgroundColor = UIColor(
                    named: "BgLightGrey", in: Bundle(for: Self.self), compatibleWith: nil
                )
            case .elloCard, .elloEarnCard:
//                smallImageView.image = UIImage(named: "Wallet/ello-card", in: Bundle(for: Self.self), with: nil)
//                smallImageView.superview?.backgroundColor = .blue
                smallImageView.superview?.isHidden = true
            case .apple:
                smallImageView.superview?.isHidden = true
            }
        }
    }
    
    private func configureAmountLabel(with transaction: TransactionItem) {
//        switch transaction.type {
//        case .transfer:
//            if transaction.amount >= 0 {
//                amountLabel.textColor = UIColor(named: "TextGreen", in: Bundle(for: Self.self), compatibleWith: nil)
//                amountLabel.text = String(format: "+%.2f", transaction.amount)
//            } else {
//                amountLabel.textColor = UIColor(named: "TextRed", in: Bundle(for: Self.self), compatibleWith: nil)
//                amountLabel.text = String(format: "%.2f", transaction.amount)
//            }
//        case .all, .deposit:
//            amountLabel.textColor = UIColor(named: "TextGreen", in: Bundle(for: Self.self), compatibleWith: nil)
//            amountLabel.text = String(format: "+%.2f", transaction.amount)
//        case .withdraw:
//            amountLabel.textColor = UIColor(named: "TextRed", in: Bundle(for: Self.self), compatibleWith: nil)
//            amountLabel.text = String(format: "%.2f", transaction.amount)
//        }
        amountLabel.text = String(format: "%+.2f", transaction.amount)
    }
    
    private func configureTitleLabel(with item: WalletTransaction) {
        if item.transaction.peerType == .transfer  {
            titleLabel.text = item.transaction.amount.isLess(than: .zero) 
            ? "Wallets.MainWallet".localized
            : "transfer".localized
            
            configureSmallImageView(with: nil, transaction: item.transaction)
            
            return
        }
        
        titleLabel.text = TopUpMethodModel(rawValue: item.serviceName ?? "")?.title.localized ?? item.serviceName?.capitalized
        titleLabel.text = switch item.transaction.peerType {
        case .aiPacks, .aiSubscription, .aiTextPacks, .aiTextSubscription:
            "transactionDetails.aiText".localized
        case .aiImagePacks, .aiImageSubscription:
            "transactionDetails.aiPhoto".localized
        case .aiImageTextPack:
            "transactionDetails.aiPhotoText".localized
        case .loyaltyBonus:
            "transactionDetails.bonus".localized
        case .loyaltyComission:
            "transactionDetails.comission".localized
        default:
            titleLabel.text
        }

        if (titleLabel.text ?? "").isEmpty || (item.transaction.peerType != .depositOrWithdrawal) {
            guard let requestService else { return }
            
            _ = (requestService.accountContext.account.postbox.transaction { transaction -> Peer? in
                let peerId = PeerId(
                    namespace: Namespaces.Peer.CloudChannel,
                    id: PeerId.Id._internalFromInt64Value(Int64(item.transaction.peerId))
                )
                
                return transaction.getPeer(peerId)
                
            } |> deliverOnMainQueue).start { [weak self, peerId] channel in
                guard self?.peerId == peerId else { return }
                self?.configureSmallImageView(with: channel, transaction: item.transaction, defaultText: item.serviceName)
                
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
            configureSmallImageView(with: nil, transaction: item.transaction)
        }
    }
    
    private func configureSubtitleLabel(with transaction: TransactionItem) {
        switch transaction.peerType {
        case .transfer:
            if transaction.amount >= 0 {
                subtitleLabel.text = "transactionDetails.deposit".localized
            } else {
                subtitleLabel.text = "transactionDetails.withdrawal".localized
            }
        case .depositOrWithdrawal, .none:
            subtitleLabel.text = if transaction.paymentMethod == .apple {
                "transactionDetails.deposit".localized
            } else {
                transaction.type.title.capitalized
            }
        case .channelsSubscription:
            switch transaction.type {
            case .deposit:
                subtitleLabel.text = "transactionDetails.mySubscriptionChannel".localized
            case .withdraw:
                subtitleLabel.text = "transactionDetails.subscriptionFee".localized
            default:
                subtitleLabel.text = transaction.type.title.capitalized
            }
        case .courseSubscription:
            switch transaction.type {
            case .deposit:
                subtitleLabel.text = "transactionDetails.mySubscriptionCourse".localized
            case .withdraw:
                subtitleLabel.text = "transactionDetails.mySubscriptionCourse".localized
            default:
                subtitleLabel.text = transaction.type.title.capitalized
            }
        case .mediaPurchase:
            subtitleLabel.text = "transactionDetails.mediaSale".localized
        case .aiPacks, .aiSubscription, .aiImagePacks, .aiImageSubscription, .aiTextPacks, .aiTextSubscription, .aiImageTextPack:
            subtitleLabel.text = "transactionDetails.aiBot".localized
        case .loyaltyComission:
            subtitleLabel.text = "transactionDetails.referral".localized
        case .loyaltyBonus:
            subtitleLabel.text = "transactionDetails.referral".localized
        }
    }
}
