//
//  WalletType.swift
//  _idx_ElloAppApi_5257747F_ios_min14.0
//
//

import Foundation

public enum WalletType: String, Codable {
    case main
    case earning
    
    public var isMain: Bool { self == .main }
    public var isEarning: Bool { self == .earning }
    public var name: String {
        switch self {
            case .main: return "transactionDetails.myBalance"
            case .earning: return "transactionDetails.myEarnings"
        }
    }
}
