//
//  PeerInfoScreenCostItem.swift
//  _idx_Lib_ElloAppUI_7D3C161C_ios_min14.0
//
//

import AsyncDisplayKit
import Display
import ElloAppPresentationData
import ElloAppUIPeerInfoItem
import AppBundle

final class PeerInfoScreenCostItem: PeerInfoScreenItem {
    enum Label {
        case none
        case text(String)
        case badge(String, UIColor)
        case status(String, String, UIColor)
        case textWithImage(String, UIImage?)
        
        var text: String {
            switch self {
            case .none:
                return ""
            case let .text(text), let .badge(text, _), let .status(_, text, _), let .textWithImage(text, _):
                return text
            }
        }
        
        var badgeColor: UIColor? {
            switch self {
            case .none, .text, .textWithImage:
                return nil
            case let .badge(_, color):
                return color
            case let .status(_, _, color):
                return color
            }
        }
        
        var status: String {
            switch self {
            case let .status(status, _, _):
                return status
            default:
                return ""
            }
        }
        
        var image: UIImage? {
            switch self {
            case let .textWithImage(_, image):
                return image
            default:
                return nil
            }
        }
    }
    
    let id: AnyHashable
    let label: Label
    let text: String
    let icon: UIImage?
    let action: (() -> Void)?
    
    init(id: AnyHashable, label: Label = .none, text: String, icon: UIImage? = nil, action: (() -> Void)?) {
        self.id = id
        self.label = label
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenCostItemNode()
    }
}

private final class PeerInfoScreenCostItemNode: PeerInfoScreenItemNode {
    private let selectionNode: PeerInfoScreenSelectableBackgroundNode
    private let maskNode: ASImageNode
    private let iconNode: ASImageNode
    private let labelBadgeNode: ASImageNode
    private let labelNode: ImmediateTextNode
    private let textNode: ImmediateTextNode
    private let coinIconNode: ASImageNode
    private let arrowNode: ASImageNode
    private let bottomSeparatorNode: ASDisplayNode
    private let activateArea: AccessibilityAreaNode
    
    private var item: PeerInfoScreenCostItem?
    
    override init() {
        var bringToFrontForHighlightImpl: (() -> Void)?
        self.selectionNode = PeerInfoScreenSelectableBackgroundNode(bringToFrontForHighlight: { bringToFrontForHighlightImpl?() })
        
        self.maskNode = ASImageNode()
        self.maskNode.isUserInteractionEnabled = false
        
        self.iconNode = ASImageNode()
        self.iconNode.isLayerBacked = true
        self.iconNode.displaysAsynchronously = false
        
        self.labelBadgeNode = ASImageNode()
        self.labelBadgeNode.displayWithoutProcessing = true
        self.labelBadgeNode.displaysAsynchronously = false
        self.labelBadgeNode.isLayerBacked = true
        
        self.labelNode = ImmediateTextNode()
        self.labelNode.displaysAsynchronously = false
        self.labelNode.isUserInteractionEnabled = false
        
        self.textNode = ImmediateTextNode()
        self.textNode.displaysAsynchronously = false
        self.textNode.isUserInteractionEnabled = false
        
        self.coinIconNode = ASImageNode()
        self.coinIconNode.displayWithoutProcessing = true
        self.coinIconNode.displaysAsynchronously = false
        self.coinIconNode.isLayerBacked = true
        
        self.arrowNode = ASImageNode()
        self.arrowNode.isLayerBacked = true
        self.arrowNode.displaysAsynchronously = false
        self.arrowNode.displayWithoutProcessing = true
        self.arrowNode.isUserInteractionEnabled = false
        
        self.bottomSeparatorNode = ASDisplayNode()
        self.bottomSeparatorNode.isLayerBacked = true
        
        self.activateArea = AccessibilityAreaNode()
        
        super.init()
        
        bringToFrontForHighlightImpl = { [weak self] in
            self?.bringToFrontForHighlight?()
        }
        
        self.addSubnode(self.bottomSeparatorNode)
        self.addSubnode(self.selectionNode)
        self.addSubnode(self.maskNode)
        self.addSubnode(self.labelNode)
        self.addSubnode(self.textNode)
        self.addSubnode(self.coinIconNode)
        self.addSubnode(self.arrowNode)
        self.addSubnode(self.activateArea)
    }
    
    override func update(width: CGFloat, safeInsets: UIEdgeInsets, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, hasCorners: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        guard let item = item as? PeerInfoScreenCostItem else {
            return 10.0
        }
        
        let previousItem = self.item
        self.item = item
        
        self.selectionNode.pressed = item.action
        
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let sideInset: CGFloat = 16.0 + safeInsets.left
        let iconRightSpace = 12.0
        let leftInset = (item.icon == nil ? sideInset : sideInset + iconSize.width + iconRightSpace)
        let rightInset = sideInset
        let separatorInset = item.icon == nil ? sideInset : leftInset - 1.0 + iconRightSpace
        let titleFont = Font.regular(15.0)
        let coinImageSize = CGSize(width: 18.0, height: 18.0)
        
        self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
                
        let textColorValue = presentationData.theme.list.itemPrimaryTextColor
        let labelColorValue = presentationData.theme.list.itemPrimaryTextColor
        let labelFont: UIFont = Font.medium(15.0)
        
        self.textNode.maximumNumberOfLines = 1
        if item.label.status.isEmpty {
            self.labelNode.attributedText = NSAttributedString(string: item.label.text, font: labelFont, textColor: labelColorValue)
            self.textNode.attributedText = NSAttributedString(string: item.text, font: titleFont, textColor: textColorValue)
        } else {
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: item.label.status, font: labelFont, textColor: item.label.badgeColor ?? .black))
            text.append(NSAttributedString(string: " • \(item.label.text)", font: labelFont, textColor: labelColorValue))
            self.labelNode.attributedText = text
            self.textNode.attributedText = text
        }
        
        if item.label.image != nil {
            self.coinIconNode.image = item.label.image
        } else {
            self.coinIconNode.image = nil
        }
        
        
        let textSize = self.textNode.updateLayout(CGSize(width: width - (leftInset + rightInset), height: .greatestFiniteMagnitude))
        let labelSize = self.labelNode.updateLayout(CGSize(width: width - textSize.width - (leftInset + rightInset), height: .greatestFiniteMagnitude))
        
        let textFrame = CGRect(origin: CGPoint(x: leftInset, y: 16.0), size: textSize)
        
        let height = textSize.height + 32.0
        
        if let icon = item.icon {
            if self.iconNode.supernode == nil {
                self.addSubnode(self.iconNode)
            }
            self.iconNode.image = generateTintedImage(image: icon, color: UIColor(bundleColorName: "IconsBlue") ?? .black)
            let iconFrame = CGRect(origin: CGPoint(x: sideInset, y: floorToScreenPixels((height - iconSize.height) / 2.0)), size: iconSize)
            transition.updateFrame(node: self.iconNode, frame: iconFrame)
        } else if self.iconNode.supernode != nil {
            self.iconNode.image = nil
            self.iconNode.removeFromSupernode()
        }
        
        let badgeDiameter: CGFloat = 20.0
        if case let .badge(text, badgeColor) = item.label, !text.isEmpty {
            if previousItem?.label.badgeColor != badgeColor {
                self.labelBadgeNode.image = generateStretchableFilledCircleImage(diameter: badgeDiameter, color: badgeColor)
            }
            if self.labelBadgeNode.supernode == nil {
                self.insertSubnode(self.labelBadgeNode, belowSubnode: self.labelNode)
            }
        } else {
            self.labelBadgeNode.removeFromSupernode()
        }
        
        let badgeWidth = max(badgeDiameter, labelSize.width + 10.0)
        let labelFrame: CGRect
        if case .badge = item.label {
            labelFrame = CGRect(origin: CGPoint(x: width - rightInset - badgeWidth + (badgeWidth - labelSize.width) / 2.0, y: floor((height - labelSize.height) / 2.0)), size: labelSize)
        } else {
            labelFrame = CGRect(origin: CGPoint(x: width - rightInset - labelSize.width, y: 16.0), size: labelSize)
        }
        
        let labelBadgeNodeFrame = CGRect(origin: CGPoint(x: width - rightInset - badgeWidth, y: labelFrame.minY - 1.0), size: CGSize(width: badgeWidth, height: badgeDiameter))
        
        self.activateArea.accessibilityLabel = item.text
        self.activateArea.accessibilityValue = item.label.text
        
        transition.updateFrame(node: self.labelBadgeNode, frame: labelBadgeNodeFrame)
        if self.labelNode.bounds.size != labelFrame.size {
            self.labelNode.frame = labelFrame
        } else {
            transition.updateFrame(node: self.labelNode, frame: labelFrame)
        }
        transition.updateFrame(node: self.textNode, frame: textFrame)
        transition.updateFrame(
            node: self.coinIconNode,
            frame: CGRect(
                origin: CGPoint(
                    x: labelFrame.minX - 8.0 - coinImageSize.width,
                    y: labelFrame.midY - coinImageSize.height / 2.0),
                size: coinImageSize))
        let hasCorners = hasCorners && (topItem == nil || bottomItem == nil)
        let hasTopCorners = hasCorners && topItem == nil
        let hasBottomCorners = hasCorners && bottomItem == nil
        
        self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(presentationData.theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
        self.maskNode.frame = CGRect(origin: CGPoint(x: safeInsets.left, y: 0.0), size: CGSize(width: width - safeInsets.left - safeInsets.right, height: height))
        self.bottomSeparatorNode.isHidden = hasBottomCorners
        
        let highlightNodeOffset: CGFloat = topItem == nil ? 0.0 : UIScreenPixel
        self.selectionNode.update(size: CGSize(width: width, height: height + highlightNodeOffset), theme: presentationData.theme, transition: transition)
        transition.updateFrame(node: self.selectionNode, frame: CGRect(origin: CGPoint(x: 0.0, y: -highlightNodeOffset), size: CGSize(width: width, height: height + highlightNodeOffset)))
        
        transition.updateFrame(node: self.bottomSeparatorNode, frame: CGRect(origin: CGPoint(x: separatorInset, y: height - UIScreenPixel), size: CGSize(width: width - separatorInset, height: UIScreenPixel)))
        transition.updateAlpha(node: self.bottomSeparatorNode, alpha: bottomItem == nil ? 0.0 : 1.0)
        
        self.activateArea.frame = CGRect(origin: CGPoint(x: safeInsets.left, y: 0.0), size: CGSize(width: width - safeInsets.left - safeInsets.right, height: height))
        
        return height
    }
}
