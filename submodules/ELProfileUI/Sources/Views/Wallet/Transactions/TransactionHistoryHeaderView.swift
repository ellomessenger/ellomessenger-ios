//
//  TransactionHistoryHeaderView.swift
//  _idx_ELProfileUI_F5FB5BFD_ios_min14.0
//
//

import UIKit

class TransactionHistoryHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: TransactionHistoryHeaderView.self)
    
    static var nib: UINib {
        return UINib(
            nibName: String(describing: TransactionHistoryHeaderView.self),
            bundle: Bundle(for: TransactionHistoryHeaderView.self)
        )
    }
    
    @IBOutlet var titleLabel: UILabel!
    
}
