//
//  TransactionCell.swift
//  _idx_ELProfileUI_41162252_ios_min11.0
//
//

import UIKit
import ELBase

class TransactionCell: UITableViewCell {
    
    // MARK: - Public
    
    var transaction: Transaction?
    { didSet{ setupData() }}
    
    // MARK: - Private
    
    @IBOutlet private weak var avatarIV: UIImageView?
    @IBOutlet private weak var nameL: UILabel?
    @IBOutlet private weak var statusIcon: UIImageView?
    @IBOutlet private weak var statusL: UILabel?
    
    @IBOutlet private weak var totalAmountTitleL: UILabel?
    @IBOutlet private weak var totalAmountValueL: UILabel?
    
    @IBOutlet private weak var commissionsTitleL: UILabel?
    @IBOutlet private weak var commissionsValueL: UILabel?

    @IBOutlet private weak var receivedAmountTitleL: UILabel?
    @IBOutlet private weak var receivedAmountDateL: UILabel?

    @IBOutlet private weak var withdrawRequestedTitleL: UILabel?
    @IBOutlet private weak var withdrawRequestedDateL: UILabel?

    @IBOutlet private weak var paymentTitleL: UILabel?
    @IBOutlet private weak var paymentDateL: UILabel?

    @IBOutlet private weak var transferTitleL: UILabel?
    @IBOutlet private weak var transferDateL: UILabel?
    
    private func localize() {
        totalAmountTitleL?.text = Localization.totalAmount.localized(Bundle(for: Self.self))
        commissionsTitleL?.text = Localization.commissions.localized(Bundle(for: Self.self))
        receivedAmountTitleL?.text = Localization.receivedAmount.localized(Bundle(for: Self.self))
        withdrawRequestedTitleL?.text = Localization.withdrawalRequest.localized(Bundle(for: Self.self))
        paymentTitleL?.text = Localization.paymentMethod.localized(Bundle(for: Self.self))
        transferTitleL?.text = Localization.transfer.localized(Bundle(for: Self.self))
    }
    
    private func setupData() {
        localize()
        
        if let image = transaction?.owner.avatar {
            avatarIV?.image = image
        } else {
            avatarIV?.image = UIImage(named: "avatar", in: Bundle(for: Self.self), compatibleWith: nil)
        }
        nameL?.text = transaction?.owner.name
        statusIcon?.image = transaction?.state.icon
        statusL?.text = transaction?.state.localized(Bundle(for: Self.self))
        statusL?.textColor = transaction?.state.color
        
        totalAmountValueL?.text = "\(transaction?.totalAmount ?? 0)"
        commissionsValueL?.text = "\(transaction?.commissions ?? 0)"
        receivedAmountDateL?.text = transaction?.amountReceivedDate.stringWithFormat(.MMMddyyyy)
        withdrawRequestedDateL?.text = transaction?.withdrawRequestedDate.stringWithFormat(.MMMddyyyy)
        paymentDateL?.text = transaction?.paymentDate.stringWithFormat(.MMMddyyyy)
        transferDateL?.text = transaction?.transferedDate.stringWithFormat(.MMMddyyyy)
    }
}

extension Transaction.State {
    var icon: UIImage? {
        return UIImage(named: self.rawValue, in: Bundle(for: TransactionCell.self), compatibleWith: nil)
    }
    
    var title: String {
        return self.localized(Bundle(for: TransactionCell.self))
    }
    
    var color: UIColor {
        switch self {
            case .approved: return UIColor(rgb: 0x27ae60)
            case .rejected: return UIColor(rgb: 0xef4062)
            case .pending: return UIColor(rgb: 0xe0a147)
        }
    }
}

private enum Localization: String {
    case totalAmount
    case receivedAmount
    case paymentMethod
    case commissions
    case withdrawalRequest
    case transfer
}
