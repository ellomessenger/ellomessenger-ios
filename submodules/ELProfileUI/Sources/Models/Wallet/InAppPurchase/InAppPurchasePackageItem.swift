//
//  InAppPurchasePackageItem.swift
//  _LocalDebugOptions
//
//

import Foundation
import StoreKit

struct InAppPurchasePackageItem {
    let productId: String
    let title: String
    /// Count of coins to buy
    let count: Int
    /// Price of coins
    let price: String
    
    init(product: Product) {
        productId = product.id
        title = product.displayName
        count = Int(product.id.components(separatedBy: ".").last ?? "0") ?? 0
        price = product.displayPrice
    }
}
