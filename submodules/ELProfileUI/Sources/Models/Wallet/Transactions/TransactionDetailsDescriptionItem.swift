//
//  TransactionDetailsDescriptionItem.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import Foundation

struct TransactionDetailsDescriptionItem: Hashable {
    let status: TransactionDetailsDescriptionItemStatus
    let date: String
    let currency: String
    let amount: Double
    
    var iconName: String { status.iconName }
    var paymentStatusTitle: String { status.paymentStatusTitle }
    var colorName: String { status.colorName }
}

enum TransactionDetailsDescriptionItemStatus: Hashable {
    case approved
    case pending
    case rejected(reason: String)
    
    fileprivate var iconName: String {
        switch self {
        case .approved:
            return "Wallet/approved"
        case .pending:
            return "Wallet/pending"
        case .rejected:
            return "Wallet/rejected"
        }
    }
    
    fileprivate var paymentStatusTitle: String {
        switch self {
        case .approved:
            return "transactionDetails.approved".localized
        case .pending:
            return "transactionDetails.pending".localized
        case .rejected:
            return "transactionDetails.rejected".localized
        }
    }
    
    fileprivate var colorName: String {
        switch self {
        case .approved:
            return "Green"
        case .pending:
            return "Yellow"
        case .rejected:
            return "Red"
        }
    }
}
