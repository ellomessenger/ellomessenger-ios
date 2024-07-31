//
//  FeedShadowSpacer.swift
//  _idx_ELFeedUI_26FB37DA_ios_min11.0
//
//

import UIKit
import ELBase

class FeedShadowSpacer: UIImageView {
    private var shadowAdded = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        drawShadow()
    }
    
    func drawShadow() {
        if !shadowAdded {
            shadowAdded.toggle()
            
            let size = frame.size
            let layer: CALayer = CALayer()
            layer.backgroundColor = backgroundColor?.cgColor
            layer.position = CGPointMake(size.width / 2, -size.height / 2 + 0.5)
            layer.bounds = CGRectMake(0, 0, size.width, size.height)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSizeMake(0, -2)
            layer.shadowOpacity = 0.05
            layer.shadowRadius = 10.0
            
            self.layer.addSublayer(layer)
        }
    }
}
