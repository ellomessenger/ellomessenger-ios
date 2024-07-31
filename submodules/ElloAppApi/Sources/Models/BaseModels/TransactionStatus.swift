//
//  TransactionStatus.swift
//  _idx_ElloAppApi_01594E19_ios_min14.0
//
//

import Foundation

//STATUS_PROCESSING  = "processing"
//STATUS_ADMIN_CHECK = "admin_check"
//STATUS_COMPLETED   = "completed"
//STATUS_CANCELED    = "canceled"
//STATUS_ERROR       = "error"

public enum TransactionStatus: String, Codable {
    case processing
    case adminCheck = "admin_check"
    case completed
    case canceled
    case error
}
