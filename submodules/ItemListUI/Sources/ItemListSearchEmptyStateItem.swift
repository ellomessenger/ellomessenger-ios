import Foundation
import UIKit
import AsyncDisplayKit
import Display
import ElloAppPresentationData
import ActivityIndicator
import AnimationUI

public final class ItemListSearchEmptyStateItem: ItemListControllerEmptyStateItem {
    let theme: PresentationTheme
    let strings: PresentationStrings
    public init(theme: PresentationTheme, strings: PresentationStrings) {
        self.theme = theme
        self.strings = strings
    }
    
    public func isEqual(to: ItemListControllerEmptyStateItem) -> Bool {
        return to is ItemListSearchEmptyStateItem
    }
    
    public func node(current: ItemListControllerEmptyStateItemNode?) -> ItemListControllerEmptyStateItemNode {
        if let current = current as? ItemListSearchEmptyStateItemNode {
            current.currentTheme = self.theme
            current.currentStrings = self.strings
            return current
        } else {
            return ItemListSearchEmptyStateItemNode(theme: self.theme, strings: self.strings)
        }
    }
}

public final class ItemListSearchEmptyStateItemNode: ItemListControllerEmptyStateItemNode {
    var currentTheme: PresentationTheme
    var currentStrings: PresentationStrings
    private let animationNode: AnimationNode
    private let titleNode: ImmediateTextNode
    private let textNode: ImmediateTextNode
    
    private var validLayout: (ContainerViewLayout, CGFloat)?
    
    public init(theme: PresentationTheme, strings: PresentationStrings) {
        self.currentTheme = theme
        self.currentStrings = strings
        self.animationNode = AnimationNode(animation: "ChatListNoResults")
        self.animationNode.loop()
        self.animationNode.play()
        
        self.titleNode = ImmediateTextNode()
        self.titleNode.maximumNumberOfLines = 0
        self.titleNode.lineSpacing = 0.15
        self.titleNode.textAlignment = .center
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.displaysAsynchronously = false
        
        self.textNode = ImmediateTextNode()
        self.textNode.maximumNumberOfLines = 0
        self.textNode.lineSpacing = 0.14
        self.textNode.textAlignment = .center
        self.textNode.isUserInteractionEnabled = false
        self.textNode.displaysAsynchronously = false
        
        super.init()
//        self.backgroundColor = UIColor(hex: 0x27AE60)
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.textNode)
        self.addSubnode(self.animationNode)
    }
    
    override public func updateLayout(layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        
        let titleFont = Font.regular(16.0)
        let messageFont = Font.regular(14.0)

        let titleString = currentStrings.SharedMedia_SearchNoResults
        self.titleNode.attributedText = NSAttributedString(string: titleString, font: titleFont, textColor: currentTheme.list.itemPrimaryTextColor)
        
        let textString = currentStrings.SharedMedia_SearchNoResultsDescription
        self.textNode.attributedText = NSAttributedString(string: textString, font: messageFont, textColor: currentTheme.list.itemPrimaryTextColor)
        self.validLayout = (layout, navigationBarHeight)
        
        var insets = layout.insets(options: [.statusBar])
        insets.top += navigationBarHeight
        let contentSpacing: CGFloat = 8.0
        var contentSize = CGSize(width: layout.size.width, height: 0.0)
        
        let titleSize = self.titleNode.updateLayout(CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude))
        let textSize = self.textNode.updateLayout(CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude))
        let animationSize = CGSize(width: 120, height: 120)
        
        contentSize.height = titleSize.height + contentSpacing + textSize.height + contentSpacing + animationSize.height
        
        let contentRect = CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: contentSize)
        
        
        let animationFrame = CGRect(
            origin: CGPoint(
                x: contentRect.midX - floor((animationSize.width) / 2.0),
                y: layout.size.height / 2 - floor(contentSize.height / 2)),
            size: animationSize
        )
        transition.updateFrame(node: self.animationNode, frame: animationFrame)
        
        let titleFrame = CGRect(
            origin: CGPoint(
                x: contentRect.midX - floor((titleSize.width) / 2.0),
                y: animationFrame.maxY + 2 * contentSpacing),
            size: titleSize)
        transition.updateFrame(node: self.titleNode, frame: titleFrame)
        
        let textFrame = CGRect(
            origin: CGPoint(
                x: contentRect.midX - floor((textSize.width) / 2.0),
                y: titleFrame.maxY + contentSpacing),
            size: textSize)
        transition.updateFrame(node: self.textNode, frame: textFrame)
    }
}

