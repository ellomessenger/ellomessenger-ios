//
//  WalletCardCollectionViewCell.swift
//  _idx_ELProfileUI_7F7B2F0B_ios_min14.0
//
//

import UIKit
import ELBase
import ElloAppApi

class WalletCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var paymentProcessingImageView: UIImageView!
    @IBOutlet var walletBackgroundImageView: UIImageView!
    
    //MARK: - Earning wallet
    @IBOutlet var avalableBalanceStackView: UIStackView!
    @IBOutlet var availableBalanceLabel: UILabel!
    @IBOutlet var onHoldBalanceLabel: UILabel!
    @IBOutlet var cardTypeLabel: UILabel!
    
    func configure(item: Api.wallet.WalletItem) {
        cardTypeLabel.text = if item.type.isMain {
            "Wallets.MainWallet".localized
        } else {
            "Wallets.BusinessWallet".localized
        }
        avalableBalanceStackView.isHidden = item.type == .main
        
        balanceLabel.text = String(format: "%.2f", item.amount)
        
        if item.type == .earning {
            let image = UIImage(named: "Wallet/earn_Bacground", in: Bundle(for: Self.self), compatibleWith: nil)
            walletBackgroundImageView.image = image
            availableBalanceLabel.text = String(format: "%.2f", item.amount)
            onHoldBalanceLabel.text = String(format: "%.2f", item.freezeAmount)
        } else {
            let image = UIImage(named: "Wallet/card_bacground", in: Bundle(for: Self.self), compatibleWith: nil)
            walletBackgroundImageView.image = image
        }
    }
}
