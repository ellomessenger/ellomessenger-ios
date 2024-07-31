//
//  WalletTransaction.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

public struct WalletTransactions: MTProtoResponse {
    @DecodableDefault.EmptyList
    public var transactions: [WalletTransaction]
}

public struct WalletTransaction: MTProtoResponse {
    public let transaction: TransactionItem
    public var serviceImage: String?
    public var serviceName: String?
    public let payment: Payment?
}

public struct TransactionItem: MTProtoResponse {
    public let id: Int
    public let uuid: String
    public let status: TransactionStatus?
    public let peerType: PeerType?
    public let peerId: Int
    public let amount: Double
    public var fee: Double?
    public let currency: String
    @DecodableDefault.EmptyString
    public var description: String
    public let type: PaymentType
    public let paymentMethod: PaymentMethod
    public var operationBalance: Double
    public let createdAt: Int
    public var createdAtFormatted: String
    public var paymentSystemFee: Double?
    public var payerId:Int?
    public var fromWalletId:Int?
    public var toWalletId:Int?
    public var referral:Referral?
}

public struct Payment: MTProtoResponse {
    public let id: Int
    public let assetName: String
    public let assetSymbol: String
    public let amount: Double
    public let fee: Double
    public let status: String
    public let type: PaymentType
    public let createdAt: Int
    public let walletId: String
    public let currency: String
    public let paymentMethod: PaymentMethod
    public let to: String
    public let paymentServiceFee: Double
}

public struct Referral: MTProtoResponse {
    public let id: Int
    public let username: String?
    public let firstName: String?
    public let lastName: String?
    public let accessHash: String?
}

//[{"transaction":
//    {
//    "id":230,
//    "uuid":"8c6e4dd4743eb190bf8ccb2bf90cf7c2",
//    "status":"completed",
//    "peer_type":2,
//    "peer_id":185,
//    "amount":10,
//    "fee":0,
//    "currency":"usd",
//    "description":"",
//    "type":"deposit",
//    "payment_method":"paypal",
//    "created_at_formatted":"August 23, 23",
//    "created_at":1692750418,
//    "payer_id":136907842,
//    "from_wallet_id":0,
//    "to_wallet_id":103,
//    "operation_balance":2008,
//    "payment_system_fee":"0"
//    },
//    "service_image":"",
//    "service_name":"paypal"
//},
// {"transaction":{"id":227,"uuid":"0e820da8b8fcbf289ad7cdabc25c68ba","status":"processing","peer_type":2,"peer_id":183,"amount":1020,"fee":0,"currency":"usd","description":"","type":"deposit","payment_method":"stripe","created_at_formatted":"August 22, 23","created_at":1692710300,"payer_id":136907842,"from_wallet_id":0,"to_wallet_id":103,"operation_balance":978,"payment_system_fee":"0"},"service_image":"","service_name":"stripe"},{"transaction":{"id":224,"uuid":"af764cbc4f208ca900e9f4b478315fd8","status":"completed","peer_

//{"transaction":
//    {
//    "id":236,
//    "uuid":"32ca8e1dcd5fd4f2a5912e06c6c2b269",
//    "status":"completed",
//    "peer_type":0,
//    "peer_id":1073742006,
//    "amount":11.99,
//    "fee":0.01,
//    "currency":"usd",
//    "description":"",
//    "type":"deposit",
//    "payment_method":"ello_earn_card",
//    "created_at_formatted":"August 23, 23",
//    "created_at":1692793591,
//    "payer_id":136907857,
//    "from_wallet_id":115,
//    "to_wallet_id":24,
//    "operation_balance":0,
//    "payment_system_fee":""
//    },
//    "service_image":"
//    {
//        \"predicate_name\": \"photo\"}",
//        "service_name":"Andy20SubscriptCh"
//    }
