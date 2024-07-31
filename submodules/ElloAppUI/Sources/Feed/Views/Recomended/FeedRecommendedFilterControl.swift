//
//  FeedRecommendedFilterControl.swift
//  ElloAppUI
//
//

import UIKit

class FeedRecommendedFilterControl: UIControl {
    @IBOutlet var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected
            ? UIColor(bundleColorName: "TextBlue")
            : UIColor(bundleColorName: "IconsDarkGray")
            
            backgroundColor = isSelected
            ? UIColor(bundleColorName: "Blue200")
            : UIColor(bundleColorName: "BlackAlpha5")
        }
    }
}
