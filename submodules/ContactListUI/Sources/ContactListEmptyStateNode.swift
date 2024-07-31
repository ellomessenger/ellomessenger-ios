import Foundation
import AnimationUI
import ElloAppPermissionsUI
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

public final class ContactListEmptyStateNode: ASDisplayNode {
    private var theme: PresentationTheme
    public let kind: Int32
    
    private let iconNode: ASImageNode
    private let nearbyIconNode: PeersNearbyIconNode?
    private let animationNode: AnimationNode?
    private let titleNode: ImmediateTextNode
    private let textNode: ImmediateTextNode
    private let promoButtonNode: SolidRoundedButtonNode?
    
    private let icon: PermissionContentIcon
    private var title: String
    private var text: String
    private let showPromoButton: Bool
    
    public var validLayout: (CGSize, UIEdgeInsets)?
    
    public init(context: AccountContext, theme: PresentationTheme, strings: PresentationStrings, kind: Int32, icon: PermissionContentIcon, title: String, text: String, showPromoButton: Bool = false) {
        self.theme = theme
        self.kind = kind
        
        self.icon = icon
        self.title = title
        self.text = text
        self.showPromoButton = showPromoButton
        
        self.iconNode = ASImageNode()
        self.iconNode.isLayerBacked = true
        self.iconNode.displayWithoutProcessing = true
        self.iconNode.displaysAsynchronously = false
        
        if case let .animation(animation) = icon {
            self.animationNode = AnimationNode(animation: animation)
            self.animationNode?.loop()
            
            self.nearbyIconNode = nil
        } else if kind == PermissionKind.nearbyLocation.rawValue {
            self.nearbyIconNode = PeersNearbyIconNode(theme: theme)
            self.animationNode = nil
        } else {
            self.nearbyIconNode = nil
            self.animationNode = nil
        }
        
        self.titleNode = ImmediateTextNode()
        self.titleNode.maximumNumberOfLines = 0
        self.titleNode.textAlignment = .center
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.displaysAsynchronously = false
        
        self.textNode = ImmediateTextNode()
        self.textNode.maximumNumberOfLines = 0
        self.textNode.textAlignment = .natural
        self.textNode.displaysAsynchronously = false
        
        self.promoButtonNode = if showPromoButton {
            SolidRoundedButtonNode(
                theme: SolidRoundedButtonTheme(theme: theme),
                font: .bold,
                fontSize: 15.0,
                height: 57.0,
                cornerRadius: 18,
                gloss: false)
        } else {
            nil
        }
        
        super.init()
        
        self.iconNode.image = icon.imageForTheme(theme)
        self.title = title
        
        let body = MarkdownAttributeSet(font: Font.regular(16.0), textColor: UIColor(hexString: "#929298") ?? theme.list.itemPrimaryTextColor)
        let link = MarkdownAttributeSet(font: Font.regular(16.0), textColor: theme.list.itemAccentColor, additionalAttributes: [ElloAppTextAttributes.URL: ""])
        self.textNode.attributedText = parseMarkdownIntoAttributedString(text.replacingOccurrences(of: "]", with: "]()"), attributes: MarkdownAttributes(body: body, bold: body, link: link, linkAttribute: { _ in nil }), textAlignment: .natural)
        self.promoButtonNode?.title = strings.Contacts_CreatePublicChannel_EmptyState_PromoButton_Title
        
        self.addSubnode(self.iconNode)
        self.nearbyIconNode.flatMap { self.addSubnode($0) }
        self.animationNode.flatMap { self.addSubnode($0) }
        self.addSubnode(self.titleNode)
        self.addSubnode(self.textNode)
        self.promoButtonNode.map { self.addSubnode($0) }
        
        self.promoButtonNode?.pressed = { [weak self] in
            self?.buttonAction()
        }
    }
    
    public func updatePresentationData(_ presentationData: PresentationData) {
        let theme = presentationData.theme
        self.theme = theme
        
        self.iconNode.image = self.icon.imageForTheme(theme)
        
        let body = MarkdownAttributeSet(font: Font.regular(16.0), textColor: UIColor(hexString: "#929298") ?? theme.list.itemPrimaryTextColor)
        let link = MarkdownAttributeSet(font: Font.regular(16.0), textColor: theme.list.itemAccentColor, additionalAttributes: [ElloAppTextAttributes.URL: ""])
        self.textNode.attributedText = parseMarkdownIntoAttributedString(self.text.replacingOccurrences(of: "]", with: "]()"), attributes: MarkdownAttributes(body: body, bold: body, link: link, linkAttribute: { _ in nil }), textAlignment: .natural)
        
        if let validLayout = self.validLayout {
            self.updateLayout(size: validLayout.0, insets: validLayout.1, transition: .immediate)
        }
    }
    
    public func updateLayout(
        size: CGSize,
        additionalInsets: UIEdgeInsets = UIEdgeInsets.zero,
        insets: UIEdgeInsets,
        transition: ContainedViewLayoutTransition
    ) {
        let size = CGSize(width: size.width, height: size.height - additionalInsets.bottom)
        
        self.validLayout = (size, insets)
        
        let sidePadding = 16.0 + insets.left
        let fontSize: CGFloat
        if min(size.width, size.height) > 330.0 {
            fontSize = 24.0
        } else {
            fontSize = 20.0
        }
        
        self.titleNode.attributedText = NSAttributedString(string: self.title, font: Font.bold(fontSize), textColor: self.theme.list.itemPrimaryTextColor)
        
        let titleSize = self.titleNode.updateLayout(CGSize(width: size.width - sidePadding * 2.0, height: .greatestFiniteMagnitude))
        let textSize = self.textNode.updateLayout(CGSize(width: size.width - sidePadding * 2.0, height: .greatestFiniteMagnitude))
        
        let buttonSize: CGSize = if showPromoButton {
            CGSizeMake(size.width - sidePadding * 2.0, 57.0)
        } else {
            .zero
        }
        
        let availableHeight = floor(size.height - insets.top - insets.bottom - titleSize.height - textSize.height - buttonSize.height)
        
        let titleTextSpacing: CGFloat = 16.0 // max(15.0, floor(availableHeight * 0.045))
        var contentHeight = titleSize.height + titleTextSpacing + textSize.height
        promoButtonNode.map { _ in contentHeight += titleTextSpacing + buttonSize.height }
        
        var imageSize = CGSize()
        var imageSpacing: CGFloat = 0.0
        if let icon = self.iconNode.image, size.width < size.height {
            imageSpacing = floor(availableHeight * 0.12)
            imageSize = icon.size
            contentHeight += imageSize.height + imageSpacing
        }
        if let _ = self.nearbyIconNode, size.width < size.height {
            imageSpacing = floor(availableHeight * 0.12)
            imageSize = CGSize(width: 120.0, height: 120.0)
            contentHeight += imageSize.height + imageSpacing
        }
        if let _ = self.animationNode, size.width < size.height {
            imageSpacing = floor(availableHeight * 0.12)
            imageSize = CGSize(width: 160.0, height: 160.0)
            contentHeight += imageSize.height + imageSpacing
        }
        
        var verticalOffset: CGFloat = 0.0
        if size.height >= 568.0 {
            verticalOffset = availableHeight * 0.05
        }
        
        let contentOrigin = insets.top + floor((size.height - insets.top - insets.bottom - contentHeight) / 2.0) - verticalOffset
        let iconFrame = CGRect(origin: CGPoint(x: floor((size.width - imageSize.width) / 2.0), y: contentOrigin), size: imageSize)
        let nearbyIconFrame = CGRect(origin: CGPoint(x: floor((size.width - imageSize.width) / 2.0), y: contentOrigin), size: imageSize)
        let animationFrame = CGRect(origin: CGPoint(x: floor((size.width - imageSize.width) / 2.0), y: contentOrigin), size: imageSize)
        let titleFrame = CGRect(origin: CGPoint(x: floor((size.width - titleSize.width) / 2.0), y: iconFrame.maxY + (contentOrigin - insets.top)), size: titleSize)
        let textFrame = CGRect(origin: CGPoint(x: floor((size.width - textSize.width) / 2.0), y: titleFrame.maxY + titleTextSpacing), size: textSize)
        let buttonFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - buttonSize.width) / 2.0),
                y: textFrame.maxY + titleTextSpacing),
            size: buttonSize)
        
        transition.updateFrame(node: self.iconNode, frame: iconFrame)
        if let nearbyIconNode = self.nearbyIconNode {
            transition.updateFrame(node: nearbyIconNode, frame: nearbyIconFrame)
        }
        if let animationNode = self.animationNode {
            transition.updateFrame(node: animationNode, frame: animationFrame)
            // Make transparent, when the title overlaps the animation
            transition.updateAlpha(node: animationNode, alpha: max(titleFrame.minY - animationFrame.maxY, 0.0))
        }
        transition.updateFrame(node: self.titleNode, frame: titleFrame)
        transition.updateFrame(node: self.textNode, frame: textFrame)
        if let promoButtonNode {
            _ = promoButtonNode.updateLayout(width: buttonSize.width, transition: transition)
            transition.updateFrame(node: promoButtonNode, frame: buttonFrame)
        }
    }
    
    @objc private func buttonAction() {
        let email = "info@ello.team?subject=Channel recommendation inquiry"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}
