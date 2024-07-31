//
//  PaidSubscriptionService.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

struct PaidSubscriptionService: MTProtoClient {
    func subscriptions(filterType: PaidSubscriptionFilterType) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<PaidSubscriptionItems>) {
        sendRequest(endpoint: PaidSubscriptionEndpoint.subscriptions(filterType: filterType))
    }
    
    func subscribe(peerId: Int, peerType: Int) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<PaidSubscriptionItem>) {
        sendRequest(endpoint: PaidSubscriptionEndpoint.subscribe(peerId: peerId, peerType: peerType))
    }
    
    func unsubscribe(peerId: Int, peerType: Int) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<PaidSubscriptionItem>) {
        sendRequest(endpoint: PaidSubscriptionEndpoint.unsubscribe(peerId: peerId, peerType: peerType))
    }
}
