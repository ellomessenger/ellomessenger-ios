import Foundation
import UIKit
import Display
import AsyncDisplayKit
import ElloAppCore
import ElloAppPresentationData
import TextFormat
import ElloAppPermissions
import PeersNearbyIconNode
import SolidRoundedButtonNode
import PresentationDataUtils
import Markdown
import AnimatedStickerNode
import ElloAppAnimatedStickerNode
import AppBundle
import AccountContext
import ElloAppUIPeerInfoItem
import ElloAppPermissionsUI

public enum PeerInfoScreenPermissionItemIcon: Equatable {
    case image(UIImage?)
    case animation(String)
    
    public func imageForTheme(_ theme: PresentationTheme) -> UIImage? {
        switch self {
            case let .image(image):
                return image
            case .animation:
                return nil
        }
    }
}
final class PeerInfoScreenPermissionItem: PeerInfoScreenItem {
    var id: AnyHashable
    let icon: UIImage?
    let title: String
    let text: String
    let buttonTitle: String
    let action: (() -> Void)
    private var theme: PresentationTheme
    private var context: AccountContext
    private var strings: PresentationStrings
    
    init(context: AccountContext, theme: PresentationTheme, strings: PresentationStrings, id: AnyHashable, title: String,  text: String, icon: UIImage? = nil, buttonTitle: String, action: @escaping (() -> Void)) {
        self.id = id
        self.text = text
        self.icon = icon
        self.buttonTitle = buttonTitle
        self.title = title
        self.action = action
        self.context = context
        self.theme = theme
        self.strings = strings
    }
    
    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenPermissionItemNode(context: context, theme: theme, strings: strings, id: id as? Int ?? 0, icon: .image(icon), title: title, text: text, buttonTitle: buttonTitle, buttonAction: action)
    }
}

public final class PeerInfoScreenPermissionItemNode: PeerInfoScreenItemNode {
    private var theme: PresentationTheme
    public let id: Int

    private let iconNode: ASImageNode
    private let titleNode: ImmediateTextNode
    private let textNode: ImmediateTextNode
    private let actionButton: SolidRoundedButtonNode
    private let maskNode: ASImageNode
    
    private let icon: PeerInfoScreenPermissionItemIcon
    private var title: String
    private var text: String
    
    public var buttonAction: (() -> Void)?
    
    public var validLayout: (CGSize, UIEdgeInsets)?
    
    public init(context: AccountContext, theme: PresentationTheme, strings: PresentationStrings, id: Int, icon: PeerInfoScreenPermissionItemIcon, title: String, text: String, buttonTitle: String, buttonAction: @escaping () -> Void) {
        self.theme = theme
        self.id = id
        
        self.buttonAction = buttonAction
        
        self.icon = icon
        self.title = title
        self.text = text
        
        self.iconNode = ASImageNode()
        self.iconNode.isLayerBacked = true
        self.iconNode.displayWithoutProcessing = true
        self.iconNode.displaysAsynchronously = false
        
        self.titleNode = ImmediateTextNode()
        self.titleNode.maximumNumberOfLines = 0
        self.titleNode.textAlignment = .center
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.displaysAsynchronously = false
        
        
        self.textNode = ImmediateTextNode()
        self.textNode.maximumNumberOfLines = 0
        self.textNode.displaysAsynchronously = false
        
        self.actionButton = SolidRoundedButtonNode(theme: SolidRoundedButtonTheme(theme: theme), height: 36, cornerRadius: 6.0, gloss: true)
        
        self.iconNode.image = icon.imageForTheme(theme)
        self.title = title
        
        var secondaryText = false
        if case .animation = icon {
            secondaryText = true
        }
        
        self.textNode.textAlignment = .natural
        
        let body = MarkdownAttributeSet(font: Font.regular(16.0), textColor: theme.list.itemSecondaryTextColor)
        let link = MarkdownAttributeSet(font: Font.regular(16.0), textColor: theme.list.itemAccentColor, additionalAttributes: [ElloAppTextAttributes.URL: ""])
        self.textNode.attributedText = parseMarkdownIntoAttributedString(text.replacingOccurrences(of: "]", with: "]()"), attributes: MarkdownAttributes(body: body, bold: body, link: link, linkAttribute: { _ in nil }), textAlignment: secondaryText ? .natural : .center)
        
        self.maskNode = ASImageNode()
        self.actionButton.title = buttonTitle
        super.init()
        
        self.maskNode.isUserInteractionEnabled = false
        self.addSubnode(self.iconNode)
        self.addSubnode(self.titleNode)
        self.addSubnode(self.textNode)
        self.addSubnode(self.actionButton)
        
        self.actionButton.pressed = { [weak self] in
            self?.buttonAction?()
        }
    }
    
    public func updatePresentationData(_ presentationData: PresentationData) {
        let theme = presentationData.theme
        self.theme = theme
        
        self.iconNode.image = self.icon.imageForTheme(theme)
        
        let body = MarkdownAttributeSet(font: Font.regular(16.0), textColor: theme.list.itemPrimaryTextColor)
        let link = MarkdownAttributeSet(font: Font.regular(16.0), textColor: theme.list.itemAccentColor, additionalAttributes: [ElloAppTextAttributes.URL: ""])
        self.textNode.attributedText = parseMarkdownIntoAttributedString(self.text.replacingOccurrences(of: "]", with: "]()"), attributes: MarkdownAttributes(body: body, bold: body, link: link, linkAttribute: { _ in nil }), textAlignment: .center)
        
        if let validLayout = self.validLayout {
            self.updateLayout(size: validLayout.0, insets: validLayout.1, transition: .immediate)
        }
    }
    
    public func updateLayout(size: CGSize, insets: UIEdgeInsets, transition: ContainedViewLayoutTransition) {
        self.validLayout = (size, insets)
        
        var sidePadding: CGFloat
        let fontSize: CGFloat
        if min(size.width, size.height) > 330.0 {
            fontSize = 24.0
            sidePadding = 16
        } else {
            fontSize = 20.0
            sidePadding = 16
        }
        sidePadding += insets.left
        
        
        self.titleNode.attributedText = NSAttributedString(string: self.title, font: Font.bold(fontSize), textColor: self.theme.list.itemPrimaryTextColor)
        
        let titleSize = self.titleNode.updateLayout(CGSize(width: size.width - sidePadding * 2.0, height: .greatestFiniteMagnitude))
        let textSize = self.textNode.updateLayout(CGSize(width: size.width - sidePadding * 2.0, height: .greatestFiniteMagnitude))
        let buttonWidth = self.actionButton.sizeThatFits(size).width
        let buttonHeight = self.actionButton.updateLayout(width: buttonWidth, transition: transition)
        
        let availableHeight = floor(size.height - insets.top - insets.bottom - titleSize.height - textSize.height - buttonHeight)
        
        let titleTextSpacing: CGFloat = 7
        let buttonSpacing: CGFloat = 10
        var contentHeight = titleSize.height + titleTextSpacing + textSize.height + buttonHeight + buttonSpacing
        
        var imageSize = CGSize()
        var imageSpacing: CGFloat = 0.0
        if let icon = self.iconNode.image, size.width < size.height {
            imageSpacing = floor(availableHeight * 0.12)
            imageSize = icon.size
            contentHeight += imageSize.height + imageSpacing
        }
        
        let contentOrigin = insets.top + floor((size.height - insets.top - insets.bottom - contentHeight) / 2.0)
        let iconFrame = CGRect(origin: CGPoint(x: floor((size.width - imageSize.width) / 2.0), y: contentOrigin), size: imageSize)
        let titleFrame = CGRect(origin: CGPoint(x: floor((size.width - titleSize.width) / 2.0), y: 10), size: titleSize)
        
        let textFrame = CGRect(origin: CGPoint(x: floor((size.width - textSize.width) / 2.0), y: titleTextSpacing + titleFrame.maxY), size: textSize)
        
        let buttonFrame: CGRect
        buttonFrame = CGRect(origin: CGPoint(x: floor((size.width - buttonWidth) / 2.0), y: max(textFrame.maxY + buttonSpacing ,size.height - buttonHeight - insets.bottom - 70.0)), size: CGSize(width: buttonWidth, height: buttonHeight))
        self.maskNode.image = PresentationResourcesItemList.cornersImage(theme, top: true, bottom: true)
        self.maskNode.frame = CGRect(origin: CGPoint(x: 0, y: 0.0), size: CGSize(width: size.width, height: size.height))
        
        if self.maskNode.supernode == nil {
            self.addSubnode(self.maskNode)
        }
        transition.updateFrame(node: self.iconNode, frame: iconFrame)
        transition.updateFrame(node: self.titleNode, frame: titleFrame)
        transition.updateFrame(node: self.textNode, frame: textFrame)
        transition.updateFrame(node: self.actionButton, frame: buttonFrame)
    }
    
    public override func update(width: CGFloat, safeInsets: UIEdgeInsets, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, hasCorners: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        let height: CGFloat = 140
        updateLayout(size: .init(width: width, height: height), insets: .zero, transition: transition)
        return height
    }
}
