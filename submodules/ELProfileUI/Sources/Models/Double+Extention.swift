//
//  Double+Extention.swift
//  _LocalDebugOptions
//
//  Created by Oleksii Zabrodin on 19.12.2023.
//

import Foundation

extension Double {
    public var stringFinanceFormat: String {
        String(format: "%.2f", self)
    }
    
    public var stringFinanceFormatWithDollar: String {
        stringFinanceFormat(withAssetSymbolCode: nil, defaultCurrencySymbol: "$")
    }
    
    public func stringFinanceFormat(withAssetSymbolCode assetSymbol: String?, defaultCurrencySymbol: String = "") -> String {
        if let assetSymbol, !assetSymbol.isEmpty {
            String(format: "%@%.2f", assetSymbol.currencySymbol, self)
        } else {
            String(format: "%@%.2f", defaultCurrencySymbol, self)
        }
    }
}
