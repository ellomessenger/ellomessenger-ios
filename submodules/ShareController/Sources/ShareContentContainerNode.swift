import Foundation
import UIKit
import Display
import Postbox
import ElloAppCore

public protocol ShareContentContainerNode: AnyObject {
    func activate()
    func deactivate()
    func setEnsurePeerVisibleOnLayout(_ peerId: EnginePeer.Id?)
    func setContentOffsetUpdated(_ f: ((CGFloat, ContainedViewLayoutTransition) -> Void)?)
    func updateLayout(size: CGSize, isLandscape: Bool, bottomInset: CGFloat, transition: ContainedViewLayoutTransition)
    func updateSelectedPeers()
}
