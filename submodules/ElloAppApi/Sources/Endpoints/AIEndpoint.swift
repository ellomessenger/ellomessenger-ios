//
//  ChannelCategoryListEndpoint.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public enum AIEndpoint {
    case subscriptionInfo(botId: Int?)
    case startChatBot
    case stoptChatBot
    case changeMode(easyMode: Bool)
    case subscribe(subscriptionType: Int, quantity: Int)
    case unsubscribe(subscriptionType: Int)
    case subscribeIAP(subscriptionType: Int, quantity: Int, amount: Float, payload: String)
    case getAllBots
}

extension AIEndpoint: Endpoint {
    public var service: MTProtoService {
        .ai
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .subscriptionInfo:
            return AIMethod.subscriptionInfo
        case .startChatBot:
            return AIMethod.startChatBot
        case .stoptChatBot:
            return AIMethod.stoptChatBot
        case .changeMode:
            return AIMethod.changeMode
        case .subscribe:
            return AIMethod.subscribe
        case .unsubscribe:
            return AIMethod.unsubscribe
        case .subscribeIAP:
            return AIMethod.subscribeIAP
        case .getAllBots:
            return AIMethod.getAllBots
        }
    }
    
    public var data: [String : Any] {
        switch self {
        case .subscriptionInfo(let botId):
            guard let botId else { return [:] }
            return ["bot_id" : botId]
        case .startChatBot:
            return [:]
        case .stoptChatBot:
            return [:]
        case let .changeMode(easyMode):
            return ["easy_mode": easyMode]
        case let .subscribe(subscriptionType, quantity):
            return ["sub_type": subscriptionType, "quantity": quantity]
        case let .unsubscribe(subscriptionType):
            return ["sub_type": subscriptionType]
        case let .subscribeIAP(subscriptionType, quantity, amount, payload):
            return ["sub_type": subscriptionType, "quantity": quantity, "amount": amount, "payload": payload]
        case .getAllBots:
            return [:]
        }
    }
    
}
