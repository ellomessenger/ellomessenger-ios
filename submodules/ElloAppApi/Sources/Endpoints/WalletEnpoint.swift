//
//  WalletEnpoint.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

public enum BaseAsset:Int {
    case usd = 2
    
    var symbol:String {
        switch self {
            case .usd:
                "usd"
            }
    }
}

public enum WithdrawSystem: String {
    case paypal
    case bank
}

public enum WalletEnpoint {
    case createWallet(assetId: Int)
    case userWallet(assetId: Int)
    case userWallets(assetId: Int)
    case walletTransactions(
        assetId: Int,
        walletId: Int,
        paymentType: String,
        search: String,
        dateFrom: String,
        dateTo: String,
        limit: Int,
        offset: Int
    )
    case lastMonthActivityGraphic(walletId: Int, limit: Int, page: Int)
    case transferStatisticGraphic(walletId: Int, period: String, type: String, limit: Int, page: Int)
    case earnWalletInfo(walletId: Int)
    case withdrawCreatePayment(
        assetId: Int,
        walletId:Int,
        currency: String,
        paypalEmail: String? = nil,
        paymentId: String? = nil,
        bankWithdrawRequisitesId: Int? = nil,
        amount: Double,
        withdrawSystem: String? = nil // paypal, bank
    )
    case withdrawCancelPayment(
        walletId: Int,
        paymentId: String
    )
    case withdrawApprovePayment(
        walletId: Int,
        paymentId: String,
        approveCode: String,
        paypalEmail: String? = nil,
        bankWithdrawRequisitesId: Int? = nil,
        withdrawSystem: String? = nil
    )
    case sendAuthCode
    case createBankWithdrawRequisites(
        isTemplate: Bool?,
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
        userAddressPostalCode: String?
    )
    case editWithdrawTemplate(
        templateId: Int?,
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
        userAddressPostalCode: String?
    )

    case bankTopUpUrl(assetId: Int, walletId: Int, currency: String, amount: Double)
    case processApplePayment(amount: Double, payload: String)
    case internalTransferPayment(fromWalletId:Int, toWalletId:Int, amount: Double, currency: String? = nil, message:String? = nil)
    case getBankWithdrawsRequisites(
        limit: Int,
        offset: Int,
        isTemplate: Bool
    )
}

extension WalletEnpoint: Endpoint {
    public var service: MTProtoService {
        .wallet
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .createWallet:
            return WalletMethod.createWallet
        case .userWallet:
            return WalletMethod.userWallet
        case .userWallets:
            return WalletMethod.userWallets
        case .walletTransactions:
            return WalletMethod.walletTransactions
        case .lastMonthActivityGraphic:
            return WalletMethod.lastMonthActivityGraphic
        case .transferStatisticGraphic:
            return WalletMethod.transferStatisticGraphic
        case .earnWalletInfo:
            return WalletMethod.earnWalletInfo
        case .withdrawCreatePayment:
            return WalletMethod.withdrawCreatePayment
        case .withdrawCancelPayment:
            return WalletMethod.withdrawCancelPayment
        case .withdrawApprovePayment:
            return WalletMethod.withdrawApprovePayment
        case .sendAuthCode:
            return WalletMethod.sendAuthCode
        case .createBankWithdrawRequisites:
            return WalletMethod.createBankWithdrawRequisites
        case .bankTopUpUrl:
            return WalletMethod.bankTopUpUrl
        case .processApplePayment:
            return WalletMethod.processApplePayment
        case .internalTransferPayment:
            return WalletMethod.internalTransferPayment
        case .getBankWithdrawsRequisites:
            return WalletMethod.getBankWithdrawsRequisites
        case .editWithdrawTemplate:
            return WalletMethod.editWithdrawTemplate
        }
    }
    
    public var data: [String: Any] {
        switch self {
        case .createWallet(let assetId):
            return [
                "asset_id": assetId
            ]
        case .userWallet(let assetId):
            return [
                "asset_id": assetId
            ]
        case .userWallets(let assetId):
            return [
                "asset_id": assetId
            ]
        case .walletTransactions(assetId: let assetId, walletId: let walletId, paymentType: let paymentType, search: let search, dateFrom: let dateFrom, dateTo: let dateTo, limit: let limit, offset: let offset):
            return [
                "asset_id": assetId,
                "wallet_id": walletId,
                "payment_type": paymentType, // "all", deposit, transfer, withdraw
                "search": search,
                "date_from": dateFrom, // format yyyy-MM-dd
                "date_to": dateTo,
                "limit": limit,
                "offset": offset
            ]
        case .lastMonthActivityGraphic(walletId: let walletId, limit: let limit, page: let page):
            return [
                "wallet_id": walletId,
                "limit": limit,
                "page": page
            ]
        case .transferStatisticGraphic(walletId: let walletId, period: let period, type: let type, limit: let limit, page: let page):
            return [
                "wallet_id": walletId,
                "period": period,
                "type": type,
                "limit": limit,
                "page": page
            ]
        case .earnWalletInfo(walletId: let walletId):
            return [
                "wallet_id": walletId
            ]
        case .withdrawCreatePayment(assetId: let assetId, 
                                    walletId: let walletId,
                                    currency: let currency,
                                    paypalEmail: let paypalEmail,
                                    paymentId: let paymentId,
                                    bankWithdrawRequisitesId: let bankWithdrawRequisitesId,
                                    amount: let amount,
                                    withdrawSystem: let withdrawSystem):
            let params: [String: Any?] =  [
                "asset_id": assetId,
                "wallet_id": walletId,
                "currency": currency,
                "paypal_email": paypalEmail,
                "payment_id": paymentId,
                "bank_withdraw_requisites_id": bankWithdrawRequisitesId,
                "amount": amount,
                "withdraw_system": withdrawSystem
            ]
            return params.compactMapValues { $0 }
        case let .withdrawCancelPayment(walletId, paymentId):
            return [
                "wallet_id": walletId,
                "paymentId": paymentId
            ]
        case let .withdrawApprovePayment(walletId, paymentId, approveCode, paypalEmail, bankWithdrawRequisitesId, withdrawSystem):
            let params: [String: Any?] = [
                "wallet_id": walletId,
                "payment_id": paymentId,
                "approve_code": approveCode,
                "paypal_email": paypalEmail,
                "bank_withdraw_requisites_id": bankWithdrawRequisitesId,
                "withdraw_system": withdrawSystem
            ]
            return params.compactMapValues { $0 }
        case .sendAuthCode:
            return [:]
        case let .createBankWithdrawRequisites(isTemplate, recipientType, businessIdNumber, personalFirstName, personalLastName, personalPhoneNumber, personalEmail, message, currency, bankCountry, bankRoutingNumber, bankName, bankStreet, bankCity, bankState, bankSwift, bankAddress, bankPostalCode, bankZipCode, bankRecipientAccountNumber, userAddressAddress, userAddressStreet, userAddressCity, userAddressState, userAddressRegion, userAddressZipCode, userAddressPostalCode):
            let params: [String: Any?] = [
                "is_template": isTemplate,
                "recipient_type": recipientType,
                "business_id_number": businessIdNumber,
                "personal_first_name": personalFirstName,
                "personal_last_name": personalLastName,
                "personal_phone_number": personalPhoneNumber,
                "personal_email": personalEmail,
                "message": message,
                "currency": currency,
                "bank_country": bankCountry,
                "bank_routing_number": bankRoutingNumber,
                "bank_name": bankName,
                "bank_street": bankStreet,
                "bank_city": bankCity,
                "bank_state": bankState,
                "bank_swift": bankSwift,
                "bank_address": bankAddress,
                "bank_postal_code": bankPostalCode,
                "bank_zip_code": bankZipCode,
                "bank_recipient_account_number": bankRecipientAccountNumber,
                "user_address_address": userAddressAddress,
                "user_address_street": userAddressStreet,
                "user_address_city": userAddressCity,
                "user_address_state": userAddressState,
                "user_address_region": userAddressRegion,
                "user_address_zip_code": userAddressZipCode,
                "user_address_postal_code": userAddressPostalCode
            ]
            return params.compactMapValues { $0 }
        case let .bankTopUpUrl(assetId, walletId, currency, amount):
            return [
                "asset_id": assetId,
                "wallet_id": walletId,
                "currency": currency,
                "amount": amount
            ]
        case let .processApplePayment(amount, payload):
            return [
                "amount": amount,
                "payload": payload
            ]
        case let .internalTransferPayment(fromWalletId, toWalletId, amount, currency, message):
            var result:[String:Any] = [
                "from_wallet_id": fromWalletId,
                "to_wallet_id": toWalletId,
                "amount": amount
            ]
            
            if let currency {
                result["currency"] = currency
            }
            
            if let message {
                result["message"] = message
            }
            
            return result
        case .getBankWithdrawsRequisites(limit: let limit, offset: let offset, isTemplate: let isTemplate):
            return [
                "limit": limit,
                "offset": offset,
                "is_template": isTemplate
            ]
        case .editWithdrawTemplate(templateId: let templateId, 
                                   recipientType: let recipientType,
                                   businessIdNumber: let businessIdNumber,
                                   personalFirstName: let personalFirstName,
                                   personalLastName: let personalLastName,
                                   personalPhoneNumber: let personalPhoneNumber,
                                   personalEmail: let personalEmail,
                                   message: let message,
                                   currency: let currency, 
                                   bankCountry: let bankCountry,
                                   bankRoutingNumber: let bankRoutingNumber,
                                   bankName: let bankName,
                                   bankStreet: let bankStreet,
                                   bankCity: let bankCity,
                                   bankState: let bankState,
                                   bankSwift: let bankSwift,
                                   bankAddress: let bankAddress,
                                   bankPostalCode: let bankPostalCode,
                                   bankZipCode: let bankZipCode,
                                   bankRecipientAccountNumber: let bankRecipientAccountNumber,
                                   userAddressAddress: let userAddressAddress,
                                   userAddressStreet: let userAddressStreet,
                                   userAddressCity: let userAddressCity,
                                   userAddressState: let userAddressState,
                                   userAddressRegion: let userAddressRegion,
                                   userAddressZipCode: let userAddressZipCode,
                                   userAddressPostalCode: let userAddressPostalCode):
            let params: [String: Any?] = [
                "template_id": templateId,
                "recipient_type": recipientType,
                "business_id_number": businessIdNumber,
                "personal_first_name": personalFirstName,
                "personal_last_name": personalLastName,
                "personal_phone_number": personalPhoneNumber,
                "personal_email": personalEmail,
                "message": message,
                "currency": currency,
                "bank_country": bankCountry,
                "bank_routing_number": bankRoutingNumber,
                "bank_name": bankName,
                "bank_street": bankStreet,
                "bank_city": bankCity,
                "bank_state": bankState,
                "bank_swift": bankSwift,
                "bank_address": bankAddress,
                "bank_postal_code": bankPostalCode,
                "bank_zip_code": bankZipCode,
                "bank_recipient_account_number": bankRecipientAccountNumber,
                "user_address_address": userAddressAddress,
                "user_address_street": userAddressStreet,
                "user_address_city": userAddressCity,
                "user_address_state": userAddressState,
                "user_address_region": userAddressRegion,
                "user_address_zip_code": userAddressZipCode,
                "user_address_postal_code": userAddressPostalCode
            ]
            return params.compactMapValues { $0 }.filter { 
                guard let value = $0.value as? String else { return true }
                return !value.isEmpty
            }
        }
    }
}
