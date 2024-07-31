//
//  SubscriptionInfoItem.swift
//  _idx_ElloAppApi_E681992B_ios_min14.0
//
//

import Foundation

public struct AISubscriptionInfoItem: MTProtoResponse {
    public let easyMode: Bool
    @DecodableDefault.ZeroInt
    public var textTotal: Int
    let textExpireAt: Int?
    let textSubActive: Bool?
    @DecodableDefault.ZeroInt
    public var imgTotal: Int
    let imgExpireAt: Int?
    let imgSubActive: Bool?
    @DecodableDefault.ZeroInt
    public var state: Int
}
