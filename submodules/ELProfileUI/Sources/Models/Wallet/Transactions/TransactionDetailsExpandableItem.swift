//
//  TransactionDetailsExpandableItem.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import Foundation

enum TransactionDetailsExpandableItem: Hashable {
    case purchase([String], Bool)
    
    var iconName: String {
        switch self {
        case .purchase(_, _):
            return "Wallet/purchase"
        }
    }
    
    var title: String {
        switch self {
        case .purchase(_, _):
            return "transactionDetails.purchase".localized
        }
    }
    
    var value: [String] {
        switch self {
        case .purchase(let string, _):
            return string
        }
    }
    
    var isExpanded: Bool {
        switch self {
        case .purchase(_, let isExpanded):
            return isExpanded
        }
    }
}
