//
//  TransactionDetailsItem.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import Foundation

enum TransactionDetailsItem: Hashable {
    case channel(String, icon: String = "Wallet/channel", title: String = "transactionDetails.channel".localized)
    case commission(String, icon: String = "Wallet/commission", title: String = "transactionDetails.commission".localized)
    case stripeCommission(String, icon: String = "Wallet/StripeCommission", title: String = "transactionDetails.StripeCommission".localized)
    case payPalCommission(String, icon: String = "Wallet/PayPalCommission", title: String = "transactionDetails.PayPalCommission".localized)
    case paymentMethods(String, icon: String = "Wallet/payment_method", title: String = "transactionDetails.elloBalance".localized)
    case balance(String, icon: String = "Wallet/balance", title: String = "transactionDetails.balance".localized)
    case course(String, icon: String = "Wallet/channel", title: String = "transactionDetails.onlineCourse".localized)

    var iconName: String {
        switch self {
        case .channel(_, let icon, _):
            return icon
        case .course(_, let icon, _):
            return icon
        case .paymentMethods(_, let icon, _):
            return icon
        case .stripeCommission(_, let icon, _):
            return icon
        case .payPalCommission(_, let icon, _):
            return icon
        case .balance(_, let icon, _):
            return icon
        case .commission(_, let icon, _):
            return icon
        }
    }
    
    var title: String {
        switch self {
        case .channel(_, _, let title):
            return title
        case .course(_, _, let title):
            return title
        case .paymentMethods(_, _, let title):
            return title
        case .stripeCommission(_, _, let title):
            return title
        case .payPalCommission(_, _, let title):
            return title
        case .balance(_, _, let title):
            return title
        case .commission(_, _, let title):
            return title
        }
    }
    
    var value: String {
        switch self {
        case .channel(let string, _, _):
            return string
        case .course(let string, _, _):
            return string
        case .paymentMethods(let string, _, _):
            return string
        case .stripeCommission(let string, _, _):
            return string
        case .payPalCommission(let string, _, _):
            return string
        case .balance(let string, _, _):
            return string
        case .commission(let string, _, _):
            return string
        }
    }
}
