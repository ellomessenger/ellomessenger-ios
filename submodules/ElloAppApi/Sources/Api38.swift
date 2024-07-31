//
//  Api37.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public extension Api.ai {
    typealias AIResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    internal static var aiService: AIService {
        AIService()
    }
    
    static func subscriptionInfo(_ botId:Int? = nil) -> AIResponse<AISubscriptionInfoItem> {
        aiService.subscriptionInfo(botId)
    }
    
    static func startChatBot() -> AIResponse<AISubscriptionInfoItem> {
        aiService.startChatBot()
    }
    
    static func stoptChatBot() -> AIResponse<AISubscriptionInfoItem> {
        aiService.stoptChatBot()
    }
    
    static func changeMode(easyMode: Bool) -> AIResponse<AISubscriptionInfoItem> {
        aiService.changeMode(easyMode: easyMode)
    }
    
    static func subscribe(subscriptionType: Int, quantity: Int) -> AIResponse<AISubscriptionInfoItem> {
        aiService.subscribe(subscriptionType: subscriptionType, quantity: quantity)
    }
    
    static func unsubscribe(subscriptionType: Int) -> AIResponse<AISubscriptionInfoItem> {
        aiService.unsubscribe(subscriptionType: subscriptionType)
    }
    
    static func subscribeAIP(subscriptionType: Int, quantity: Int, amount: Float, payload: String)-> AIResponse<AISubscriptionInfoItem> {
        aiService.subscribeAIP(subscriptionType: subscriptionType, quantity: quantity, amount: amount, payload: payload)
    }
    
    static func getAllBots() -> AIResponse<AIGetAllBotsItem> {
        aiService.getAllBots()
    }
}
