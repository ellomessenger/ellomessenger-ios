//
//  EarnWalletItem.swift
//  _idx_ElloAppApi_EF16B6E7_ios_min14.0
//
//  Created by MacBookAir on 13.06.2023.
//

import Foundation

public struct EarnWalletItems: MTProtoResponse {
    @DecodableDefault.EmptyList
    public var items: [EarnWalletItem]
}

public struct EarnWalletItem: MTProtoResponse {
    @DecodableDefault.ZeroDouble
    public var availableBalance: Double
    
    @DecodableDefault.ZeroDouble
    public var freezeBalance: Double
    
    @DecodableDefault.ZeroDouble
    public var totalBalance: Double
}
