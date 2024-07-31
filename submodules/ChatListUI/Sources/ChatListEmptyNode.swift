import Foundation
import UIKit
import AsyncDisplayKit
import Display
import ElloAppPresentationData
import AnimationUI
import ElloAppAnimatedStickerNode
import AppBundle
import SolidRoundedButtonNode
import ActivityIndicator
import AccountContext

final class ChatListEmptyNode: ASDisplayNode {
    private let action: () -> Void
    private let tipsAction: () -> Void
    private let recommendedAction: () -> Void
    
    let isFilter: Bool
    private(set) var isLoading: Bool
    private let textNode: ImmediateTextNode
    private let descriptionNode: ImmediateTextNode
    private let animationNode: AnimationNode
//    private let inviteButtonNode: HighlightTrackingButtonNode
//    private let inviteButtonTextNode: ImmediateTextNode
//    private let tipsButtonNode: HighlightTrackingButtonNode
//    private let tipsButtonTextNode: ImmediateTextNode
    private let recommendedButtonNode: HighlightTrackingButtonNode
    private let recommendedButtonTextNode: ImmediateTextNode
    private let activityIndicator: ActivityIndicator
    
    private var validLayout: CGSize?
    
    init(context: AccountContext, isFilter: Bool, isLoading: Bool, theme: PresentationTheme, strings: PresentationStrings, action: @escaping () -> Void, tipsAction: @escaping () -> Void, recommendedAction: @escaping () -> Void) {
        self.action = action
        self.tipsAction = tipsAction
        self.recommendedAction = recommendedAction
        self.isFilter = isFilter
        self.isLoading = isLoading
        
        self.animationNode = AnimationNode()
        
        self.textNode = ImmediateTextNode()
        self.textNode.displaysAsynchronously = false
        self.textNode.maximumNumberOfLines = 0
        self.textNode.isUserInteractionEnabled = false
        self.textNode.textAlignment = .center
        self.textNode.lineSpacing = 0.1
        
        self.descriptionNode = ImmediateTextNode()
        self.descriptionNode.displaysAsynchronously = false
        self.descriptionNode.maximumNumberOfLines = 0
        self.descriptionNode.isUserInteractionEnabled = false
        self.descriptionNode.textAlignment = .left
        self.descriptionNode.lineSpacing = 0.1
        
//        self.inviteButtonNode = HighlightTrackingButtonNode()
//        self.inviteButtonNode.view.borderColor = UIColor(hexString: "#CFCFD2")
//        self.inviteButtonNode.view.borderWidth = 1.0
//        self.inviteButtonNode.view.cornerRadius = 14.0
//        
//        self.inviteButtonTextNode = ImmediateTextNode()
//        self.inviteButtonTextNode.displaysAsynchronously = false
//        self.inviteButtonTextNode.textAlignment = .center
//        self.inviteButtonTextNode.verticalAlignment = .middle
//        
//        self.tipsButtonNode = HighlightTrackingButtonNode()
//        self.tipsButtonNode.view.borderColor = UIColor(hexString: "#CFCFD2")
//        self.tipsButtonNode.view.borderWidth = 1.0
//        self.tipsButtonNode.view.cornerRadius = 14.0
//        
//        self.tipsButtonTextNode = ImmediateTextNode()
//        self.tipsButtonTextNode.displaysAsynchronously = false
//        self.tipsButtonTextNode.textAlignment = .center
//        self.tipsButtonTextNode.verticalAlignment = .middle
        
        self.recommendedButtonNode = HighlightTrackingButtonNode()
        self.recommendedButtonNode.view.backgroundColor = UIColor(hexString: "#0A49A5")
//        self.recommendedButtonNode.view.borderColor = UIColor(hexString: "#CFCFD2")
//        self.recommendedButtonNode.view.borderWidth = 1.0
        self.recommendedButtonNode.view.cornerRadius = 18.0
        
        self.recommendedButtonTextNode = ImmediateTextNode()
        self.recommendedButtonTextNode.displaysAsynchronously = false
        self.recommendedButtonTextNode.textAlignment = .center
        self.recommendedButtonTextNode.verticalAlignment = .middle
        
        self.activityIndicator = ActivityIndicator(type: .custom(theme.list.itemAccentColor, 22.0, 1.0, false))
        
        super.init()
        
        self.addSubnode(self.animationNode)
        self.addSubnode(self.textNode)
        self.addSubnode(self.descriptionNode)
//        self.addSubnode(self.inviteButtonTextNode)
//        self.addSubnode(self.inviteButtonNode)
//        self.addSubnode(self.tipsButtonTextNode)
//        self.addSubnode(self.tipsButtonNode)
        self.addSubnode(self.recommendedButtonNode)
        self.addSubnode(self.recommendedButtonTextNode)
        self.addSubnode(self.activityIndicator)
        
        let animationName: String
        if isFilter {
            animationName = "ChatListFilterEmpty"
        } else {
            animationName = "ChatListEmpty"
        }

        self.animationNode.setAnimation(name: animationName)
        self.animationNode.loop()
        self.animationNode.isHidden = self.isLoading
        self.textNode.isHidden = self.isLoading
        self.descriptionNode.isHidden = self.isLoading
//        self.inviteButtonNode.isHidden = self.isLoading
//        self.inviteButtonTextNode.isHidden = self.isLoading
//        self.tipsButtonNode.isHidden = self.isLoading
//        self.tipsButtonTextNode.isHidden = self.isLoading
        self.recommendedButtonNode.isHidden = self.isLoading
        self.recommendedButtonTextNode.isHidden = self.isLoading
        self.activityIndicator.isHidden = !self.isLoading
        
//        self.inviteButtonNode.hitTestSlop = UIEdgeInsets(top: -10.0, left: -10.0, bottom: -10.0, right: -10.0)
//        self.inviteButtonNode.addTarget(self, action: #selector(self.buttonPressed), forControlEvents: .touchUpInside)
//        self.inviteButtonNode.highligthedChanged = { [weak self] highlighted in
//            if let strongSelf = self {
//                if highlighted {
//                    strongSelf.inviteButtonTextNode.layer.removeAnimation(forKey: "opacity")
//                    strongSelf.inviteButtonTextNode.alpha = 0.4
//                } else {
//                    strongSelf.inviteButtonTextNode.alpha = 1.0
//                    strongSelf.inviteButtonTextNode.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
//                }
//            }
//        }
//        
//        self.tipsButtonNode.hitTestSlop = UIEdgeInsets(top: -10.0, left: -10.0, bottom: -10.0, right: -10.0)
//        self.tipsButtonNode.addTarget(self, action: #selector(self.tipsButtonPressed), forControlEvents: .touchUpInside)
//        self.tipsButtonNode.highligthedChanged = { [weak self] highlighted in
//            if let strongSelf = self {
//                if highlighted {
//                    strongSelf.tipsButtonTextNode.layer.removeAnimation(forKey: "opacity")
//                    strongSelf.tipsButtonTextNode.alpha = 0.4
//                } else {
//                    strongSelf.tipsButtonTextNode.alpha = 1.0
//                    strongSelf.tipsButtonTextNode.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
//                }
//            }
//        }
        
        self.recommendedButtonNode.hitTestSlop = UIEdgeInsets(top: -10.0, left: -10.0, bottom: -10.0, right: -10.0)
        self.recommendedButtonNode.addTarget(self, action: #selector(self.recommendedButtonPressed), forControlEvents: .touchUpInside)
        self.recommendedButtonNode.highligthedChanged = { [weak self] highlighted in
            if let strongSelf = self {
                if highlighted {
                    strongSelf.recommendedButtonTextNode.layer.removeAnimation(forKey: "opacity")
                    strongSelf.recommendedButtonTextNode.alpha = 0.4
                } else {
                    strongSelf.recommendedButtonTextNode.alpha = 1.0
                    strongSelf.recommendedButtonTextNode.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
                }
            }
        }
        
        self.updateThemeAndStrings(theme: theme, strings: strings)
        
        self.animationNode.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.animationTapGesture(_:))))
    }
    
    @objc private func buttonPressed() {
        self.action()
    }
    @objc private func tipsButtonPressed() {
        self.tipsAction()
    }
    @objc private func recommendedButtonPressed() {
        self.recommendedAction()
    }
    
    @objc private func animationTapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            if !self.animationNode.isPlaying {
                self.animationNode.loop()
            }
        }
    }
    
    func restartAnimation() {
        self.animationNode.play()
    }
    
    func updateThemeAndStrings(theme: PresentationTheme, strings: PresentationStrings) {
        let string = NSMutableAttributedString(
            string: isFilter ? strings.ChatList_EmptyChatListFilterTitle : strings.ChatList_EmptyChatList,
            font: Font.semibold(20.0),
            textColor: theme.list.itemPrimaryTextColor)
        let descriptionString: NSAttributedString
        if isFilter {
            descriptionString = NSAttributedString(
                string: strings.ChatList_EmptyChatListFilterText,
                font: Font.regular(14.0),
                textColor: theme.list.itemSecondaryTextColor)
        } else {
            descriptionString = NSAttributedString(
                string: strings.ChatList_EmptyChatListDescription,
                font: Font.regular(16.0),
                textColor: theme.list.itemPrimaryTextColor,
                paragraphAlignment: .center)
        }
        
        textNode.attributedText = string
        descriptionNode.attributedText = descriptionString
        
//        inviteButtonTextNode.attributedText = NSAttributedString(
//            string: isFilter ? strings.ChatList_EmptyChatListEditFilter : strings.ChatList_EmptyChatListInvite,
//            font: Font.medium(20.0),
//            textColor: theme.list.itemPrimaryTextColor)
//        tipsButtonTextNode.attributedText = NSAttributedString(
//            string: isFilter ? strings.ChatList_EmptyChatListEditFilter : strings.ChatList_EmptyChatListTips,
//            font: Font.medium(20.0),
//            textColor: theme.list.itemPrimaryTextColor)
        recommendedButtonTextNode.attributedText = NSAttributedString(
            string: isFilter ? strings.ChatList_EmptyChatListEditFilter : strings.ChatList_EmptyChatListRecommended,
            font: Font.medium(15.0),
            textColor: .white)
        
        activityIndicator.type = .custom(theme.list.itemAccentColor, 22.0, 1.0, false)
        
        if let size = validLayout {
            updateLayout(size: size, transition: .immediate)
        }
    }
    
    func updateIsLoading(_ isLoading: Bool) {
        if self.isLoading == isLoading { return }
        
        self.isLoading = isLoading
        animationNode.isHidden = isLoading
        textNode.isHidden = isLoading
        descriptionNode.isHidden = isLoading
//        inviteButtonNode.isHidden = isLoading
//        inviteButtonTextNode.isHidden = isLoading
//        tipsButtonNode.isHidden = isLoading
//        tipsButtonTextNode.isHidden = isLoading
        recommendedButtonNode.isHidden = isLoading
        recommendedButtonTextNode.isHidden = isLoading
        activityIndicator.isHidden = !isLoading
    }
    
    func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) {
        validLayout = size
        
        if !animationNode.isPlaying {
            animationNode.loop()
        }
        
        let indicatorSize = activityIndicator.measure(CGSize(width: 100.0, height: 100.0))
        transition.updateFrame(
            node: activityIndicator,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - indicatorSize.width) / 2.0),
                    y: floor((size.height - indicatorSize.height - 50.0) / 2.0)),
                size: indicatorSize
            )
        )
        
        let topInset = 36.0
        let animationSpacing: CGFloat = 0.0
        let descriptionSpacing: CGFloat = 16.0
        let buttonSpacing: CGFloat = 42.0//16.0
//        let buttonSideInset: CGFloat = 16.0
//        let buttonInsetFromCenter = 2.0
        
        var animationSize = CGSize(width: 200.0, height: 200.0)
        let textSize = textNode.updateLayout(CGSize(width: size.width - 40.0, height: size.height))
        let descriptionSize = descriptionNode.updateLayout(CGSize(width: size.width - 40.0, height: size.height))
        
//        let buttonWidth = min(size.width - buttonSideInset * 2.0, 280.0)
        let buttonSize = CGSize(width: 172.0, height: 57.0)
//        let buttonsVerticalSpace = 4.0
        let recomendedButtonSize = CGSize(width: buttonSize.width, height: 57.0)
        let buttonsHeightBlock = /*buttonSize.height + buttonsVerticalSpace + */recomendedButtonSize.height
        
        var contentHeight: CGFloat {
            animationSize.height + animationSpacing + textSize.height + descriptionSize.height + descriptionSpacing + buttonSpacing + buttonsHeightBlock
        }
        // Change animation size for small screen
        if size.height < contentHeight {
            let exceedHeight = contentHeight - size.height
            animationSize = CGSize(
                width: animationSize.width - exceedHeight,
                height: animationSize.height - exceedHeight
            )
        }
        var contentOffset: CGFloat = 0.0
        if size.height < contentHeight {
            contentOffset = -animationSize.height - animationSpacing + 44.0
            transition.updateAlpha(node: animationNode, alpha: 0.0)
        } else {
            contentOffset = -40.0
            transition.updateAlpha(node: animationNode, alpha: 1.0)
        }
        
        let animationFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - animationSize.width) / 2.0),
                y: floor((size.height - contentHeight) / 2.0) + contentOffset + topInset),
            size: animationSize)
        let textFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - textSize.width) / 2.0),
                y: animationFrame.maxY + animationSpacing),
            size: textSize)
        let descpriptionFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - descriptionSize.width) / 2.0),
                y: textFrame.maxY + descriptionSpacing),
            size: descriptionSize)
        let bottomTextEdge: CGFloat = descpriptionFrame.width.isZero ? textFrame.maxY : descpriptionFrame.maxY
        
        transition.updateFrame(node: animationNode, frame: animationFrame)
        transition.updateFrame(node: textNode, frame: textFrame)
        transition.updateFrame(node: descriptionNode, frame: descpriptionFrame)
        
//        let _ = inviteButtonTextNode.updateLayout(CGSize(width: size.width, height: .greatestFiniteMagnitude))
//        let _ = tipsButtonTextNode.updateLayout(CGSize(width: size.width, height: .greatestFiniteMagnitude))
        let _ = recommendedButtonTextNode.updateLayout(CGSize(width: size.width, height: .greatestFiniteMagnitude))
        
//        let inviteButtonFrame = CGRect(
//            origin: CGPoint(
//                x: floor(size.width / 2.0) - buttonSize.width - buttonInsetFromCenter,
//                y: bottomTextEdge + buttonSpacing),
//            size: buttonSize)
//        transition.updateFrame(node: inviteButtonNode, frame: inviteButtonFrame)
//        transition.updateFrame(node: inviteButtonTextNode, frame: inviteButtonFrame)
//        
//        let tipsButtonFrame = CGRect(
//            origin: CGPoint(
//                x: floor(size.width / 2.0) + buttonInsetFromCenter,
//                y: bottomTextEdge + buttonSpacing),
//            size: buttonSize)
//        transition.updateFrame(node: tipsButtonNode, frame: tipsButtonFrame)
//        transition.updateFrame(node: tipsButtonTextNode, frame: tipsButtonFrame)
        
        let recommendedButtonFrame = CGRect(
            origin: CGPoint(
                x: (size.width - recomendedButtonSize.width) / 2.0/*inviteButtonFrame.minX*/,
                y: bottomTextEdge + buttonSpacing/*inviteButtonFrame.maxY + buttonsVerticalSpace*/),
            size: recomendedButtonSize)
        transition.updateFrame(node: recommendedButtonNode, frame: recommendedButtonFrame)
        transition.updateFrame(node: recommendedButtonTextNode, frame: recommendedButtonFrame)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.inviteButtonNode.frame.contains(point) {
//            return self.inviteButtonNode.view.hitTest(self.view.convert(point, to: self.inviteButtonNode.view), with: event)
//        }
//        if self.tipsButtonNode.frame.contains(point) {
//            return self.tipsButtonNode.view.hitTest(self.view.convert(point, to: self.tipsButtonNode.view), with: event)
//        }
        if self.recommendedButtonNode.frame.contains(point) {
            return self.recommendedButtonNode.view.hitTest(self.view.convert(point, to: self.recommendedButtonNode.view), with: event)
        }
        if self.animationNode.frame.contains(point) {
            return self.animationNode.view.hitTest(self.view.convert(point, to: self.animationNode.view), with: event)
        }
        return nil
    }
}
