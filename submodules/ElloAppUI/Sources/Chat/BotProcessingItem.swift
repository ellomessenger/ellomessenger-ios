//
//  BotProcessingItem.swift
//  _idx_ELCommonUI_F0C2D3F9_ios_min14.0
//
//

import ElloAppUIPeerInfoItem
import ElloAppPresentationData
import ELBase
import Display
import AsyncDisplayKit
import UIKit
import ELCommonUI

public class BotProcessingItem {
    
    public let id: AnyHashable
    
    let close: VoidClosure?
    let minimizeAction: EventClosure<Bool>?
    
    public init(id: AnyHashable, link: String, closeAction: VoidClosure? = nil, minimizeAction: EventClosure<Bool>?) {
        self.id = id
        self.close = closeAction
        self.minimizeAction = minimizeAction
    }
    
    public func node() -> BotProcessingItemNode {
        let node = BotProcessingItemNode()
        node.updateItem(self)
        return node
    }
}

public class BotProcessingItemNode: ASDisplayNode {
    
    private var item: BotProcessingItem?
    
    private let uiview: BotProcessingView
    
    public var isMinimized: Bool {
        uiview.isMinimized
    }
    
    override init() {
        self.uiview = BotProcessingView()
        super.init()
        
        
        self.uiview.close = { [weak self] in
            self?.item?.close?()
        }
        self.view.addSubview(uiview)
    }
    
    func updateItem(_ item: BotProcessingItem) {
        self.item = item
        self.uiview.close = {
            item.close?()
        }
        self.uiview.minimiseAction = item.minimizeAction
    }
    
    public func restartAnimation() {
        uiview.restartAnimation()
    }
    
    public func updateViewFrameOnAppearing() {
        uiview.frame = bounds
    }
    
    func animateFrameChange(transition: ContainedViewLayoutTransition, frame: CGRect) {
        if case .animated = transition {
            let isExpanding = frame.size.height > bounds.size.height
            transition.updateFrame(node: self, frame: frame, delay: 0.2) { isFinished in
                if !isExpanding {
                    transition.updateFrameAdditive(view: self.uiview, frame: self.bounds)
                    self.uiview.updateMinimazing()
                }
            }
            if isExpanding {
                transition.updateFrameAdditive(view: uiview, frame: bounds)
                uiview.updateMinimazing()
            }
        }
    }
}

