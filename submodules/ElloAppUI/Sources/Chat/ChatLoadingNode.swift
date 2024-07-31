import Foundation
import UIKit
import AsyncDisplayKit
import Display
import ElloAppCore
import ElloAppPresentationData
import ActivityIndicator
import AnimationUI

enum ChatLoadingAnimationType {
    case spinner
    case custom(String)
}

final class ChatLoadingNode: ASDisplayNode {
    private let backgroundNode: NavigationBackgroundNode
    private let offset: CGPoint
    private let animationType:ChatLoadingAnimationType

    private var activityIndicator: ActivityIndicator?
    private var animationNode: AnimationNode?

    init(theme: PresentationTheme, 
         chatWallpaper: ElloAppWallpaper,
         bubbleCorners: PresentationChatBubbleCorners,
         animationType: ChatLoadingAnimationType = .spinner){ // .custom("Preloader")) {
        
        self.animationType = animationType
        self.backgroundNode = NavigationBackgroundNode(color: selectDateFillStaticColor(theme: theme, wallpaper: chatWallpaper),
                                                       enableBlur: dateFillNeedsBlur(theme: theme, wallpaper: chatWallpaper))
        
        let serviceColor = serviceMessageColorComponents(theme: theme, wallpaper: chatWallpaper)
        if serviceColor.primaryText != .white {
            self.offset = CGPoint(x: 0.5, y: 0.5)
        } else {
            self.offset = CGPoint()
        }

        switch animationType {
        case .spinner:
            self.activityIndicator = ActivityIndicator(type: .custom(serviceColor.primaryText, 22.0, 2.0, false), speed: .regular)
        case .custom(let animationName):
            self.animationNode = AnimationNode(animation: animationName)
        }
        
        super.init()
        
        switch animationType {
        case .spinner:
            self.addSubnode(self.backgroundNode)
            self.addSubnode(self.activityIndicator!)
        case .custom(_):
            self.addSubnode(self.animationNode!)
//            showSpinner()
        }
    }
    
    func updateLayout(size: CGSize, insets: UIEdgeInsets, transition: ContainedViewLayoutTransition) {
        let displayRect = CGRect(origin: CGPoint(x: 0.0, y: insets.top), size: CGSize(width: size.width, height: size.height - insets.top - insets.bottom))

        if let activityIndicator {
            let backgroundSize: CGFloat = 30.0
            transition.updateFrame(node: self.backgroundNode, frame: CGRect(origin: CGPoint(x: displayRect.minX + floor((displayRect.width - backgroundSize) / 2.0), y: displayRect.minY + floor((displayRect.height - backgroundSize) / 2.0)), size: CGSize(width: backgroundSize, height: backgroundSize)))
            self.backgroundNode.update(size: self.backgroundNode.bounds.size, cornerRadius: self.backgroundNode.bounds.height / 2.0, transition: transition)
            
            let activitySize = activityIndicator.measure(size)
            transition.updateFrame(node: activityIndicator, frame: CGRect(origin: CGPoint(x: displayRect.minX + floor((displayRect.width - activitySize.width) / 2.0) + self.offset.x, y: displayRect.minY + floor((displayRect.height - activitySize.height) / 2.0) + self.offset.y), size: activitySize))
        }
        
        if let animationNode {
            transition.updateFrame(node: animationNode, frame: displayRect)
            showSpinner()
        }
    }
    
    var progressFrame: CGRect {
        return self.backgroundNode.frame
    }
    
    func showSpinner() {
        guard let animationNode else { return }
        self.view.addSubview(animationNode.view)
        animationNode.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        animationNode.view.frame = self.bounds
//        animationNode.view.transform = CGAffineTransform(scaleX: -1, y: -1)
        animationNode.loop()
        animationNode.isUserInteractionEnabled = false
    }
    
    func hideSpinner() {
        guard let animationNode else { return }
        animationNode.reset()
        animationNode.view.removeFromSuperview()
    }
}

