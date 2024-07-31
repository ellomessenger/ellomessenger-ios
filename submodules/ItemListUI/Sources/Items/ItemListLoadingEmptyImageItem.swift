//
//  ItemListLoadingEmptyImageItem.swift
//  _idx_ItemListUI_88345AEC_ios_min16.0
//

import UIKit
import AsyncDisplayKit
import Display
import ElloAppPresentationData

public final class ItemListLoadingEmptyImageItem: ItemListControllerEmptyStateItem {
    let theme: PresentationTheme
        public var emptyTitle: String = "Please be patient while we're creating the analytics for you."
        public var emptyText: String = "Please be patient while we're creating the analytics for you."
    public init(theme: PresentationTheme, emptyTitle: String, emptyText: String) {
        self.theme = theme
        self.emptyText = emptyText
        self.emptyTitle = emptyTitle
    }
    
    public func isEqual(to: ItemListControllerEmptyStateItem) -> Bool {
        return to is ItemListLoadingIndicatorEmptyStateItem
    }
    
    public func node(current: ItemListControllerEmptyStateItemNode?) -> ItemListControllerEmptyStateItemNode {
        if let current = current as? ItemListLoadingEmptyImageItemNode {
            current.theme = self.theme
            return current
        } else {
            return ItemListLoadingEmptyImageItemNode(theme: self.theme, emptyTitle: emptyTitle, emptyText: emptyText)
        }
    }
}

public final class ItemListLoadingEmptyImageItemNode: ItemListControllerEmptyStateItemNode {
    public var theme: PresentationTheme
    
    private let emptyTitleNode: ASTextNode
    private let emptyTextNode: ASTextNode
    private let backgroundNode: ASDisplayNode
    private let emptyImageView: ASImageNode
    private var validLayout: (ContainerViewLayout, CGFloat)?
    
    public init(theme: PresentationTheme, emptyTitle: String, emptyText: String) {
        self.theme = theme
        
        self.emptyImageView = ASImageNode()
        self.backgroundNode = ASDisplayNode()
        
        self.emptyTitleNode = ASTextNode()
        self.emptyTitleNode.maximumNumberOfLines = 1
        
        self.emptyTextNode = ASTextNode()
        self.emptyTextNode.maximumNumberOfLines = 3
        
        super.init()
        
        self.emptyImageView.image = UIImage(named: "Chat/EmptyStats")
        self.emptyTitleNode.attributedText = NSAttributedString(string: emptyTitle, font: Font.medium(20.0), textColor: theme.list.itemPrimaryTextColor, paragraphAlignment: .center)
        self.emptyTextNode.attributedText = NSAttributedString(string: emptyText, font: Font.regular(16.0), textColor: theme.list.itemSecondaryTextColor, paragraphAlignment: .center)
        self.emptyImageView.isUserInteractionEnabled = false
        self.emptyImageView.displaysAsynchronously = false
        self.backgroundNode.backgroundColor = theme.list.plainBackgroundColor
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.emptyImageView)
        self.addSubnode(self.emptyTitleNode)
        self.addSubnode(self.emptyTextNode)
    }
    
    override public func updateLayout(layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        self.validLayout = (layout, navigationBarHeight)
        
        let insets = layout.insets(options: [.statusBar])
        let availableWidth = layout.size.width - insets.left - insets.right
        let imageSize = CGSize(width: 160, height: 160)
        let titleSize = self.emptyTitleNode.measure(CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude))
        let textSize = self.emptyTextNode.measure(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
        let totalHeight = imageSize.height + titleSize.height + textSize.height
        let padding = 16.0
        
        let startY = insets.top + (layout.size.height - insets.top - insets.bottom - totalHeight - (2 * padding)) / 2.0
        
        let imageFrameY = startY
        let titleFrameY = imageFrameY + imageSize.height + padding / 2
        let textFrameY = titleFrameY + titleSize.height + padding / 2
        transition.updateFrame(node: self.emptyImageView, frame: CGRect(x: floor((layout.size.width - imageSize.width) / 2.0), y: imageFrameY, width: imageSize.width, height: imageSize.height))
        transition.updateFrame(node: self.emptyTitleNode, frame: CGRect(x: floor((layout.size.width - titleSize.width) / 2.0), y: titleFrameY, width: titleSize.width, height: titleSize.height))
        transition.updateFrame(node: self.emptyTextNode, frame: CGRect(x: floor((layout.size.width - textSize.width) / 2.0), y: textFrameY, width: textSize.width, height: textSize.height))
        
        transition.updateFrame(node: self.backgroundNode, frame: CGRect(x: 0, y: navigationBarHeight, width: layout.size.width, height: layout.size.height - navigationBarHeight))
    }
}
