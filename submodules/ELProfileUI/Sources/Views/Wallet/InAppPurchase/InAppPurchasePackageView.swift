//
//  InAppPurchasePackageView.swift
//  _LocalDebugOptions
//
//

import UIKit

class InAppPurchasePackageView: UIControl {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var productId = ""
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected
            ? UIColor(named: "BgLightGrey", in: Bundle(for: Self.self), compatibleWith: nil)
            : .white
            borderWidth = isSelected ? 1.0 : 0.0
        }
    }
    
    func updateData(_ item: InAppPurchasePackageItem) {
        productId = item.productId
        titleLabel.text = item.title
        countLabel.text = String(item.count)
        priceLabel.text = item.price
    }
}
