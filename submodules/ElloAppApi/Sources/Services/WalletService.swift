//
//  WalletService.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

protocol WalletServiceable {
    typealias WalletsResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    func createWallet(assetId: Int) -> WalletsResponse<Api.wallet.WalletItem>
    func userWallet(assetId: Int) -> WalletsResponse<Api.wallet.WalletItem>
    func userWallets(assetId: Int) -> WalletsResponse<WalletsItem>
    func bankTopUpUrl(assetId: Int, walletId: Int, currency: String, amount: Double) -> WalletsResponse<WalletBankTopUpUrlResponse>
    func processApplePayment(amount: Double, payload: String) -> WalletsResponse<WalletInAppPurchaseCoinsResponse>
    func internalTransferPayment(fromWalletId: Int, toWalletId: Int, amount:Double, currency:String?, message:String?) -> WalletsResponse<WalletInternalTransferPayment>
}

struct WalletService: MTProtoClient, WalletServiceable {
    func createWallet(assetId: Int) -> WalletsResponse<Api.wallet.WalletItem> {
        sendRequest(endpoint: WalletEnpoint.createWallet(assetId: assetId))
    }
    
    func userWallet(assetId: Int) -> WalletsResponse<Api.wallet.WalletItem> {
        sendRequest(endpoint: WalletEnpoint.userWallet(assetId: assetId))
    }
    
    func userWallets(assetId: Int) -> WalletsResponse<WalletsItem> {
        sendRequest(endpoint: WalletEnpoint.userWallets(assetId: assetId))
    }
    
    func bankTopUpUrl(assetId: Int, walletId: Int, currency: String, amount: Double) -> WalletsResponse<WalletBankTopUpUrlResponse> {
        sendRequest(endpoint: WalletEnpoint.bankTopUpUrl(assetId: assetId, walletId: walletId, currency: currency, amount: amount))
    }
    
    func processApplePayment(amount: Double, payload: String) -> WalletsResponse<WalletInAppPurchaseCoinsResponse> {
        sendRequest(endpoint: WalletEnpoint.processApplePayment(amount: amount, payload: payload))
    }
    
    func internalTransferPayment(fromWalletId: Int, toWalletId: Int, amount:Double, currency:String?, message:String?) -> WalletsResponse<WalletInternalTransferPayment> {
        sendRequest(endpoint: WalletEnpoint.internalTransferPayment(fromWalletId: fromWalletId, toWalletId: toWalletId, amount: amount, currency: currency, message: message))
    }
}
