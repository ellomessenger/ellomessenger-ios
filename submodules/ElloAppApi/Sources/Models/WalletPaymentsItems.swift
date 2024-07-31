//
//  WalletPaymentsItems.swift
//  _idx_ElloAppApi_8DEA847F_ios_min14.0
//

import Foundation


public struct WalletPaymentsItems: MTProtoResponse {
    @DecodableDefault.EmptyList
    public var payments: [WalletPaymentsItem]
}

public struct WalletPaymentsItem: MTProtoResponse {
    public var id: Int
    @DecodableDefault.ZeroDouble
    public var amount: Double
    @DecodableDefault.EmptyString
    public var status: String
    public var paymentMethod: TopUpMethodModel
    @DecodableDefault.EmptyString
    public var paymentType: String
    @DecodableDefault.EmptyString
    public var currency: String
    @DecodableDefault.EmptyString
    public var date: String
    @DecodableDefault.EmptyString
    public var time: String
    @DecodableDefault.EmptyString
    public var to: String
}

public enum TopUpMethodModel: String, Codable {
    case payPal = "paypal"
    case bankCard = "stripe"
    case elloai = "elloai"
    case myBalance = "myBalance"
    case apple
    
    public var title: String {
        switch self {
        case .payPal:
            return "PayPal"
        case .bankCard:
            return "Withdrawal.BankTransferTitle"
        case .elloai:
            return "AI"
        case .myBalance:
            return "transactionDetails.myBalance"
        case .apple:
            return "transactionDetails.apple"
        }
    }
    
    public var icon: String {
        switch self {
        case .payPal:
            return "Wallet/payPal"
        case .bankCard:
            return "Wallet/bank-transfer"
        case .elloai:
            return "Wallet/AIText"
        case .myBalance:
            return "Wallet/myBalance_icon"
        case .apple:
            return "Wallet/myBalance_icon"
        }
    }
}
