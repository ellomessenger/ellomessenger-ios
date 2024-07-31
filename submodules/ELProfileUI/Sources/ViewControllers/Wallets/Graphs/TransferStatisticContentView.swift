//
//  TransferStatisticContentView.swift
//  _idx_AccountContext_7827DC97_ios_min16.0
//

import ELBase
import ElloAppApi
import SwiftUI

public struct TransferStatisticContentView: View {
    
    var onPeriodChange: ((String) -> Void)?
    var onTotalChange: ((String) -> Void)?
    
    // MARK: - Constants
    private struct Constants {
        static let chartsSpacing = 25.0
    }
    
    // MARK: - Properties
    private var arrayWithDates: [String] = []
    private var period: TransferStatisticGraphicItem.Period = .week
    private var periodActivityItemTransactions: [TransferStatisticGraphicItem]
    private var typeGraphs: TransferStatisticGraphicItem.`Type`
    
    // MARK: - Init
    public init(arraywithDates: [String], periodActivityItemTransactions: [TransferStatisticGraphicItem], typeGraphs: TransferStatisticGraphicItem.`Type`, period: TransferStatisticGraphicItem.Period) {
        self.arrayWithDates = arraywithDates
        self.periodActivityItemTransactions = periodActivityItemTransactions
        self.typeGraphs = typeGraphs
        self.period = period
    }
    
    public var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: Constants.chartsSpacing) {
                    ForEach(periodActivityItemTransactions, id: \.self) { transaction in
                        TransferStatisticChartView(didPeriodChange: onPeriodChange, didTotalChange: onTotalChange, arrayWithDates: arrayWithDates, items: transaction, typeGraphs: typeGraphs)
                    }
                    .frame(width: UIScreen.main.bounds.width - Constants.chartsSpacing*2)
                }
            }
        }
    }
    
    public static func createWithDates(period: TransferStatisticGraphicItem.Period, periodActivityItemTransactions: [TransferStatisticGraphicItem], typeGraphs: TransferStatisticGraphicItem.`Type`) -> TransferStatisticContentView {
        let arrayWithDates = getDateArray(period: period, periodActivityItemTransactions: periodActivityItemTransactions)
        return TransferStatisticContentView(arraywithDates: arrayWithDates, periodActivityItemTransactions: periodActivityItemTransactions, typeGraphs: typeGraphs, period: period)
    }
    
    private static func getDateArray(period: TransferStatisticGraphicItem.Period, periodActivityItemTransactions: [TransferStatisticGraphicItem]) -> [String] {
        switch period {
        case .week:
            
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        case .month:
            
            return getMonthDateRanges(from: periodActivityItemTransactions)
            
        case .year:
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            dateFormatter.locale = Locale(identifier: "en_US")
            
            guard let monthRangesSet = getYearDateRanges(from: periodActivityItemTransactions) else { return [] }
            
            let sortedMonths = monthRangesSet
                .compactMap { monthName -> (monthName: String, date: Date)? in
                    guard let date = dateFormatter.date(from: monthName) else { return nil }
                    return (monthName: monthName, date: date)
                }
                .sorted { $0.date < $1.date }
                .map { $0.monthName }
            return sortedMonths
        }
    }
    
    private static func getMonthDateRanges(from transactions: [TransferStatisticGraphicItem]) -> [String] {
       
        var arrayWithDates: [String] = []
        let stringFromMonthDate = transactions.last?.data.first?.date
        guard let daysCount = countDaysInMonth(from: stringFromMonthDate ?? "31") else { return [] }

        var startDate = 1
        let strideValue = 6
        
        while startDate < daysCount {
            var endDate = startDate + strideValue
            if endDate > daysCount {
                endDate = daysCount
            }
            
            var dateRange = ""
            if startDate != endDate {
                dateRange = "\(startDate) - \(endDate)"
            } else {
                dateRange = "\(startDate)"
            }
            
            arrayWithDates.append(dateRange)
            startDate += strideValue
        }
        
        return arrayWithDates
    }
    
    private static func getYearDateRanges(from transactions: [TransferStatisticGraphicItem]) -> Set<String>? {
        
        var monthNamesSet = Set<String>()
        let dateStrings = transactions.flatMap { $0.data.map { $0.date } }
        
        guard !dateStrings.isEmpty else { return monthNamesSet }
        for dateString in dateStrings {
            guard let nearestMonths = getNearestMonths(from: dateString) else { return monthNamesSet }
            monthNamesSet.formUnion(nearestMonths)
        }
        
        while monthNamesSet.count < 6 {
            let lastDate = dateStrings.last ?? DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
            if let mockMonths = getNearestMonths(from: lastDate) {
                monthNamesSet.formUnion(mockMonths)
            }
        }
        return monthNamesSet
    }
    
    private static func countDaysInMonth(from dateString: String) -> Int? {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            let range = calendar.range(of: .day, in: .month, for: date)
            return range?.count
        }
        
        return 31
    }
    
    private static func getNearestMonths(from dateString: String) -> Set<String>? {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        if let date = dateFormatter.date(from: dateString) {
            var months = Set<String>()
            
            for offset in 0..<6 {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMM"
                monthFormatter.locale = Locale(identifier: "en_US")
                if let month = calendar.date(byAdding: .month, value: offset, to: date) {
                    let monthString = monthFormatter.string(from: month)
                    months.insert(monthString)
                }
            }
            return months
        }
        return nil
    }
}
