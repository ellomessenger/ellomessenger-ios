//
//  RequestService.swift
//  _idx_ELProfileUI_A8A1B18C_ios_min14.0
//
//

import Foundation
import AccountContext
import SwiftSignalKit
import ElloAppApi

enum CommonError: Error, LocalizedError {
    case message(String)
    
    var errorDescription: String {
        switch self {
        case let .message(value): return value
        }
    }
}

public class RequestService {
    let accountContext: AccountContext
    
    public init(accountContext: AccountContext) {
        self.accountContext = accountContext
    }
}

//MARK: - Create Wallet
extension RequestService {
    func createWallet(completionHandler: @escaping (_ walletItem: Api.wallet.WalletItem) -> Void) {
        let signal = createWalletSignal()
        
        _ = signal.start { walletItem in
            debugPrint(walletItem)
            debugPrint("walletItem")
            completionHandler(walletItem)
        } error: { error in
            debugPrint(error)
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func createWalletSignal() -> Signal<Api.wallet.WalletItem, CommonError> {
        accountContext.account.network.request(Api.wallet.createWallet(with: 2))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.wallet.WalletItem, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

// MARK: - Get Wallet
extension RequestService {
    func getWallet() {
        let signal = getWalletSignal()
        
        _ = signal.start { walletItem in
            debugPrint(walletItem)
            debugPrint("walletItem")
        } error: { error in
            debugPrint(error)
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func getWalletSignal() -> Signal<Api.wallet.WalletItem, CommonError> {
        accountContext.account.network.request(Api.wallet.getUserWallet(with: 2))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.wallet.WalletItem, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
    
    func getWallets() async throws -> [Api.wallet.WalletItem] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Api.wallet.WalletItem], Error>) in
            _ = (accountContext.account.network.request(Api.wallet.getUserWallets(with: 2))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> WalletError in .message(error.errorDescription) }
                 |> mapToSignal { result -> Signal<[Api.wallet.WalletItem], WalletError> in
                    .single(result.wallets)
            }).start { wallets in
                continuation.resume(returning: wallets)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - TopUp Wallet
extension RequestService {
    func makePayment(with paymentItem: Api.wallet.PaymentItem, completionHandler: @escaping (Result<Api.wallet.PaymentItemResponse, CommonError>) -> Void) {
        let signal = makePaymentSignal(with: paymentItem)
        
        _ = signal.start { walletItem in
            debugPrint(walletItem)
            debugPrint("walletItem")
            completionHandler(.success(walletItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makePaymentSignal(with paymentItem: Api.wallet.PaymentItem) -> Signal<Api.wallet.PaymentItemResponse, CommonError> {
        accountContext.account.network.request(Api.wallet.makePayment(with: paymentItem))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.wallet.PaymentItemResponse, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

extension RequestService {
    func transferMoneyBetweenWallets(with paymentItem: Api.wallet.TransferMoneyBetweenWalletsItem, completionHandler: @escaping (Result<Api.wallet.TransferMoneyBetweenWalletsItemResponse, CommonError>) -> Void) {
        let signal = makeTransferMoneyBetweenWalletsSignal(with: paymentItem)
        
        _ = signal.start { walletItem in
            debugPrint(walletItem)
            debugPrint("walletItem")
            completionHandler(.success(walletItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeTransferMoneyBetweenWalletsSignal(with paymentItem: Api.wallet.TransferMoneyBetweenWalletsItem) -> Signal<Api.wallet.TransferMoneyBetweenWalletsItemResponse, CommonError> {
        accountContext.account.network.request(Api.wallet.transferMoneyBetweenWallets(with: paymentItem))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.wallet.TransferMoneyBetweenWalletsItemResponse, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

// MARK: - Get PayPal URL
extension RequestService {
    func getPaypalPayment(with paymentItem: Api.wallet.PaypalPaymentItem, completionHandler: @escaping (Result<Api.wallet.PaypalPaymentItemResponse, CommonError>) -> Void) {
        let signal = makePaymentSignal(with: paymentItem)
        
        _ = signal.start { walletItem in
            completionHandler(.success(walletItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        }
    }
    
    private func makePaymentSignal(with paymentItem: Api.wallet.PaypalPaymentItem) -> Signal<Api.wallet.PaypalPaymentItemResponse, CommonError> {
        accountContext.account.network.request(Api.wallet.getPaypallPaymentUrl(with: paymentItem))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.wallet.PaypalPaymentItemResponse, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

// MARK: - Get Wallet Transactions
extension RequestService {
    func getWalletTransactions(walletId: Int, paymentType: String, search: String, dateFrom: String, dateTo: String, limit: Int, offset: Int, completionHandler: @escaping (Result<WalletTransactions, CommonError>) -> Void) {
        let signal = getWalletTransactions(walletId: walletId, paymentType: paymentType, search: search, dateFrom: dateFrom, dateTo: dateTo, limit: limit, offset: offset)
        
        _ = signal.start { walletItem in
            debugPrint(walletItem)
            debugPrint("walletItem")
            completionHandler(.success(walletItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func getWalletTransactions(walletId: Int, paymentType: String, search: String, dateFrom: String, dateTo: String, limit: Int, offset: Int) -> Signal<WalletTransactions, CommonError> {
        accountContext.account.network.request(Api.wallet.transferTransactions(with: 2, walletId: walletId, paymentType: paymentType, search: search, dateFrom: dateFrom, dateTo: dateTo, limit: limit, offset: offset))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<WalletTransactions, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

// MARK: - Get transfer page month activity statistic data for graphic
extension RequestService {
    func lastMonthActivityGraphic(walletId: Int, limit: Int, page: Int, completionHandler: @escaping (Result<MonthActivityItems, CommonError>) -> Void) {
        let signal = lastMonthActivityGraphic(walletId: walletId, limit: limit, page: page)
        
        _ = signal.start { monthActivityItems in
            debugPrint(monthActivityItems)
            debugPrint("monthActivityItems")
            completionHandler(.success(monthActivityItems))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func lastMonthActivityGraphic(walletId: Int, limit: Int, page: Int) -> Signal<MonthActivityItems, CommonError> {
        accountContext.account.network.request(Api.wallet.lastMonthActivityGraphic(with: walletId, limit: limit, page: page))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<MonthActivityItems, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
    
    func transferStatisticGraphic(walletId: Int, period: TransferStatisticGraphicItem.Period, type: TransferStatisticGraphicItem.`Type`, limit: Int, page: Int, completionHandler: @escaping (Result<TransferStatisticGraphicItems, CommonError>) -> Void) {
        let signal = transferStatisticGraphic(walletId: walletId, period: period, type: type, limit: limit, page: page)
        
        _ = signal.start { transferStatisticGraphicItem in
            debugPrint(transferStatisticGraphicItem)
            debugPrint("monthActivityItems")
            completionHandler(.success(transferStatisticGraphicItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func transferStatisticGraphic(walletId: Int, period: TransferStatisticGraphicItem.Period, type: TransferStatisticGraphicItem.`Type`, limit: Int, page: Int) -> Signal<TransferStatisticGraphicItems, CommonError> {
        
        accountContext.account.network.request(Api.wallet.transferPageStatistic(with: walletId, period: period.rawValue, type: type.rawValue, limit: limit, page: page))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<TransferStatisticGraphicItems, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

// MARK: - Get earn wallet
extension RequestService {
    func earnWalletInfo(walletId: Int, completionHandler: @escaping (Result<EarnWalletItem, CommonError>) -> Void) {
        let signal = earnWalletInfo(walletId: walletId)
        
        _ = signal.start { earnWalletInfoItem in
            debugPrint(earnWalletInfoItem)
            debugPrint("earnWalletInfo")
            completionHandler(.success(earnWalletInfoItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func earnWalletInfo(walletId: Int) -> Signal<EarnWalletItem, CommonError> {
        
        accountContext.account.network.request(Api.wallet.earnWalletInfo(with: walletId))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<EarnWalletItem, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}

// MARK: - Get wallet Payments
extension RequestService {
    func createWithdrawPayment(assetId: Int,
                               walletId: Int,
                               currency: String,
                               paypalEmail: String? = nil,
                               paymentId: String? = nil,
                               bankWithdrawRequisitesId: Int? = nil,
                               amount: Double,
                               withdrawSystem: String? = nil, 
                               completionHandler: @escaping (Result<WithdrawCreatePaymentItem, CommonError>) -> Void) {
        
        let signal = createWithdrawPayment(assetId: assetId, 
                                           walletId: walletId,
                                           currency: currency,
                                           paypalEmail: paypalEmail,
                                           paymentId: paymentId,
                                           bankWithdrawRequisitesId: bankWithdrawRequisitesId,
                                           amount: amount,
                                           withdrawSystem: withdrawSystem)
        
        _ = signal.start { withdrawCreatePaymentItem in
            debugPrint(withdrawCreatePaymentItem)
            debugPrint("withdrawCreatePaymentItem")
            completionHandler(.success(withdrawCreatePaymentItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    
    private func createWithdrawPayment(assetId: Int,
                                       walletId:Int,
                                       currency: String,
                                       paypalEmail: String? = nil,
                                       paymentId: String? = nil,
                                       bankWithdrawRequisitesId: Int? = nil,
                                       amount: Double,
                                       withdrawSystem: String? = nil) -> Signal<WithdrawCreatePaymentItem, CommonError> {
        
        accountContext.account.network.request(Api.wallet.withdrawCreatePayment(with: assetId,
                                                                                walletId: walletId,
                                                                                currency: currency,
                                                                                paypalEmail: paypalEmail,
                                                                                paymentId: paymentId,
                                                                                bankWithdrawRequisitesId: bankWithdrawRequisitesId,
                                                                                amount: amount,
                                                                                withdrawSystem: withdrawSystem))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<WithdrawCreatePaymentItem, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }

    func getBankWithdrawsRequisites(limit: Int,
                                    offset: Int,
                                    isTemplate: Bool,
                                    completionHandler: @escaping (Result<BankWithdrawsItems, CommonError>) -> Void) {
        
        let signal = getBankWithdrawsRequisites(limit: limit, offset: offset, isTemplate: isTemplate)
        
        _ = signal.start { bankWithdrawsItems in
            debugPrint(bankWithdrawsItems)
            debugPrint("bankWithdrawsItems")
            completionHandler(.success(bankWithdrawsItems))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }

    private func getBankWithdrawsRequisites(limit: Int, offset: Int, isTemplate: Bool) -> Signal<BankWithdrawsItems, CommonError> {
        accountContext.account.network.request(Api.wallet.getBankWithdrawsRequisites(limit: limit, offset: offset, isTemplate: isTemplate))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<BankWithdrawsItems, CommonError> in
            debugPrint(result)
            
            return .single(result)
        }
    }
}


// MARK: - Approve wallet withdraw
extension RequestService {
    func approveWithdrawPayment(with walletId: Int,
                                paymentId: String,
                                approveCode: String,
                                paypalEmail: String? = nil,
                                bankWithdrawRequisitesId: Int? = nil,
                                completionHandler: @escaping (Result<WithdrawApprovePaymentItem, CommonError>) -> Void) {
        
        let signal = approveWithdrawPayment(with: walletId, 
                                            paymentId: paymentId,
                                            approveCode: approveCode,
                                            paypalEmail: paypalEmail,
                                            bankWithdrawRequisitesId: bankWithdrawRequisitesId)
        
        _ = signal.start { withdrawCreatePaymentItem in
            debugPrint(withdrawCreatePaymentItem)
            debugPrint("withdrawCreatePaymentItem")
            completionHandler(.success(withdrawCreatePaymentItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    
    private func approveWithdrawPayment(with walletId: Int,
                                        paymentId: String,
                                        approveCode: String,
                                        paypalEmail: String?,
                                        bankWithdrawRequisitesId: Int?) -> Signal<WithdrawApprovePaymentItem, CommonError> {
        accountContext.account.network.request(Api.wallet.withdrawApprovePayment(with: walletId, 
                                                                                 paymentId: paymentId,
                                                                                 approveCode: approveCode,
                                                                                 paypalEmail: paypalEmail,
                                                                                 bankWithdrawRequisitesId: bankWithdrawRequisitesId))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<WithdrawApprovePaymentItem, CommonError> in
            debugPrint(result)

            return .single(result)
        }
    }
}

// MARK: - Subscriptions
extension RequestService {
    func subscriptions(_ filterType: PaidSubscriptionFilterType) async throws -> [PaidSubscriptionItem] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PaidSubscriptionItem], Error>) in
            _ = (accountContext.account.network.request(Api.paidSubscription.subscriptions(filterType: filterType))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                debugPrint(error)
                return .message(error.errorDescription)
            }).start { paidSubscriptionItems in
                continuation.resume(returning: paidSubscriptionItems.items)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func subscribe(_ peerId: Int, peerType: Int) async throws -> PaidSubscriptionItem {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PaidSubscriptionItem, Error>) in
            _ = (accountContext.account.network.request(Api.paidSubscription.subscribe(peerId: peerId, peerType: peerType))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                debugPrint(error)
                return .message(error.errorDescription)
            }).start { paidSubscriptionItem in
                continuation.resume(returning: paidSubscriptionItem)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func unsubscribe(_ peerId: Int, peerType: Int) async throws -> PaidSubscriptionItem {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PaidSubscriptionItem, Error>) in
            _ = (accountContext.account.network.request(Api.paidSubscription.unsubscribe(peerId: peerId, peerType: peerType))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                debugPrint(error)
                return .message(error.errorDescription)
            }).start { paidSubscriptionItem in
                continuation.resume(returning: paidSubscriptionItem)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
// MARK: - Create bank withdraw requisites
extension RequestService {
    func createBankWithdrawRequisites(with object: BankWithdrawalInfoObject,
                                      completionHandler: @escaping (Result<BankWithdrawRequisitesItem, CommonError>) -> Void) {
        
        let signal = createBankWithdrawRequisites(object: object)
        
        _ = signal.start { bankWithdrawRequisitesItem in
            debugPrint(bankWithdrawRequisitesItem)
            debugPrint("BankWithdrawRequisitesItem")
            completionHandler(.success(bankWithdrawRequisitesItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    
    private func createBankWithdrawRequisites(object: BankWithdrawalInfoObject) -> Signal<BankWithdrawRequisitesItem, CommonError> {
        accountContext.account.network.request(Api.wallet.createBankWithdrawRequisites(isTemplate: object.isTemplate,
                                                                                       recipientType: object.recipientType,
                                                                                       businessIdNumber: object.businessIdNumber,
                                                                                       personalFirstName: object.personalFirstName,
                                                                                       personalLastName: object.personalLastName,
                                                                                       personalPhoneNumber: object.personalPhone,
                                                                                       personalEmail: object.personalEmail, 
                                                                                       message: object.message,
                                                                                       currency: object.currency,
                                                                                       bankCountry: object.bankCountry,
                                                                                       bankRoutingNumber: object.bankRoutingNumber, 
                                                                                       bankName: object.bankName,
                                                                                       bankStreet: object.bankStreet,
                                                                                       bankCity: object.bankCity,
                                                                                       bankState: object.bankState,
                                                                                       bankSwift: object.bankSwift,
                                                                                       bankAddress: object.bankAddress,
                                                                                       bankPostalCode: object.bankPostalCode,
                                                                                       bankZipCode: object.bankZipCode,
                                                                                       bankRecipientAccountNumber: object.bankRecipientAccountNumber,
                                                                                       userAddressAddress: object.userAddressAddres,
                                                                                       userAddressStreet: object.userAddressStreet,
                                                                                       userAddressCity: object.userAddressCity,
                                                                                       userAddressState: object.userAddressState,
                                                                                       userAddressRegion: object.userAddressRegion,
                                                                                       userAddressZipCode: object.userAddressZipCode,
                                                                                       userAddressPostalCode: object.userAddressPostalCode))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<BankWithdrawRequisitesItem, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func editWithdrawTemplate(with object: BankWithdrawalInfoObject,
                        completionHandler: @escaping (Result<BankWithdrawRequisitesItem, CommonError>) -> Void) {
        
        let signal = editWithdrawTemplate(object: object)
        
        _ = signal.start { bankWithdrawRequisitesItem in
            debugPrint(bankWithdrawRequisitesItem)
            debugPrint("BankWithdrawRequisitesItem")
            completionHandler(.success(bankWithdrawRequisitesItem))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func editWithdrawTemplate(object: BankWithdrawalInfoObject) -> Signal<BankWithdrawRequisitesItem, CommonError> {
        accountContext.account.network.request(Api.wallet.editWithdrawTemplate(templateId: object.templateId,
                                                                               recipientType: object.recipientType,
                                                                               businessIdNumber: object.businessIdNumber,
                                                                               personalFirstName: object.personalFirstName,
                                                                               personalLastName: object.personalLastName,
                                                                               personalPhoneNumber: object.personalPhone,
                                                                               personalEmail: object.personalEmail,
                                                                               message: object.message,
                                                                               currency: object.currency,
                                                                               bankCountry: object.bankCountry,
                                                                               bankRoutingNumber: object.bankRoutingNumber,
                                                                               bankName: object.bankName,
                                                                               bankStreet: object.bankStreet,
                                                                               bankCity: object.bankCity,
                                                                               bankState: object.bankState,
                                                                               bankSwift: object.bankName,
                                                                               bankAddress: object.bankAddress,
                                                                               bankPostalCode: object.bankPostalCode,
                                                                               bankZipCode: object.bankZipCode,
                                                                               bankRecipientAccountNumber: object.bankRecipientAccountNumber,
                                                                               userAddressAddress: object.userAddressAddres,
                                                                               userAddressStreet: object.userAddressStreet,
                                                                               userAddressCity: object.userAddressCity,
                                                                               userAddressState: object.userAddressState,
                                                                               userAddressRegion: object.userAddressRegion,
                                                                               userAddressZipCode: object.userAddressZipCode,
                                                                               userAddressPostalCode: object.userAddressPostalCode))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<BankWithdrawRequisitesItem, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func bankTopUpUrl(assetId: Int, walletId: Int, currency: String = "USD", amount: Double) async throws -> WalletBankTopUpUrlResponse {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<WalletBankTopUpUrlResponse, Error>) in
            _ = (accountContext.account.network.request(Api.wallet.bankPaymentUrl(with: assetId, walletId: walletId, currency: currency, amount: amount))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                    .message(error.errorDescription)
            }).start { topUpUrlResponse in
                continuation.resume(returning: topUpUrlResponse)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Top Up with InAppPurchase
extension RequestService {
    /// Top Up coins with inApp Purchase
    /// - Parameters:
    ///   - amount: amount of coins to buy
    ///   - payload: inapppurchase payload
    /// - Returns: response of topup status
    func processApplePayment(amount: Double, payload: String) async throws -> WalletInAppPurchaseCoinsResponse {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<WalletInAppPurchaseCoinsResponse, Error>) in
            _ = (accountContext.account.network.request(Api.wallet.processApplePayment(amount: amount, payload: payload))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                debugPrint(error)
                return .message(error.errorDescription)
            }).start { inAppPurchaseCoinsResponse in
                continuation.resume(returning: inAppPurchaseCoinsResponse)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Internal Transfer Payment
extension RequestService {
    /// Top Up coins with inApp Purchase
    /// - Parameters:
    ///   - fromWalletId:
    ///   - toWalletId:
    ///   - amount: amount of coins to buy
    ///   - currency:
    ///   - message:
    /// - Returns: response of topup status
    func internalTransferPayment(fromWalletId: Int, toWalletId: Int, amount:Double, currency:String?, message:String?) async throws -> WalletInternalTransferPayment {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<WalletInternalTransferPayment, Error>) in
            _ = (accountContext.account.network.request(Api.wallet.internalTransferPayment(fromWalletId: fromWalletId, 
                                                                                           toWalletId: toWalletId,
                                                                                           amount: amount, 
                                                                                           currency: currency,
                                                                                           message: message))
                 |> deliverOn(.mainQueue())
                 |> mapError { error -> CommonError in
                        debugPrint(error)
                        return .message(error.errorDescription)
            }).start { internalTransferPayment in
                continuation.resume(returning: internalTransferPayment)
            } error: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}


// MARK: - Loyalty
extension RequestService {
    func makeCheckCode(with code: Api.loyalty.Code, completionHandler: @escaping (Result<Api.Bool, CommonError>) -> Void) {
        let signal = makecheckCodeSignal(with: code)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("result makeCheckCode")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makecheckCodeSignal(with code: Api.loyalty.Code) -> Signal<Api.Bool, CommonError> {
        accountContext.account.network.request(Api.loyalty.checkCode(with: code))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.Bool, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeGenCode(user_id: Int, is_business: Bool, loyalty_package_id: Int, completionHandler: @escaping (Result<Api.loyalty.Code, CommonError>) -> Void) {
        let signal = makeGenCodeSignal(user_id: user_id, is_business: is_business, loyalty_package_id: loyalty_package_id)
        
        _ = signal.start { code in
            debugPrint(code)
            debugPrint("code makeGenCode")
            completionHandler(.success(code))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGenCodeSignal(user_id: Int, is_business: Bool, loyalty_package_id: Int) -> Signal<Api.loyalty.Code, CommonError> {
        accountContext.account.network.request(Api.loyalty.genCode(user_id: user_id,
                                                                   is_business: is_business,
                                                                   loyalty_package_id: loyalty_package_id))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.Code, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeGenBonusCode(user: Api.loyalty.User, completionHandler: @escaping (Result<Api.loyalty.CodeWithPackage, CommonError>) -> Void) {
        let signal = makeGenBonusCodeSignal(user: user)
        
        _ = signal.start { code in
            debugPrint(code)
            debugPrint("code makeGenBonusCode")
            completionHandler(.success(code))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGenBonusCodeSignal(user: Api.loyalty.User) -> Signal<Api.loyalty.CodeWithPackage, CommonError> {
        accountContext.account.network.request(Api.loyalty.genBonusCode(user: user))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.CodeWithPackage, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeAppendPartnerCode(code: Api.loyalty.Code, completionHandler: @escaping (Result<Api.Bool, CommonError>) -> Void) {
        let signal = makeAppendPartnerCodeSignal(code: code)
        
        _ = signal.start { code in
            debugPrint(code)
            debugPrint("code makeAppendCode")
            completionHandler(.success(code))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeAppendPartnerCodeSignal(code: Api.loyalty.Code) -> Signal<Api.Bool, CommonError> {
        accountContext.account.network.request(Api.loyalty.appendPartnerCode(with: code))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.Bool, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeGetRefUsers(userWithPagination: Api.loyalty.UserWithPagination, completionHandler: @escaping (Result<Api.loyalty.LoyaltyUser_Vector, CommonError>) -> Void) {
        let signal = makeGetRefUsersSignal(userWithPagination: userWithPagination)
        
        _ = signal.start { code in
            debugPrint(code)
            debugPrint("code makeGetRefUsers")
            completionHandler(.success(code))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGetRefUsersSignal(userWithPagination: Api.loyalty.UserWithPagination) -> Signal<Api.loyalty.LoyaltyUser_Vector, CommonError> {
        accountContext.account.network.request(Api.loyalty.getRefUsers(with: userWithPagination))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.LoyaltyUser_Vector, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeCalcPercents(loyaltyCalcReq: Api.loyalty.LoyaltyCalcReq, completionHandler: @escaping (Result<Api.loyalty.LoyaltyCalc, CommonError>) -> Void) {
        let signal = makeCalcPercentsSignal(loyaltyCalcReq: loyaltyCalcReq)
        
        _ = signal.start { code in
            debugPrint(code)
            debugPrint("code makeCalcPercents")
            completionHandler(.success(code))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeCalcPercentsSignal(loyaltyCalcReq: Api.loyalty.LoyaltyCalcReq) -> Signal<Api.loyalty.LoyaltyCalc, CommonError> {
        accountContext.account.network.request(Api.loyalty.calcPercents(loyaltyCalcReq: loyaltyCalcReq))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.LoyaltyCalc, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeGetPackages(is_business: Bool, is_default: Bool, completionHandler: @escaping (Result<Api.loyalty.LoyaltyData_Vector, CommonError>) -> Void) {
        let signal = makeGetPackagesSignal(is_business: is_business, is_default: is_default)
        
        _ = signal.start { code in
            debugPrint(code)
            debugPrint("code makeGetPackages")
            completionHandler(.success(code))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGetPackagesSignal(is_business: Bool, is_default: Bool) -> Signal<Api.loyalty.LoyaltyData_Vector, CommonError> {
        accountContext.account.network.request(Api.loyalty.getPackages(is_business: is_business, is_default: is_default))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.LoyaltyData_Vector, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeBindUserPartner(with code: Api.loyalty.Code, completionHandler: @escaping (Result<Api.loyalty.Code, CommonError>) -> Void) {
        let signal = makeBindUserPartnerSignal(with: code)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("code makeBindUserPartner")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeBindUserPartnerSignal(with code: Api.loyalty.Code) -> Signal<Api.loyalty.Code, CommonError> {
        accountContext.account.network.request(Api.loyalty.bindUserPartner(with: code))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.Code, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func saveSaveBonusCode(with code: Api.loyalty.Code, completionHandler: @escaping (Result<Api.Bool, CommonError>) -> Void) {
        let signal = makeSaveBonusCodeSignal(with: code)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("result makeSaveBonusCode")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeSaveBonusCodeSignal(with code: Api.loyalty.Code) -> Signal<Api.Bool, CommonError> {
        accountContext.account.network.request(Api.loyalty.saveBonusCode(with: code))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.Bool, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func activateBonusCode(with user: Api.loyalty.User, completionHandler: @escaping (Result<Api.Bool, CommonError>) -> Void) {
        let signal = makeActivateBonusCodeSignal(with: user)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("result makeActivateBonusCode")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeActivateBonusCodeSignal(with user: Api.loyalty.User) -> Signal<Api.Bool, CommonError> {
        accountContext.account.network.request(Api.loyalty.activateBonusCode(user))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.Bool, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func getCurrentUserCodeProgram(with user: Api.loyalty.User, completionHandler: @escaping (Result<Api.loyalty.LoyaltyData, CommonError>) -> Void) {
        let signal = makeGetCurrentUserCodeProgramSignal(with: user)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("result makeGetCurrentUserCodeProgramSignal")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGetCurrentUserCodeProgramSignal(with user: Api.loyalty.User) -> Signal<Api.loyalty.LoyaltyData, CommonError> {
        accountContext.account.network.request(Api.loyalty.getCurrentUserCodeProgram(user: user))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.LoyaltyData, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func makeGetLoyaltyBonusDataWithSum(with user: Api.loyalty.User, completionHandler: @escaping (Result<Api.loyalty.LoyaltyDataWithSum, CommonError>) -> Void) {
        let signal = makeGetLoyaltyBonusDataWithSumSignal(with: user)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("code makeGetLoyaltyBonusDataWithSum")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGetLoyaltyBonusDataWithSumSignal(with user: Api.loyalty.User) -> Signal<Api.loyalty.LoyaltyDataWithSum, CommonError> {
        accountContext.account.network.request(Api.loyalty.getLoyaltyBonusDataWithSum(user: user))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<Api.loyalty.LoyaltyDataWithSum, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func getAllBots(completionHandler: @escaping (Result<AIGetAllBotsItem, CommonError>) -> Void) {
        let signal = makeGetAllBotsSignal()
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("code makeGetAllBotsSignal")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeGetAllBotsSignal() -> Signal<AIGetAllBotsItem, CommonError> {
        accountContext.account.network.request(Api.ai.getAllBots())
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<AIGetAllBotsItem, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

extension RequestService {
    func subscriptionInfo(_ botId:Int? = nil, completionHandler: @escaping (Result<AISubscriptionInfoItem, CommonError>) -> Void) {
        let signal = makeSubscriptionInfoSignal(botId)
        
        _ = signal.start { result in
            debugPrint(result)
            debugPrint("code makeSubscriptionInfoSignal")
            completionHandler(.success(result))
        } error: { error in
            debugPrint(error)
            completionHandler(.failure(error))
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    private func makeSubscriptionInfoSignal(_ botId:Int? = nil) -> Signal<AISubscriptionInfoItem, CommonError> {
        accountContext.account.network.request(Api.ai.subscriptionInfo(botId))
        |> deliverOn(.mainQueue())
        |> mapError { error -> CommonError in
            debugPrint(error)
            return .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<AISubscriptionInfoItem, CommonError> in
            debugPrint(result)
            return .single(result)
        }
    }
}

