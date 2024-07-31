//
//  TransactionDetailsTitleItem.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import Foundation
import ElloAppApi

struct TransactionDetailsTitleItem: Hashable {
    let title: String?
    let transactionType: TransactionDetailsTitleItemType
    
    var iconName: String { transactionType.iconName }
    var paymentTypeTitle: String { transactionType.paymentTypeTitle }
    var colorName: String { transactionType.colorName }
}

enum TransactionDetailsTitleItemType: Hashable {
    case subscriptionChannelFee(OperationType)
    case withdrawal
    case deposit
    case mediaSale
    case aiTextPacks
    case aiImagePacks
    case apple
    case onlineCourseFee(OperationType)
    case transfer(OperationType)
    case referralComission
    case referralBonus
    case aiImageTextPacks
    
    enum OperationType: String {
        case income
        case expenses
    }
    
    fileprivate var iconName: String {
        switch self {
        case .onlineCourseFee(let operationType):
            "Wallet/transaction_history-online_course-\(operationType.rawValue)"
        case .subscriptionChannelFee(let operationType):
            "Wallet/transaction_history-subscription_channel-\(operationType.rawValue)"
        case .withdrawal:
            "Wallet/transaction_history-withdraw"
        case .deposit:
            "Wallet/transaction_history-deposit"
        case .mediaSale:
            "Wallet/transaction_history-media"
        case .aiTextPacks, .aiImagePacks, .aiImageTextPacks:
            "Wallet/transaction_history-ai"
        case .apple:
            "Wallet/transaction_history-deposit"
        case .transfer(let operationType):
            switch operationType {
            case .income:
                "Wallet/transaction_history-deposit"
            case .expenses:
                "Wallet/transaction_history-withdraw"
            }
        case .referralComission:
            "Wallet/transaction_history-referral"
        case .referralBonus:
            "Wallet/transaction_history-referral"
        }
    }
    
    fileprivate var paymentTypeTitle: String {
        switch self {
        case .onlineCourseFee:
            return "transactionDetails.mySubscriptionCourse".localized
        case .subscriptionChannelFee:
            return "transactionDetails.subscriptionFee".localized
        case .withdrawal:
            return "transactionDetails.withdrawal".localized
        case .deposit:
            return "transactionDetails.deposit".localized
        case .mediaSale:
            return "transactionDetails.mediaSale".localized
        case .aiTextPacks, .aiImagePacks, .aiImageTextPacks:
            return "transactionDetails.aiBot".localized
        case .apple:
            return "transactionDetails.deposit".localized
        case .transfer(let operationType):
            switch operationType {
            case .income:
                return "transactionDetails.deposit".localized
            case .expenses:
                return "transactionDetails.withdrawal".localized
            }
        case .referralComission:
            return "transactionDetails.referral".localized
        case .referralBonus:
            return "transactionDetails.referral".localized
        }
    }
    
    fileprivate var colorName: String {
        switch self {
        case .onlineCourseFee(let operationType), .subscriptionChannelFee(let operationType), .transfer(let operationType):
            operationType == .income ? "Green" : "Red"
        case .deposit, .apple, .referralBonus, .referralComission:
            "Green"
        case .mediaSale:
            "Yellow"
        case .aiTextPacks, .aiImagePacks, .aiImageTextPacks:
            "BorderBlue"
        case .withdrawal:
            "Red"
        }
    }
    
    var walletType: WalletType {
        switch self {
        case .subscriptionChannelFee(let operationType):
            switch operationType {
            case .income:
                return .earning
            case .expenses:
                return .main
            }
        case .withdrawal:
            return .earning
        case .deposit:
            return .main
        case .mediaSale:
            return .main
        case .aiTextPacks, .aiImagePacks, .aiImageTextPacks:
            return .main
        case .apple:
            return .main
        case .onlineCourseFee(let operationType):
            switch operationType {
            case .income:
                return .earning
            case .expenses:
                return .main
            }
        case .transfer(let operationType):
            switch operationType {
            case .income:
                return .main
            case .expenses:
                return .earning
            }
        case .referralComission:
            return .main
        case .referralBonus:
            return .main
        }
    }
}
