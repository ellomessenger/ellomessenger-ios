//
//  MonthActivityItem.swift
//  _idx_ELProfileUI_F5FB5BFD_ios_min14.0
//
//

import Foundation

public struct MonthActivityItems: MTProtoResponse {
    @DecodableDefault.ZeroDouble
    public var amount: Double
    
    @DecodableDefault.EmptyList
    public var data: [MonthActivityItem]
}

public struct MonthActivityItem: MTProtoResponse {
    public var date: String
    public var type: PaymentType
    @DecodableDefault.ZeroDouble
    public var amount: Double
    @DecodableDefault.EmptyString
    public var period: String
    @DecodableDefault.EmptyString
    public var dateFrom: String
    @DecodableDefault.EmptyString
    public var dateTo: String
    
    public init(date: String, type: PaymentType, amount: Double = 0.0, period: String = "", dateFrom: String = "", dateTo: String = "") {
        self.date = date
        self.type = type
        self.amount = amount
        self.period = period
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
}
