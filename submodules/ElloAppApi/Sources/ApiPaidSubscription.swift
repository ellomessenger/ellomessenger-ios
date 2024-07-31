//
//  ApiPaidSubscription.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public extension Api.paidSubscription {
    typealias PaidSubscriptionResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    internal static var paidSubscriptionService: PaidSubscriptionService {
        PaidSubscriptionService()
    }
    
    static func subscriptions(filterType: PaidSubscriptionFilterType) -> PaidSubscriptionResponse<PaidSubscriptionItems> {
        paidSubscriptionService.subscriptions(filterType: filterType)
    }
    
    static func subscribe(peerId: Int, peerType: Int) -> PaidSubscriptionResponse<PaidSubscriptionItem> {
        paidSubscriptionService.subscribe(peerId: peerId, peerType: peerType)
    }
    
    static func unsubscribe(peerId: Int, peerType: Int) -> PaidSubscriptionResponse<PaidSubscriptionItem> {
        paidSubscriptionService.unsubscribe(peerId: peerId, peerType: peerType)
    }
}
