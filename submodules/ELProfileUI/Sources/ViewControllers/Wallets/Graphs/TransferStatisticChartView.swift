////
////  TransferStatisticChartView.swift
////  _idx_AccountContext_7827DC97_ios_min16.0
////
///

import ELBase
import ElloAppApi
import SwiftUI
import Charts

public struct TransferStatisticChartView: View {
    
    var didPeriodChange: ((String) -> Void)?
    var didTotalChange: ((String) -> Void)?
    
    // MARK: - Properties
    var arrayWithDates: [String] = []
    let items: TransferStatisticGraphicItem
    let typeGraphs: TransferStatisticGraphicItem.`Type`
    
    public var body: some View {
        VStack(alignment: .leading) {
            Chart(arrayWithDates, id: \.self) { date in
                let item = items.data.first { $0.period == date }
                let amount = item?.amount ?? 0
                BarMark(x: .value("Period", date), y: .value("Amount", amount), width: 18.0)
                    .foregroundStyle(getGradientColors(typeGraphs))
            }
            .padding()
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.gray)
                        .font(.system(size: 11))
                }
            }
        }
        .onAppear {
            didPeriodChange?(items.period.description)
            didTotalChange?(String(format: "%.2f", items.total))
        }
    }
    
    func getGradientColors(_ typeGraphs: TransferStatisticGraphicItem.`Type`) -> LinearGradient {
        
        let depositColors: [Color] = [Color(red: 0.27, green: 0.75, blue: 0.18), Color(red: 0.15, green: 0.68, blue: 0.38)]
        let depositGradient = LinearGradient(gradient: Gradient(colors: depositColors), startPoint: .top, endPoint: .bottom)
        let withdrawColors: [Color] = [ Color(red: 1, green: 0.46, blue: 0.56), Color(red: 0.94, green: 0.25, blue: 0.38)]
        let withdrawGradient = LinearGradient(gradient: Gradient(colors: withdrawColors), startPoint: .top, endPoint: .bottom)
        
        return typeGraphs == .deposit ? depositGradient : withdrawGradient
    }
}
