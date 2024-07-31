//
//  PaidSubscriptionItem.swift
//  _idx_ElloAppApi_CBDC00B9_ios_min14.0
//
//

import Foundation

public struct PaidSubscriptionItems: MTProtoResponse {
    @DecodableDefault.EmptyList
    public var items: [PaidSubscriptionItem]
}

public struct PaidSubscriptionItem: MTProtoResponse {
    public let userId: Int?
    public let peerId: Int
    public let peerType: Int?
    public let amount: Double
    public let currency: String
    public let expireAt: Int?
    @DecodableDefault.False
    public var isActive: Bool
}
