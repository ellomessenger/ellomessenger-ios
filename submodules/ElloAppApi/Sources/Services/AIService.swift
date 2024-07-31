//
//  WalletService.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

struct AIService: MTProtoClient {
    func subscriptionInfo(_ botId:Int?) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.subscriptionInfo(botId:botId))
    }
    
    func startChatBot() -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.startChatBot)
    }
    
    func stoptChatBot() -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.stoptChatBot)
    }
    
    func changeMode(easyMode: Bool) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.changeMode(easyMode: easyMode))
    }
    
    func subscribe(subscriptionType: Int, quantity: Int) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.subscribe(subscriptionType: subscriptionType, quantity: quantity))
    }
    
    func unsubscribe(subscriptionType: Int) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.unsubscribe(subscriptionType: subscriptionType))
    }
    
    func subscribeAIP(subscriptionType: Int, quantity: Int, amount: Float, payload: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AISubscriptionInfoItem>) {
        sendRequest(endpoint: AIEndpoint.subscribeIAP(subscriptionType: subscriptionType, quantity: quantity, amount: amount, payload: payload))
    }
    
    func getAllBots() -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AIGetAllBotsItem>) {
        sendRequest(endpoint: AIEndpoint.getAllBots)
    }
}

public struct AIGetAllBotsItem: MTProtoResponse {
    var botIds:[Int]?
}
