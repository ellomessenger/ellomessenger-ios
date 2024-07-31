import Foundation
import UIKit
import AsyncDisplayKit
import Display
import ElloAppPresentationData
import TextSelectionNode
import ElloAppCore
import SwiftSignalKit
import ReactionSelectionNode

enum ContextControllerPresentationNodeStateTransition {
    case animateIn
    case animateOut(result: ContextMenuActionResult, completion: () -> Void)
}

protocol ContextControllerPresentationNode: ASDisplayNode {
    func replaceItems(items: ContextController.Items, animated: Bool)
    func pushItems(items: ContextController.Items)
    func popItems()
    func wantsDisplayBelowKeyboard() -> Bool
    
    func update(
        presentationData: PresentationData,
        layout: ContainerViewLayout,
        transition: ContainedViewLayoutTransition,
        stateTransition: ContextControllerPresentationNodeStateTransition?
    )
    
    func animateOutToReaction(value: MessageReaction.Reaction, targetView: UIView, hideNode: Bool, animateTargetContainer: UIView?, addStandaloneReactionAnimation: ((StandaloneReactionAnimation) -> Void)?, reducedCurve: Bool, completion: @escaping () -> Void)
    func cancelReactionAnimation()
    
    func highlightGestureMoved(location: CGPoint, hover: Bool)
    func highlightGestureFinished(performAction: Bool)
    
    func decreaseHighlightedIndex()
    func increaseHighlightedIndex()
    
    func addRelativeContentOffset(_ offset: CGPoint, transition: ContainedViewLayoutTransition)
}
