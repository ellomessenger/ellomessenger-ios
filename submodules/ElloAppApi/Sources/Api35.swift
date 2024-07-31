//
//  Api33.swift
//  _idx_ElloAppApi_50E079A9_ios_min11.0
//
//

import Foundation

// MARK: - Get Wallet
public extension Api.wallet {
    typealias WalletsResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    fileprivate static var walletService: WalletService = {
        WalletService()
    }()
    
    static func getUserWallet(with assetId: Int) -> WalletsResponse<WalletItem> {
        walletService.userWallet(assetId: assetId)
    }
}

// MARK: - Get Wallets

public enum WalletError: Error {
    case message(String)
}

public extension Api.wallet {
    static func getUserWallets(with assetId: Int) -> WalletsResponse<WalletsItem> {
        walletService.userWallets(assetId: assetId)
    }
}

// MARK: - Create Wallet
public extension Api.wallet {
    static func createWallet(with assetId: Int) -> WalletsResponse<WalletItem> {
        walletService.createWallet(assetId: assetId)
    }
}

// MARK: - Make Payment
public extension Api.wallet {
    struct PaymentItem: Encodable {
        let paymentSystem: String
        let assetId: Int
        let walletId: Int
        let currency: String
        let message: String
        let number: String
        let expMonth: Int
        let expYear: Int
        let csv: Int
        public let amount: Double
        let holder: String?
        
        public init(paymentSystem: String, assetId: Int, walletId: Int, currency: String, message: String, number: String, expMonth: Int, expYear: Int, csv: Int, amount: Double, holder:String? = nil) {
            self.paymentSystem = paymentSystem
            self.assetId = assetId
            self.walletId = walletId
            self.currency = currency
            self.message = message
            self.number = number
            self.expMonth = expMonth
            self.expYear = expYear
            self.csv = csv
            self.amount = amount
            self.holder = holder
        }
    }
    
    struct PaymentItemResponse: Codable {
        var status: String
        var currency: String
        var amount: Double
        
        static func parse(_ reader: BufferReader) -> PaymentItemResponse? {
            reader.reset()
            let _1 = reader.readInt32()
            debugPrint(_1 as Any)
            let _2 = parseString(reader)
            debugPrint(_2 as Any)
            
            guard let jsonData = _2?.data(using: .utf8) else { return nil }
            
            do {
                return try JSONDecoder().decode(PaymentItemResponse.self, from: jsonData)
            } catch {
                debugPrint("\(#function) Error: \(error)")
                return nil
            }
        }
    }
    
    static func makePayment(with paymentItem: PaymentItem) -> WalletsResponse<PaymentItemResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        var data: [String: Any] = [
            "payment_system": paymentItem.paymentSystem,
            "asset_id": paymentItem.assetId,
            "wallet_id": paymentItem.walletId,
            "currency": paymentItem.currency,
            "message": paymentItem.message,
            "number": paymentItem.number,
            "exp_month": paymentItem.expMonth,
            "exp_year": paymentItem.expYear,
            "csv": paymentItem.csv,
            "amount": paymentItem.amount
        ]
        
        if let holder = paymentItem.holder {
            data["holder"] = holder
        }

        let dict: [String: Any] = [
            "service": 100500,
            "method": 100500,
            "data": data
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "wallet.makePayment",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> PaymentItemResponse? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return PaymentItemResponse.parse(reader)
        })
    }

    
    struct TransferMoneyBetweenWalletsItem: Encodable {
        let from_wallet_id: Int
        let to_wallet_id:Int
        let amount:Double
        let currency:String?  // optional
        let message:String?  // optional
        
        public init(from_wallet_id: Int,
                    to_wallet_id:Int,
                    amount:Double,
                    currency: String? = nil,
                    message: String? = nil) {
            self.from_wallet_id = from_wallet_id
            self.to_wallet_id = to_wallet_id
            self.amount = amount
            self.currency = currency
            self.message = message
        }
    }
    
    struct TransferMoneyBetweenWalletsItemResponse: Codable {
        var uuid:String
        var status:String
        var amount:Double
        var fee:Double
        var currency:String
        var description:String
        var payment_method:String
        
        static func parse(_ reader: BufferReader) -> TransferMoneyBetweenWalletsItemResponse? {
            reader.reset()
            let _1 = reader.readInt32()
            debugPrint(_1 as Any)
            let _2 = parseString(reader)
            debugPrint(_2 as Any)
            
            guard let jsonData = _2?.data(using: .utf8) else { return nil }
            
            do {
                return try JSONDecoder().decode(TransferMoneyBetweenWalletsItemResponse.self, from: jsonData)
            } catch {
                debugPrint("\(#function) Error: \(error)")
                return nil
            }
        }
    }

    static func transferMoneyBetweenWallets(with paymentItem: TransferMoneyBetweenWalletsItem) -> WalletsResponse<TransferMoneyBetweenWalletsItemResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        var data: [String: Any] = [
            "from_wallet_id": paymentItem.from_wallet_id,
            "to_wallet_id": paymentItem.to_wallet_id,
            "amount": paymentItem.amount
        ]
        
        if let currency = paymentItem.currency {
            data["currency"] = currency
        }
        
        if let message = paymentItem.message {
            data["message"] = message
        }

        let dict: [String: Any] = [
            "service": 100500,
            "method": 102300,
            "data": data
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "wallet.transferMoneyBetweenWallets",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> TransferMoneyBetweenWalletsItemResponse? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return TransferMoneyBetweenWalletsItemResponse.parse(reader)
        })
    }
}

// MARK: - Get Payment URL Paypal
public extension Api.wallet {
    struct PaypalPaymentItem: Encodable {
        public let assetId: Int
        public let walletId: Int
        public let currency: String
        let message: String
        public let amount: Double
        
        public init(assetId: Int, walletId: Int, currency: String, message: String, amount: Double) {
            self.assetId = assetId
            self.walletId = walletId
            self.currency = currency
            self.message = message
            self.amount = amount
        }
    }
    
    struct PaypalPaymentItemResponse: Codable {
        var status: String
        var currency: String?
        var amount: Double
        public var link: String
        
        static func parse(_ reader: BufferReader) -> PaypalPaymentItemResponse? {
            reader.reset()
            let _1 = reader.readInt32()
            debugPrint(_1 as Any)
            let _2 = parseString(reader)
            debugPrint(_2 as Any)
            
            guard let jsonData = _2?.data(using: .utf8) else { return nil }
            
            do {
                return try JSONDecoder().decode(PaypalPaymentItemResponse.self, from: jsonData)
            } catch {
                debugPrint("\(#function) Error: \(error)")
                return nil
            }
        }
    }
    
    static func getPaypallPaymentUrl(with paymentItem: PaypalPaymentItem) -> WalletsResponse<PaypalPaymentItemResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": 100500,
            "method": 100700,
            "data": [
                "asset_id": paymentItem.assetId,
                "wallet_id": paymentItem.walletId,
                "currency": paymentItem.currency,
                "message": paymentItem.message,
                "amount": paymentItem.amount,
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "wallet.getPaypallPaymentUrl",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> PaypalPaymentItemResponse? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return PaypalPaymentItemResponse.parse(reader)
        })
    }
}

// MARK: - Get transfer transactions for user wallet
public extension Api.wallet {
    static func transferTransactions(with endpoint: Endpoint) -> WalletsResponse<WalletTransactions> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func transferTransactions(with assetId: Int, walletId: Int, paymentType: String, search: String, dateFrom: String, dateTo: String, limit: Int, offset: Int) -> WalletsResponse<WalletTransactions> {
        transferTransactions(with: WalletEnpoint.walletTransactions(assetId: assetId, walletId: walletId, paymentType: paymentType, search: search, dateFrom: dateFrom, dateTo: dateTo, limit: limit, offset: offset))
    }
}

// MARK: - Get transfer page month activity statistic data for graphic
public extension Api.wallet {
    static func lastMonthActivityGraphic(with endpoint: Endpoint) -> WalletsResponse<MonthActivityItems> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func lastMonthActivityGraphic(with walletId: Int, limit: Int, page: Int) -> WalletsResponse<MonthActivityItems> {
        lastMonthActivityGraphic(with: WalletEnpoint.lastMonthActivityGraphic(walletId: walletId, limit: limit, page: page))
    }
}

// MARK: - Get transfer page statistic data for graphic
public extension Api.wallet {
    static func transferPageStatistic(with endpoint: Endpoint) -> WalletsResponse<TransferStatisticGraphicItems> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func transferPageStatistic(with walletId: Int, period: String, type: String, limit: Int, page: Int) -> WalletsResponse<TransferStatisticGraphicItems> {
        transferPageStatistic(with: WalletEnpoint.transferStatisticGraphic(walletId: walletId, period: period, type: type, limit: limit, page: page))
    }
}

// MARK: - Get earn wallet info
public extension Api.wallet {
    static func earnWalletInfo(with endpoint: Endpoint) -> WalletsResponse<EarnWalletItem> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func earnWalletInfo(with walletId: Int) -> WalletsResponse<EarnWalletItem> {
        earnWalletInfo(with: WalletEnpoint.earnWalletInfo(walletId: walletId))
    }
}

// MARK: - Withdraw Create Payments
public extension Api.wallet {
    static func withdrawCreatePayment(with endpoint: Endpoint) -> WalletsResponse<WithdrawCreatePaymentItem> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func withdrawCreatePayment(with assetId: Int,
                                      walletId:Int,
                                      currency: String,
                                      paypalEmail: String? = nil,
                                      paymentId: String? = nil,
                                      bankWithdrawRequisitesId: Int? = nil,
                                      amount: Double,
                                      withdrawSystem: String? = nil) -> WalletsResponse<WithdrawCreatePaymentItem> {
        withdrawCreatePayment(with: WalletEnpoint.withdrawCreatePayment(assetId: assetId,
                                                                        walletId: walletId,
                                                                        currency: currency,
                                                                        paypalEmail: paypalEmail,
                                                                        paymentId: paymentId,
                                                                        bankWithdrawRequisitesId: bankWithdrawRequisitesId,
                                                                        amount: amount,
                                                                        withdrawSystem: withdrawSystem))
    }
}

// MARK: - Withdraw Approve Payment
public extension Api.wallet {
    static func withdrawApprovePayment(with endpoint: Endpoint) -> WalletsResponse<WithdrawApprovePaymentItem> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func withdrawApprovePayment(with walletId: Int,
                                      paymentId: String,
                                      approveCode: String,
                                      paypalEmail: String?,
                                      bankWithdrawRequisitesId: Int?) -> WalletsResponse<WithdrawApprovePaymentItem> {
        withdrawApprovePayment(with: WalletEnpoint.withdrawApprovePayment(walletId: walletId, 
                                                                          paymentId: paymentId,
                                                                          approveCode: approveCode,
                                                                          paypalEmail: paypalEmail,
                                                                          bankWithdrawRequisitesId: bankWithdrawRequisitesId))
    }
}

// MARK: - Send Auth Email
public extension Api.wallet {
    static func createBankWithdrawRequisites(with endpoint: Endpoint) -> WalletsResponse<BankWithdrawRequisitesItem> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func createBankWithdrawRequisites(isTemplate: Bool?,
                                             recipientType: String?,
                                             businessIdNumber: String?,
                                             personalFirstName: String?,
                                             personalLastName: String?,
                                             personalPhoneNumber: String?,
                                             personalEmail: String?,
                                             message: String?,
                                             currency: String?,
                                             bankCountry: String?,
                                             bankRoutingNumber: String?,
                                             bankName: String?,
                                             bankStreet: String?,
                                             bankCity: String?,
                                             bankState: String?,
                                             bankSwift: String?,
                                             bankAddress: String?,
                                             bankPostalCode: String?,
                                             bankZipCode: String?,
                                             bankRecipientAccountNumber: String?,
                                             userAddressAddress: String?,
                                             userAddressStreet: String?,
                                             userAddressCity: String?,
                                             userAddressState: String?,
                                             userAddressRegion: String?,
                                             userAddressZipCode: String?,
                                             userAddressPostalCode: String?) -> WalletsResponse<BankWithdrawRequisitesItem> {
        
        createBankWithdrawRequisites(with: WalletEnpoint.createBankWithdrawRequisites(isTemplate: isTemplate,
                                                                                      recipientType: recipientType,
                                                                                      businessIdNumber: businessIdNumber,
                                                                                      personalFirstName: personalFirstName,
                                                                                      personalLastName: personalLastName,
                                                                                      personalPhoneNumber: personalPhoneNumber,
                                                                                      personalEmail: personalEmail,
                                                                                      message: message,
                                                                                      currency: currency,
                                                                                      bankCountry: bankCountry,
                                                                                      bankRoutingNumber: bankRoutingNumber,
                                                                                      bankName: bankName,
                                                                                      bankStreet: bankStreet,
                                                                                      bankCity: bankCity,
                                                                                      bankState: bankState,
                                                                                      bankSwift: bankSwift,
                                                                                      bankAddress: bankAddress,
                                                                                      bankPostalCode: bankPostalCode,
                                                                                      bankZipCode: bankZipCode,
                                                                                      bankRecipientAccountNumber: bankRecipientAccountNumber,
                                                                                      userAddressAddress: userAddressAddress,
                                                                                      userAddressStreet: userAddressStreet,
                                                                                      userAddressCity: userAddressCity,
                                                                                      userAddressState: userAddressState,
                                                                                      userAddressRegion: userAddressRegion,
                                                                                      userAddressZipCode: userAddressZipCode,
                                                                                      userAddressPostalCode: userAddressPostalCode))
    }
}
    
public extension Api.wallet {
    static func editWithdrawTemplate(with endpoint: Endpoint) -> WalletsResponse<BankWithdrawRequisitesItem> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func editWithdrawTemplate(templateId: Int?,
                                     recipientType: String?,
                                     businessIdNumber: String?,
                                     personalFirstName: String?,
                                     personalLastName: String?,
                                     personalPhoneNumber: String?,
                                     personalEmail: String?,
                                     message: String?,
                                     currency: String?,
                                     bankCountry: String?,
                                     bankRoutingNumber: String?,
                                     bankName: String?,
                                     bankStreet: String?,
                                     bankCity: String?,
                                     bankState: String?,
                                     bankSwift: String?,
                                     bankAddress: String?,
                                     bankPostalCode: String?,
                                     bankZipCode: String?,
                                     bankRecipientAccountNumber: String?,
                                     userAddressAddress: String?,
                                     userAddressStreet: String?,
                                     userAddressCity: String?,
                                     userAddressState: String?,
                                     userAddressRegion: String?,
                                     userAddressZipCode: String?,
                                     userAddressPostalCode: String?) -> WalletsResponse<BankWithdrawRequisitesItem> {
        
        editWithdrawTemplate(with: WalletEnpoint.editWithdrawTemplate(templateId: templateId,
                                                                                      recipientType: recipientType,
                                                                                      businessIdNumber: businessIdNumber,
                                                                                      personalFirstName: personalFirstName,
                                                                                      personalLastName: personalLastName,
                                                                                      personalPhoneNumber: personalPhoneNumber,
                                                                                      personalEmail: personalEmail,
                                                                                      message: message,
                                                                                      currency: currency,
                                                                                      bankCountry: bankCountry,
                                                                                      bankRoutingNumber: bankRoutingNumber,
                                                                                      bankName: bankName,
                                                                                      bankStreet: bankStreet,
                                                                                      bankCity: bankCity,
                                                                                      bankState: bankState,
                                                                                      bankSwift: bankSwift,
                                                                                      bankAddress: bankAddress,
                                                                                      bankPostalCode: bankPostalCode,
                                                                                      bankZipCode: bankZipCode,
                                                                                      bankRecipientAccountNumber: bankRecipientAccountNumber,
                                                                                      userAddressAddress: userAddressAddress,
                                                                                      userAddressStreet: userAddressStreet,
                                                                                      userAddressCity: userAddressCity,
                                                                                      userAddressState: userAddressState,
                                                                                      userAddressRegion: userAddressRegion,
                                                                                      userAddressZipCode: userAddressZipCode,
                                                                                      userAddressPostalCode: userAddressPostalCode))
    }
}
    

// MARK: - Withdraw Get Payments
public extension Api.wallet {
    static func getBankWithdrawsRequisites(with endpoint: Endpoint) -> WalletsResponse<BankWithdrawsItems> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func getBankWithdrawsRequisites(limit: Int, offset: Int, isTemplate: Bool) -> WalletsResponse<BankWithdrawsItems> {
        getBankWithdrawsRequisites(with: WalletEnpoint.getBankWithdrawsRequisites(limit: limit,
                                                                                  offset: offset,
                                                                                  isTemplate: isTemplate))
    }

}

// MARK: - Send Auth Email
public extension Api.wallet {
    static func sendAuthEmail(with endpoint: Endpoint) -> WalletsResponse<Api.Response.SendVerificationCode> {
        let walletService = WalletService()
        return walletService.sendRequest(endpoint: endpoint)
    }
    
    static func sendAuthEmail() -> WalletsResponse<Api.Response.SendVerificationCode> {
        sendAuthEmail(with: WalletEnpoint.sendAuthCode)
    }
}

// MARK: - Get Wallet Bank Payment Url
public extension Api.wallet {
    /// Get  url for top up the account with a bank card
    static func bankPaymentUrl(with assetId: Int, walletId: Int, currency: String, amount: Double) -> WalletsResponse<WalletBankTopUpUrlResponse> {
        walletService.bankTopUpUrl(assetId: assetId, walletId: walletId, currency: currency, amount: amount)
    }
}

// MARK: - TopUp Coins with InAppPurchase
public extension Api.wallet {
    static func processApplePayment(amount: Double, payload: String) -> WalletsResponse<WalletInAppPurchaseCoinsResponse> {
        walletService.processApplePayment(amount: amount, payload: payload)
    }
}

// MARK: - Internal Transfer Payment
public extension Api.wallet {
    static func internalTransferPayment(fromWalletId: Int, 
                                        toWalletId: Int,
                                        amount:Double,
                                        currency:String?,
                                        message:String?) -> WalletsResponse<WalletInternalTransferPayment> {
        
        walletService.internalTransferPayment(fromWalletId: fromWalletId,
                                              toWalletId: toWalletId,
                                              amount: amount,
                                              currency: currency,
                                              message: message)
    }
}

