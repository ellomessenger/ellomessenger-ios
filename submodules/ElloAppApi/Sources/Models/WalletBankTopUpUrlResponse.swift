//
//  WalletBankTopUpUrlResponse.swift
//  ElloAppApi
//
//

import Foundation

public struct WalletBankTopUpUrlResponse: MTProtoResponse {
    var status: String
    @DecodableDefault.EmptyString
    var currency: String
    var amount: Double
    public var link: String
}
