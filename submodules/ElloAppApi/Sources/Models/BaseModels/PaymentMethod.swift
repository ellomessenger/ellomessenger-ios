//
//  PaymentMethod.swift
//  _idx_ElloAppApi_5257747F_ios_min14.0
//
//

import Foundation

public enum PaymentMethod: String {
    case unknown
    case apple
    case paypal
    case stripe
    case elloCard = "ello_card"
    case elloEarnCard = "ello_earn_card"
    
}

extension PaymentMethod {
    public var balance: String {
        switch self {
        case .paypal, .stripe, .elloCard, .apple, .unknown:
            return "transactionDetails.myBalance"
        case .elloEarnCard:
            return "transactionDetails.myEarnings"
        }
    }
}

extension PaymentMethod: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringForRawValues = try container.decode(String.self)
        switch stringForRawValues {
        case PaymentMethod.paypal.rawValue:
            self = .paypal
        case PaymentMethod.stripe.rawValue:
            self = .stripe
        case PaymentMethod.elloCard.rawValue:
            self = .elloCard
        case PaymentMethod.elloEarnCard.rawValue:
            self = .elloEarnCard
        case PaymentMethod.apple.rawValue:
            self = .apple
        default:
            self = .unknown
        }
    }
}

extension PaymentMethod: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .paypal:
            try container.encode(PaymentMethod.paypal)
        case .stripe:
            try container.encode(PaymentMethod.stripe)
        case .elloCard:
            try container.encode(PaymentMethod.elloCard)
        case .elloEarnCard:
            try container.encode(PaymentMethod.elloEarnCard)
        case .apple:
            try container.encode(PaymentMethod.apple)
        case .unknown:
            try container.encode(PaymentMethod.unknown)
        }
    }
}
