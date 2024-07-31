//
//  FeedSegmentedView.swift
//  _idx_ELFeedUI_26FB37DA_ios_min11.0
//
//

import UIKit
import ELBase

class FeedSegmentControl: UIControl {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var activeImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            let titleColorName = isSelected ? "TextBlue" : "TextGray"
            titleLabel.textColor = UIColor(named: titleColorName, in: Bundle(for: Self.self), compatibleWith: nil)
            activeImageView.isHidden = !isSelected
        }
    }
}

class FeedSegmentedView: UIView {
    @IBOutlet var forMeControl: FeedSegmentControl!
    @IBOutlet var exploreControl: FeedSegmentControl!
    @IBOutlet var recomendedControl: FeedSegmentControl!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.shadowPath = UIBezierPath(
            rect: CGRect(
                x: 0,
                y: bounds.maxY - layer.shadowRadius,
                width: bounds.width,
                height: layer.shadowRadius
            )
        ).cgPath
    }
    
    var forMeControlTappedHandler: (() -> Void)?
    var exploreControlTappedHandler: (() -> Void)?
    var recomendedTappedHandler: (() -> Void)?
    
    @IBAction func forMeControlTapped(_ sender: FeedSegmentControl) {
        guard !sender.isSelected else { return }
        
        sender.isSelected = true
        
        exploreControl.isSelected = false
        recomendedControl.isSelected = false
        forMeControlTappedHandler?()
    }
    
    @IBAction func exploreControlTapped(_ sender: FeedSegmentControl) {
        guard !sender.isSelected else { return }
        
        sender.isSelected = true
        
        forMeControl.isSelected = false
        recomendedControl.isSelected = false
        exploreControlTappedHandler?()
    }
    
    @IBAction func recomendedTapped(_ sender: FeedSegmentControl) {
        guard !sender.isSelected else { return }
        
        sender.isSelected = true
        
        forMeControl.isSelected = false
        exploreControl.isSelected = false
        recomendedTappedHandler?()
    }
}
