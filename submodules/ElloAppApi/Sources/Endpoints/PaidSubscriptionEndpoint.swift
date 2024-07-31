//
//  PaidSubscriptionEndpoint.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public enum PaidSubscriptionFilterType: Int {
    case active
    case cancelled
    case all
}

public enum PaidSubscriptionEndpoint {
    case subscriptions(filterType: PaidSubscriptionFilterType)
    case subscribe(peerId: Int, peerType: Int)
    case unsubscribe(peerId: Int, peerType: Int)
}

extension PaidSubscriptionEndpoint: Endpoint {
    public var service: MTProtoService {
        .paidSubscription
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .subscriptions:
            return PaidSubscriptionMethod.subscriptions
        case .subscribe:
            return PaidSubscriptionMethod.subscribe
        case .unsubscribe:
            return PaidSubscriptionMethod.unsubscribe
        }
    }
    
    public var data: [String : Any] {
        switch self {
        case let .subscriptions(filterType):
            return ["filter_type": filterType.rawValue]
        case let .subscribe(peerId, peerType):
            return ["peer_id": peerId, "peer_type": peerType]
        case let .unsubscribe(peerId, peerType):
            return ["peer_id": peerId, "peer_type": peerType]
        }
    }
}
