//
//  PeerInfoScreenQRItem.swift
//  _idx_ElloAppUI_62946EB7_ios_min11.0
//
//

import AsyncDisplayKit
import Display
import ElloAppPresentationData
import AccountContext
import TextFormat
import UIKit
import AppBundle
import ElloAppStringFormatting
import ContextUI
import ElloAppUIPeerInfoItem


final class PeerInfoScreenQRItem: PeerInfoScreenItem {
    let id: AnyHashable
    let label: String
    let text: String
    let textColor: PeerInfoScreenLabeledValueTextColor
    let action: (() -> Void)?
    let copyAction: (()->())?
    let shareAction: (()->())?
    
    init(
        id: AnyHashable,
        label: String,
        text: String,
        textColor: PeerInfoScreenLabeledValueTextColor = .primary,
        icon: PeerInfoScreenLabeledValueIcon? = nil,
        action: (() -> Void)?,
        copy: (()->())?,
        share: (()->())?
    ) {
        self.id = id
        self.label = label
        self.text = text
        self.textColor = textColor
        self.action = action
        self.copyAction = copy
        self.shareAction = share
    }
    
    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenQRNode()
    }
}

private final class PeerInfoScreenQRNode: PeerInfoScreenItemNode {
    private let extractedBackgroundImageNode: ASImageNode
    
    private var extractedRect: CGRect?
    private var nonExtractedRect: CGRect?
    
    private let selectionNode: PeerInfoScreenSelectableBackgroundNode
    private let maskNode: ASImageNode
    private let labelNode: ImmediateTextNode
    private let textNode: ImmediateTextNode
    private let bottomSeparatorNode: ASDisplayNode
    
    private let horDivider: ASDisplayNode
    private let vertDivider: ASDisplayNode
    private let copyLinkImageNode: ASImageNode
    private let copyLinkTitleNode: ImmediateTextNode
    private let shareLinkImageNode: ASImageNode
    private let shareLinkTitleNode: ImmediateTextNode
    
    
    private let iconNode: ASImageNode
    private let iconButtonNode: HighlightTrackingButtonNode
    
    private var linkHighlightingNode: LinkHighlightingNode?
    
    private let activateArea: AccessibilityAreaNode
    
    private var item: PeerInfoScreenQRItem?
    private var theme: PresentationTheme?
    
    private var isExpanded: Bool = false
    
    override init() {
        var bringToFrontForHighlightImpl: (() -> Void)?
        
        self.extractedBackgroundImageNode = ASImageNode()
        self.extractedBackgroundImageNode.displaysAsynchronously = false
        self.extractedBackgroundImageNode.alpha = 0.0
        
        self.selectionNode = PeerInfoScreenSelectableBackgroundNode(bringToFrontForHighlight: { bringToFrontForHighlightImpl?() })
        self.selectionNode.isUserInteractionEnabled = true
        
        self.maskNode = ASImageNode()
        self.maskNode.isUserInteractionEnabled = false
        
        self.labelNode = ImmediateTextNode()
        self.labelNode.displaysAsynchronously = false
        self.labelNode.isUserInteractionEnabled = false
        
        self.textNode = ImmediateTextNode()
        self.textNode.displaysAsynchronously = false
        self.textNode.isUserInteractionEnabled = false
        
        self.bottomSeparatorNode = ASDisplayNode()
        self.bottomSeparatorNode.isLayerBacked = true
        
        self.horDivider = ASDisplayNode()
        self.horDivider.isLayerBacked = true
        
        self.vertDivider = ASDisplayNode()
        self.vertDivider.isLayerBacked = true
        
        self.copyLinkImageNode = ASImageNode()
        self.copyLinkImageNode.isUserInteractionEnabled = false
        
        self.copyLinkTitleNode = ImmediateTextNode()
        self.copyLinkTitleNode.displaysAsynchronously = false
        
        self.shareLinkImageNode = ASImageNode()
        self.shareLinkImageNode.isUserInteractionEnabled = false
        
        self.shareLinkTitleNode = ImmediateTextNode()
        self.shareLinkTitleNode.displaysAsynchronously = false
        
        
        self.iconNode = ASImageNode()
        self.iconNode.contentMode = .center
        self.iconNode.displaysAsynchronously = false
        
        self.iconButtonNode = HighlightTrackingButtonNode()
        
        self.activateArea = AccessibilityAreaNode()
        
        super.init()
        
        bringToFrontForHighlightImpl = { [weak self] in
            self?.bringToFrontForHighlight?()
        }
        
        self.addSubnode(self.bottomSeparatorNode)
        self.addSubnode(self.selectionNode)
        
        self.addSubnode(self.maskNode)
        

        self.addSubnode(self.extractedBackgroundImageNode)
        
        self.addSubnode(self.labelNode)
        self.addSubnode(self.textNode)
        
        self.addSubnode(self.iconNode)
        self.addSubnode(self.iconButtonNode)
        
        self.addSubnode(self.vertDivider)
        self.addSubnode(self.horDivider)
        
        self.addSubnode(self.copyLinkImageNode)
        self.addSubnode(self.copyLinkTitleNode)
        
        self.addSubnode(self.shareLinkImageNode)
        self.addSubnode(self.shareLinkTitleNode)
        
        self.addSubnode(self.activateArea)
        
    }
    
    override func update(width: CGFloat, safeInsets: UIEdgeInsets, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, hasCorners: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        guard let item = item as? PeerInfoScreenQRItem else {
            return 10.0
        }
        
        self.item = item
        self.theme = presentationData.theme
        
        self.selectionNode.pressed = item.action

        
        let sideInset: CGFloat = 16.0 + safeInsets.left
        
        self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        self.horDivider.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        self.vertDivider.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        
        let textColorValue: UIColor
        switch item.textColor {
            case .primary:
                textColorValue = presentationData.theme.list.itemPrimaryTextColor
            case .accent:
                textColorValue = presentationData.theme.list.itemAccentColor
        }
                
        self.labelNode.attributedText = NSAttributedString(string: item.label, font: Font.regular(14.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
        
        let iconImage = UIImage(bundleImageName: "Settings/QrIcon")
        self.iconNode.image = generateTintedImage(image: iconImage, color: presentationData.theme.list.itemAccentColor)
        self.iconNode.isHidden = false
        self.iconButtonNode.isHidden = false

        
        let additionalSideInset: CGFloat = !self.iconNode.isHidden ? 32.0 : 0.0
        let additionalHeight: CGFloat = 54
        
        self.textNode.maximumNumberOfLines = 1
        self.textNode.cutout = nil
        self.textNode.attributedText = NSAttributedString(string: item.text, font: Font.regular(17.0), textColor: textColorValue)
        
        self.horDivider.frame =  CGRect(origin: CGPoint(x: 0, y: textNode.frame.maxY + 8), size: CGSize(width: width, height: UIScreenPixel))
        self.vertDivider.frame = CGRect(origin: CGPoint(x: width/2-UIScreenPixel, y: textNode.frame.maxY + 8), size: CGSize(width: UIScreenPixel, height: additionalHeight+sideInset))
        
        let textColor: UIColor = presentationData.theme.list.itemAccentColor
        self.copyLinkImageNode.image = UIImage(bundleImageName: "Chat/Context Menu/Copy")
        self.copyLinkImageNode.frame = CGRect(x: sideInset + 10, y: textNode.frame.maxY + (additionalHeight / 2), width: 18, height: 18)
        
        self.copyLinkTitleNode.attributedText = NSAttributedString(string: "Copy", font: Font.regular(17.0), textColor: textColor)
        let _ = self.copyLinkTitleNode.updateLayout(CGSize(width: width - sideInset * 2.0, height: .greatestFiniteMagnitude))
        self.copyLinkTitleNode.frame = CGRect(x: copyLinkImageNode.frame.maxX + 8, y: copyLinkImageNode.frame.minY , width: width/2, height: 24)
        
        self.shareLinkImageNode.image = UIImage(bundleImageName: "Chat/Context Menu/Share")
        self.shareLinkImageNode.frame = CGRect(x: width / 2 + 10, y: textNode.frame.maxY + (additionalHeight / 2), width: 18, height: 18)
        
        self.shareLinkTitleNode.attributedText = NSAttributedString(string: "Share", font: Font.regular(17.0), textColor: textColor)
        let _ = self.shareLinkTitleNode.updateLayout(CGSize(width: width - sideInset * 2.0, height: .greatestFiniteMagnitude))
        self.shareLinkTitleNode.frame = CGRect(x: shareLinkImageNode.frame.maxX + 8, y: shareLinkImageNode.frame.minY , width: width/2, height: 24)
        
        
        let labelSize = self.labelNode.updateLayout(CGSize(width: width - sideInset * 2.0, height: .greatestFiniteMagnitude))
        let textLayout = self.textNode.updateLayoutInfo(CGSize(width: width - sideInset * 2.0 - additionalSideInset, height: .greatestFiniteMagnitude))
        let textSize = textLayout.size
        
        let additionalTextSize = CGSize(width: 0, height: 54) //self.additionalTextNode.updateLayout(CGSize(width: width - sideInset * 2.0, height: .greatestFiniteMagnitude))
        
        
        let labelFrame = CGRect(origin: CGPoint(x: sideInset, y: 11.0), size: labelSize)
        let textFrame = CGRect(origin: CGPoint(x: sideInset, y: labelFrame.maxY + 3.0), size: textSize)
        let _ = CGRect(origin: CGPoint(x: sideInset, y: textFrame.maxY + 3.0), size: additionalTextSize)
        
        
                
        transition.updateFrame(node: self.labelNode, frame: labelFrame)
        
        var textTransition = transition
        if self.textNode.frame.size != textFrame.size {
            textTransition = .immediate
        }
        textTransition.updateFrame(node: self.textNode, frame: textFrame)
                
        var height = labelSize.height + 3.0 + textSize.height + 22.0
        
        let iconButtonFrame = CGRect(x: width - safeInsets.right - height, y: 0.0, width: height, height: height)
        transition.updateFrame(node: self.iconButtonNode, frame: iconButtonFrame)
        if let iconSize = self.iconNode.image?.size {
            transition.updateFrame(node: self.iconNode, frame: CGRect(origin: CGPoint(x: width - safeInsets.right - sideInset - iconSize.width + 5.0, y: floorToScreenPixels((height - iconSize.height) / 2.0)), size: iconSize))
        }
        
        if additionalTextSize.height > 0.0 {
            height += additionalTextSize.height + 3.0
        }
        
        let highlightNodeOffset: CGFloat = topItem == nil ? 0.0 : UIScreenPixel
        self.selectionNode.update(size: CGSize(width: width, height: height + highlightNodeOffset), theme: presentationData.theme, transition: transition)
        transition.updateFrame(node: self.selectionNode, frame: CGRect(origin: CGPoint(x: 0.0, y: -highlightNodeOffset), size: CGSize(width: width, height: height + highlightNodeOffset)))
        
        transition.updateFrame(node: self.bottomSeparatorNode, frame: CGRect(origin: CGPoint(x: sideInset, y: height - UIScreenPixel), size: CGSize(width: width - sideInset, height: UIScreenPixel)))
        transition.updateAlpha(node: self.bottomSeparatorNode, alpha: bottomItem == nil ? 0.0 : 1.0)
        
        let hasCorners = hasCorners && (topItem == nil || bottomItem == nil)
        let hasTopCorners = hasCorners && topItem == nil
        let hasBottomCorners = hasCorners && bottomItem == nil
        
        self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(presentationData.theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
        self.maskNode.frame = CGRect(origin: CGPoint(x: safeInsets.left, y: 0.0), size: CGSize(width: width - safeInsets.left - safeInsets.right, height: height))
        self.bottomSeparatorNode.isHidden = hasBottomCorners
        
        self.activateArea.frame = CGRect(origin: CGPoint(), size: CGSize(width: width, height: height))
        self.activateArea.accessibilityLabel = item.text
//        self.activateArea.accessibilityValue = item.text

        return height
    }
}
