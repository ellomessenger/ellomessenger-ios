//
//  BotProcessingView.swift
//  _idx_ELCommonUI_F0C2D3F9_ios_min14.0
//
//

import UIKit
import ELBase
import Lottie

public class BotProcessingView: BaseView {
    @IBOutlet private var processingIV: AnimationView?
    @IBOutlet private var containerView: UIStackView!
    @IBOutlet private var processingLabel: UILabel?
    
    public var close: VoidClosure?
    public var minimiseAction: EventClosure<Bool>?
    public var isMinimized = true
    
    
    public override func initializeSubviews() {
        super.initializeSubviews()
        isUserInteractionEnabled = false
        processingIV?.animation = Animation.named("Processing")
        if (window?.screen.bounds.height ?? 0) <= 736 {
            containerView.layoutMargins = .init(top: 3, left: 0, bottom: 2, right: 0)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        print("Frame after layout \(frame)")
    }
    
    @IBAction func minimiseAction(sender: UIButton) {
        close?()
    }
    
    public func updateMinimazing() {
        processingIV?.isHidden = isMinimized
    }
    
    public func restartAnimation() {
        processingIV?.play()
        processingIV?.loopMode = .loop
    }
    
    @IBAction func swipeAction(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .down:
            if !isMinimized {
                isMinimized.toggle()
                minimiseAction?(isMinimized)
            }
        case .up:
            if isMinimized {
                isMinimized.toggle()
                minimiseAction?(isMinimized)
            }
        default:
            return
        }
    }
}
