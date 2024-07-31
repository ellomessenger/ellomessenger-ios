//
//  AdaptingControllerNode.swift
//  _idx_ELProfileUI_3402FF40_ios_min11.0
//
//

import UIKit
import AsyncDisplayKit
import Display
import ElloAppPresentationData

final class AdaptingControllerNode: ASDisplayNode {
    init(theme: PresentationTheme? = nil) {
        super.init()
        
//        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.bounds.height)
        
        self.setViewBlock({
            return UITracingLayerView()
        })

//        self.backgroundColor = theme.list.plainBackgroundColor
        self.view.disablesInteractiveTransitionGestureRecognizer = true
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        
    }
}
