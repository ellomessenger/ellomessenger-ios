//
//  WalletMethod.swift
//  _idx_ElloAppApi_E681992B_ios_min14.0
//
//

import Foundation

enum WalletMethod: Int, MTProtoMethod {
    case createWallet = 100100
    case userWallet = 100400
    case userWallets = 100200
    case walletTransactions = 101900
    case lastMonthActivityGraphic = 101700
    case transferStatisticGraphic = 101600
    case earnWalletInfo = 101100
    case withdrawCreatePayment = 100800
    case withdrawCancelPayment = 100900
    case withdrawApprovePayment = 101000
    case sendAuthCode = 102100
    case createBankWithdrawRequisites = 101300
    case getBankWithdrawRequisites = 101400
    case getBankWithdrawsRequisites = 101500
    case bankTopUpUrl = 102500
    case processApplePayment = 102700
    case internalTransferPayment = 102800
    case editWithdrawTemplate = 102900
}
