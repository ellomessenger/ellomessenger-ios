//
//  PeerInfoItemSwitch.swift
//  _idx_ELProfileUI_0B89BFFD_ios_min11.0
//
//

import ElloAppUIPeerInfoItem
import ElloAppPresentationData
import ELBase
import Display
import AsyncDisplayKit
import UIKit

public class PeerInfoItemSwitch: PeerInfoScreenItem {
    
    public let id: AnyHashable
    
    let title: String
    let value: Bool
    let changed: EventClosure<Bool>?
    
    public init(id: AnyHashable, title: String, value:Bool = false, changed: EventClosure<Bool>? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.changed = changed
    }
    
    public func node() -> PeerInfoScreenItemNode {
        return PeerInfoItemSwitchNode()
    }
}

private class PeerInfoItemSwitchNode: PeerInfoScreenItemNode {
    
    private var item: PeerInfoItemSwitch?
    private let maskNode: ASImageNode
    private let bottomSeparatorNode: ASDisplayNode

    private let uiview: ProfileItemSwitchView
    
    override init() {
        self.maskNode = ASImageNode()
        self.maskNode.isUserInteractionEnabled = false
        
        self.bottomSeparatorNode = ASDisplayNode()
        self.bottomSeparatorNode.isLayerBacked = true
        
        self.uiview = ProfileItemSwitchView()
        
        super.init()
        self.addSubnode(self.maskNode)

        self.view.addSubviewWithSameSize(self.uiview)
        self.addSubnode(self.bottomSeparatorNode)
    }
    
    override func update(width: CGFloat, safeInsets: UIEdgeInsets, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, hasCorners: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        guard let item = item as? PeerInfoItemSwitch else {
            return 10.0
        }
        
        self.uiview.title = item.title
        self.uiview.onChange = {
            item.changed?($0)
        }
        
        self.item = item
        
        let height = self.uiview.frame.height
        
        //round cornenrs
        let hasCorners = hasCorners && (topItem == nil || bottomItem == nil)
        let hasTopCorners = hasCorners && topItem == nil
        let hasBottomCorners = hasCorners && bottomItem == nil
        
        self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(presentationData.theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
        self.maskNode.frame = CGRect(origin: CGPoint(x: safeInsets.left, y: 0.0), size: CGSize(width: width - safeInsets.left - safeInsets.right, height: height))
        
        let sideInset: CGFloat = 16.0 + safeInsets.left
        self.bottomSeparatorNode.isHidden = hasBottomCorners
        self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        transition.updateFrame(node: self.bottomSeparatorNode, frame: CGRect(origin: CGPoint(x: sideInset, y: height - UIScreenPixel), size: CGSize(width: width - sideInset, height: UIScreenPixel)))
        
        return height
    }
}
