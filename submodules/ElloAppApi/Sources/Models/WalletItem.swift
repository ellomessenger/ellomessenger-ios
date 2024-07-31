//
//  WalletItem.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

extension Api.wallet {
    public struct WalletItem: MTProtoResponse {
        public var id: Int
        @DecodableDefault.EmptyString
        public var assetName: String
        @DecodableDefault.EmptyString
        public var assetSymbol: String
        public var type: WalletType
        @DecodableDefault.ZeroDouble
        public var amount: Double
        @DecodableDefault.ZeroDouble
        public var freezeAmount: Double
    }
}
