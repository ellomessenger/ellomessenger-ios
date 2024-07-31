//
//  TransferStatisticGraphicItem.swift
//  _idx_ELProfileUI_B2691B91_ios_min14.0
//
//

import Foundation
public struct TransferStatisticGraphicItems: MTProtoResponse {
    
    @DecodableDefault.EmptyList
    public var data: [TransferStatisticGraphicItem]
}

public struct TransferStatisticGraphicItem: MTProtoResponse {
    public enum Period: String, CaseIterable, Codable {
        case week
        case month
        case year

        var title: String { rawValue }
    }
    
    public enum `Type`: String, Codable, CaseIterable {
        case deposit
        case withdraw
    }
    
    @DecodableDefault.ZeroDouble
    public var total: Double
    
    public let period: String
    
    @DecodableDefault.EmptyList
    public var data: [MonthActivityItem]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Double.self, forKey: .total)
        period = try container.decode(String.self, forKey: .period)
        data = try container.decode([MonthActivityItem].self, forKey: .data)
    }
    
    public init(total: Double, period: String, data: [MonthActivityItem]) {
        self.total = total
        self.period = period
        self.data = data
    }
}
