//
//  WalletsItem.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

public struct WalletsItem: MTProtoResponse {
    @DecodableDefault.EmptyList
    public var wallets: [Api.wallet.WalletItem]
}
