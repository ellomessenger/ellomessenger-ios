//
//  WalletInternalTransferPayment.swift
//  ElloAppApi
//
//  Created by Oleksii Zabrodin on 21.12.2023.
//

import Foundation

public struct WalletInternalTransferPayment: MTProtoResponse {
    public var amount: Double
    public var amountFiat: Double
    public var fee: Double
    public var transferMax: Double
    public var transferMin: Double
}
