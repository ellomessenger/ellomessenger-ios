//
//  WalletInAppPurchaseCoinsResponse.swift
//  ELProfileUI
//
//

import Foundation

public struct WalletInAppPurchaseCoinsResponse: MTProtoResponse {
    public let status: String
    public let currency: String
    public let amount: Double
    public let paymentId: Int
}
