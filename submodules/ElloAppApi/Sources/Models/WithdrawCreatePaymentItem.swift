//
//  WithdrawCreatePaymentItem.swift
//  _idx_ElloAppApi_BAD889E7_ios_min14.0
//

import Foundation

public struct WithdrawCreatePaymentItem: MTProtoResponse {
    @DecodableDefault.ZeroDouble
    public var amount: Double
    @DecodableDefault.ZeroDouble
    public var amountFiat: Double
    @DecodableDefault.ZeroDouble
    public var fee: Double
    @DecodableDefault.ZeroDouble
    public var paymentSystemFee: Double
    @DecodableDefault.ZeroDouble
    public var withdrawMax: Double
    @DecodableDefault.ZeroDouble
    public var withdrawMin: Double
    @DecodableDefault.EmptyString
    public var status: String
    @DecodableDefault.EmptyString
    public var paypalEmail: String
    @DecodableDefault.EmptyString
    public var paymentId: String
    public var bankWithdrawRequisitesId: Int?
}

