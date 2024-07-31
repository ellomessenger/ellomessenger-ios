//
//  PeerInfoItemQR.swift
//  _idx_ELProfileUI_0B89BFFD_ios_min11.0
//
//

import ElloAppUIPeerInfoItem
import ElloAppPresentationData
import ELBase
import Display
import UIKit

public class PeerInfoItemQR: PeerInfoScreenItem {
    
    public let id: AnyHashable
    
    let link: String
    let action: EventClosure<String>?
    let copyAction: EventClosure<String>?
    let shareAction: EventClosure<String>?
    let isButtonsHidden:Bool
    let name: String?

    public init(id: AnyHashable, 
                link: String,
                isButtonsHidden:Bool = false,
                action: EventClosure<String>? = nil,
                copyAction: EventClosure<String>? = nil,
                shareAction: EventClosure<String>? = nil,
                name:String? = nil) {
        self.id = id
        self.link = link
        self.action = action
        self.copyAction = copyAction
        self.shareAction = shareAction
        self.isButtonsHidden = isButtonsHidden
        self.name = name
    }
    
    public func node() -> PeerInfoScreenItemNode {
        return PeerInfoItemQRNode()
    }
}

private class PeerInfoItemQRNode: PeerInfoScreenItemNode {
    
    private var item: PeerInfoItemQR?
    private let maskNode: ASImageNode
    
    private let uiview: ProfileItemQRView
    
    override init() {
        self.maskNode = ASImageNode()
        self.maskNode.isUserInteractionEnabled = false
        
        self.uiview = ProfileItemQRView()
        
        super.init()
        self.addSubnode(self.maskNode)
        
        self.view.addSubviewWithSameSize(self.uiview)
    }
    
    override func update(width: CGFloat, 
                         safeInsets: UIEdgeInsets,
                         presentationData: PresentationData,
                         item: PeerInfoScreenItem,
                         topItem: PeerInfoScreenItem?,
                         bottomItem: PeerInfoScreenItem?,
                         hasCorners: Bool,
                         transition: ContainedViewLayoutTransition) -> CGFloat {
        guard let item = item as? PeerInfoItemQR else {
            return 10.0
        }
        
        self.uiview.name = item.name
        self.uiview.link = item.link
        self.uiview.onTap = {
            item.action?($0)
        }
        
        self.uiview.onCopy = {
            item.copyAction?($0)
        }
        
        self.uiview.onShare = {
            item.shareAction?($0)
        }
        
        self.item = item
        
        self.uiview.resizeButtons(isHidden: item.isButtonsHidden)
        
        let height = self.uiview.frame.height
        
        //round cornenrs
        let hasCorners = hasCorners && (topItem == nil || bottomItem == nil)
        let hasTopCorners = hasCorners && topItem == nil
        let hasBottomCorners = hasCorners && bottomItem == nil
        
        self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(presentationData.theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
        self.maskNode.frame = CGRect(origin: CGPoint(x: safeInsets.left, y: 0.0), size: CGSize(width: width - safeInsets.left - safeInsets.right, height: height))
        
        return height
    }
}
