import UIKit

import AccountContext
import AsyncDisplayKit
import ContextUI
import Display
import AnimationUI
import ElloAppCore
import ElloAppPresentationData
import ElloAppUIPreferences
import SwiftSignalKit

public final class ContactsSearchEmptyContainerNode: ASDisplayNode {
    private let emptyResultsTitleNode: ImmediateTextNode
    private let emptyResultsTextNode: ImmediateTextNode
    private let emptyResultsAnimationNode: AnimationNode
    private var emptyResultsAnimationSize = CGSize(width: 148.0, height: 148.0)
    
    private var presentationData: PresentationData
    
    private var validLayout: (size: CGSize, insets: UIEdgeInsets)?
    
    public init(context: AccountContext) {
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        
        self.emptyResultsTitleNode = ImmediateTextNode()
        self.emptyResultsTitleNode.displaysAsynchronously = false
        self.emptyResultsTitleNode.attributedText = NSAttributedString(
            string: self.presentationData.strings.Contacts_Search_NoResults,
            font: Font.semibold(17.0),
            textColor: self.presentationData.theme.list.freeTextColor)
        self.emptyResultsTitleNode.textAlignment = .center
        
        self.emptyResultsTextNode = ImmediateTextNode()
        self.emptyResultsTextNode.displaysAsynchronously = false
        self.emptyResultsTextNode.maximumNumberOfLines = 0
        self.emptyResultsTextNode.textAlignment = .center
        
        self.emptyResultsAnimationNode = AnimationNode()
        
        super.init()
        
        
        
        self.backgroundColor = .white
        self.isOpaque = false
        
        self.addSubnode(self.emptyResultsAnimationNode)
        self.addSubnode(self.emptyResultsTitleNode)
        self.addSubnode(self.emptyResultsTextNode)
        
        self.emptyResultsAnimationNode.setAnimation(name: "ChatListNoResults")
        emptyResultsAnimationNode.loop()
    }
    
    public func updateLayout(size: CGSize, insets: UIEdgeInsets, transition: ContainedViewLayoutTransition) {
        self.validLayout = (size, insets)
        
        if !emptyResultsAnimationNode.isPlaying {
            DispatchQueue.main.async {
                self.emptyResultsAnimationNode.loop()
            }
        }
        
        let topInset = insets.top
        let sideInset = insets.left
        let visibleHeight = size.height
        let bottomInset = insets.bottom
            
        let padding: CGFloat = 16.0
        let emptyTitleSize = emptyResultsTitleNode.updateLayout(
            CGSize(
                width: size.width - sideInset * 2.0 - padding * 2.0,
                height: CGFloat.greatestFiniteMagnitude))
        let emptyTextSize = emptyResultsTextNode.updateLayout(
            CGSize(
                width: size.width - sideInset * 2.0 - padding * 2.0,
                height: CGFloat.greatestFiniteMagnitude))
        let emptyAnimationHeight = emptyResultsAnimationSize.height
        let emptyAnimationSpacing: CGFloat = 8.0
        let emptyTextSpacing: CGFloat = 8.0
        let emptyTotalHeight = emptyAnimationHeight + emptyAnimationSpacing + emptyTitleSize.height + emptyTextSize.height + emptyTextSpacing
        let emptyAnimationY = topInset + floorToScreenPixels((visibleHeight - topInset - bottomInset - emptyTotalHeight) / 2.0)
        
        let textTransition = ContainedViewLayoutTransition.immediate
        textTransition.updateFrame(
            node: emptyResultsAnimationNode,
            frame: CGRect(
                origin: CGPoint(
                    x: sideInset + padding + (size.width - sideInset * 2.0 - padding * 2.0 - emptyResultsAnimationSize.width) / 2.0,
                    y: emptyAnimationY),
                size: emptyResultsAnimationSize))
        textTransition.updateFrame(
            node: emptyResultsTitleNode,
            frame: CGRect(
                origin: CGPoint(
                    x: sideInset + padding + (size.width - sideInset * 2.0 - padding * 2.0 - emptyTitleSize.width) / 2.0,
                    y: emptyAnimationY + emptyAnimationHeight + emptyAnimationSpacing),
                size: emptyTitleSize))
        textTransition.updateFrame(
            node: emptyResultsTextNode,
            frame: CGRect(
                origin: CGPoint(
                    x: sideInset + padding + (size.width - sideInset * 2.0 - padding * 2.0 - emptyTextSize.width) / 2.0,
                    y: emptyAnimationY + emptyAnimationHeight + emptyAnimationSpacing + emptyTitleSize.height + emptyTextSpacing),
                size: emptyTextSize))
    }
    
    func updateTextQuery(_ query: String) {
        emptyResultsTextNode.attributedText = NSAttributedString(
            string: presentationData.strings.Contacts_Search_NoResultsQueryDescription(query).string,
            font: Font.regular(15.0), 
            textColor: presentationData.theme.list.freeTextColor)
        
        if let validLayout {
            updateLayout(size: validLayout.size, insets: validLayout.insets, transition: .immediate)
        }
    }
}
