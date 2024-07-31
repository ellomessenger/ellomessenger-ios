//
//  WithdrawApprovePaymentItem.swift
//  _idx_ElloAppApi_09CFF3AA_ios_min14.0
//
//

import Foundation

public struct WithdrawApprovePaymentItem: MTProtoResponse {
    @DecodableDefault.ZeroDouble
    public var amount: Double
    @DecodableDefault.ZeroDouble
    public var fee: Double
    @DecodableDefault.EmptyString
    public var status: String
    @DecodableDefault.EmptyString
    public var paypalEmail: String
    @DecodableDefault.EmptyString
    public var paymentId: String
}
