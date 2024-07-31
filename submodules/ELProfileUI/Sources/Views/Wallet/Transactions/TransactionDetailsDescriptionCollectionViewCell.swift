//
//  TransactionDetailsDescriptionCollectionViewCell.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import UIKit

class TransactionDetailsDescriptionCollectionViewCell: UICollectionViewCell, UICollectionViewCellDiffable {
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var descriptionContainerView: UIView!
    @IBOutlet var rejectDescriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    func configure(item: AnyHashable) {
        guard let item = item as? TransactionDetailsDescriptionItem else { return }
        
        statusImageView.image = UIImage(
            named: item.iconName,
            in: Bundle(for: Self.self),
            with: nil
        )
        statusLabel.text = item.paymentStatusTitle
        if case let .rejected(reason: reason) = item.status  {
            descriptionContainerView.isHidden = false
            rejectDescriptionLabel.text = reason.isEmpty ? "Wallets.Rejected".localized : reason
        } else {
            descriptionContainerView.isHidden = true
        }

        dateLabel.text = item.date
        amountLabel.text = item.amount.stringFinanceFormat
        statusLabel.textColor = UIColor(
            named: item.colorName,
            in: Bundle(for: Self.self),
            compatibleWith: nil
        )
    }
}
