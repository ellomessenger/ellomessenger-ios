import Foundation
import AvatarNode
import UIKit
import Display
import Postbox
import ElloAppCore
import ElloAppPresentationData
import ElloAppUIPreferences
import AccountContext
import AnimatedStickerNode
import ElloAppAnimatedStickerNode
import SwiftSignalKit

public final class SubscribePeerHeaderActionSheetItem: ActionSheetItem {
    private let context: AccountContext
    private let presentationData: PresentationData
    private let channel: ElloAppChannel
    
    public init(context: AccountContext, presentationData: PresentationData, channel: ElloAppChannel) {
        self.context = context
        self.presentationData = presentationData
        self.channel = channel
    }
    
    public func node(theme: ActionSheetControllerTheme) -> ActionSheetItemNode {
        return SubscribePeerHeaderActionSheetItemNode(
            theme: theme,
            context: context,
            presentationData: presentationData,
            channel: channel
        )
    }
    
    public func updateNode(_ node: ActionSheetItemNode) { }
}

private final class SubscribePeerHeaderActionSheetItemNode: ActionSheetItemNode {
    private let theme: ActionSheetControllerTheme
    private let context: AccountContext
    private let presentationData: PresentationData
    private let channel: ElloAppChannel
    
    private let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 16.0))
    private let contentView: SubscribePeerHeaderActionSheetView
    
    private let accessibilityArea: AccessibilityAreaNode
    
    init(theme: ActionSheetControllerTheme, context: AccountContext, presentationData: PresentationData, channel: ElloAppChannel) {
        self.theme = theme
        self.context = context
        self.presentationData = presentationData
        self.channel = channel
        self.contentView = SubscribePeerHeaderActionSheetView(
            channel: channel,
            localizedStrings: presentationData.strings,
            context: context
        )
        
        self.accessibilityArea = AccessibilityAreaNode()
        
        super.init(theme: theme)
        
        hasSeparator = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.avatarImageView.addSubnode(avatarNode)
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func didLoad() {
        super.didLoad()
        let localizedStrings = presentationData.strings
        
        avatarNode.frame = .init(origin: .zero, size: .init(width: 54, height: 54))
        avatarNode.setPeer(context: context, theme: presentationData.theme, peer: EnginePeer(channel))
        
        let status = context.account.viewTracker.peerView(channel.id, updateData: false)
        _ = (status |> deliverOnMainQueue).start { [weak self] peerView in
            let cachedChannelData = peerView.cachedData as? CachedChannelData
            let memberCount = cachedChannelData?.participantsSummary.memberCount ?? 0
            self?.contentView.subscribersLabel.text = localizedStrings.Conversation_StatusSubscribers(memberCount)
        }
    }
    
    public override func updateLayout(constrainedSize: CGSize, transition: ContainedViewLayoutTransition) -> CGSize {
        let leftInset = 20.0, rightInset = 20.0
        let size = contentView.containerStackView.systemLayoutSizeFitting(
            CGSizeMake(constrainedSize.width - leftInset - rightInset, CGFloat.greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        let subscribeButtonHeight = 57.0
        let actualSize = CGSize(
            width: constrainedSize.width,
            height: min(
                constrainedSize.height - subscribeButtonHeight,
                size.height
            )
        )
        accessibilityArea.frame = CGRect(origin: CGPoint(), size: actualSize)
        updateInternalLayout(actualSize, constrainedSize: constrainedSize)

        return actualSize
    }
}
