import Foundation
import SwiftSignalKit
import ElloAppApi

public enum AISubscriptionError: LocalizedError, CustomStringConvertible {
    case notEnoughCoins
    case message(String)
    
    public var description: String {
        switch self {
        case let .message(description):
            description
        case .notEnoughCoins:
            ""
        }
    }
    
    public var errorDescription: String? {
        description
    }
}

func _internal_startAIBot(account: Account) -> Signal<Never, NoError> {
    account.network.request(Api.ai.startChatBot())
    |> retryRequest
    |> mapToSignal { _ -> Signal<Never, NoError> in .complete() }
}

func _internal_stoptAIBot(account: Account) -> Signal<Never, NoError> {
    account.network.request(Api.ai.stoptChatBot())
    |> retryRequest
    |> mapToSignal { _ -> Signal<Never, NoError> in .complete() }
}

func _internal_subscriptionInfo(account: Account, botId:Int64? = nil) -> Signal<AISubscriptionInfoItem, NoError> {
    account.network.request(Api.ai.subscriptionInfo(botId?.int))
        |> retryRequest
}

func _internal_subscribe(account: Account, type: Int, quantity: Int) -> Signal<AISubscriptionInfoItem, AISubscriptionError> {
    account.network.request(Api.ai.subscribe(subscriptionType: type, quantity: quantity))
    |> mapError { error -> AISubscriptionError in
        debugPrint(error)
        return if error.errorDescription.contains("not enough money for pay transaction") {
            .notEnoughCoins
        } else {
            .message(error.errorDescription)
        }
    }
    |> deliverOnMainQueue
}


func _internal_subscribeIAP(account: Account, type: Int, quantity: Int, amount: Float, payload: String) -> Signal<AISubscriptionInfoItem, BaseError> {
    account.network.request(Api.ai.subscribeAIP(subscriptionType: type, quantity: quantity, amount: amount, payload: payload))
    |> mapError { error -> BaseError in
        debugPrint(error)
        return .message(error.errorDescription)
    }
    |> deliverOnMainQueue
}

func _internal_getAllBots(account: Account) -> Signal<AIGetAllBotsItem, NoError> {
    account.network.request(Api.ai.getAllBots())
    |> retryRequest
    |> mapToSignal { _ -> Signal<AIGetAllBotsItem, NoError> in .complete() }
}

public extension Int64 {
    var int:Int { Int(self) }
}
