//
//  PurchaseInfoItemView.swift
//  _idx_ELCommonUI_128253A2_ios_min15.4
//
//

import UIKit
import ELBase

class PurchaseInfoItemView: BaseView {
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var descriptionLabel: UILabel?
    
    public func config(title: String, description: String) {
        titleLabel?.text = title
        descriptionLabel?.text = description
    }
}
