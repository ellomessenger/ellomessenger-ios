//
//  PeerInfoScreenItem.swift
//  _idx_ElloAppUI_4E530F7A_ios_min11.0
//
//

import Foundation
import UIKit
import Display
import AsyncDisplayKit
import ElloAppPresentationData

public protocol PeerInfoScreenItem: AnyObject {
    var id: AnyHashable { get }
    func node() -> PeerInfoScreenItemNode
}

open class PeerInfoScreenItemNode: ASDisplayNode, AccessibilityFocusableNode {
    open var bringToFrontForHighlight: (() -> Void)?
    
    open func update(width: CGFloat, safeInsets: UIEdgeInsets, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, hasCorners: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        preconditionFailure()
    }
    
    override open func accessibilityElementDidBecomeFocused() {
        //        (self.supernode as? ListView)?.ensureItemNodeVisible(self, animated: false, overflow: 22.0)
    }
}
