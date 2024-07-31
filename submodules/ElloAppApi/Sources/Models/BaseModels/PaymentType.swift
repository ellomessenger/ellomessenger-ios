//
//  PaymentType.swift
//  _idx_ElloAppApi_5257747F_ios_min14.0
//
//

import Foundation

public enum PaymentType: String, Codable {
    /// Transfers between your wallets (Ello Card <-> Earnings)
    case transfer
    /// Any incoming payments
    case deposit
    /// Any outgoing payments
    case withdraw
    /// All payments
    case all
    
    public var title:String {
        return self == .withdraw ? "Withdrawal" : self.rawValue
    }
}
