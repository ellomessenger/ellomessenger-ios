import Foundation
import UIKit
import AsyncDisplayKit
import Display
import Postbox
import ElloAppCore
import AvatarNode
import AccountContext
import SwiftSignalKit
import ElloAppPresentationData
import PhotoResources
import PeerAvatarGalleryUI
import ElloAppStringFormatting
import PhoneNumberFormat
import ActivityIndicator
import ElloAppUniversalVideoContent
import GalleryUI
import UniversalMediaPlayer
import RadialStatusNode
import ElloAppUIPreferences
import PeerInfoAvatarListNode
import AnimationUI
import ContextUI
import ManagedAnimationNode
import ComponentFlow
import EmojiStatusComponent
import AnimationCache
import MultiAnimationRenderer
import ComponentDisplayAdapters

import ELProfileUI

enum PeerInfoHeaderButtonKey: Hashable {
    case message
    case discussion
    case call
    case videoCall
    case voiceChat
    case mute
    case more
    case addMember
    case search
    case leave
    case stop
}

enum PeerInfoHeaderButtonIcon {
    case message
    case call
    case videoCall
    case voiceChat
    case mute
    case unmute
    case more
    case addMember
    case search
    case leave
    case stop
}

final class PeerInfoHeaderRegularContentNode: ASDisplayNode {
    
}

private let TitleNodeStateRegular = 0
private let TitleNodeStateExpanded = 1

// MARK: - PeerInfoHeaderNode

final class PeerInfoHeaderNode: ASDisplayNode {
    private var context: AccountContext
    private var presentationData: PresentationData?
    private var state: PeerInfoState?
    private var peer: Peer?
    private var avatarSize: CGFloat?
    
    private let isOpenedFromChat: Bool
    private let isSettings: Bool
    private let videoCallsEnabled: Bool
    
    private(set) var isAvatarExpanded: Bool
    var skipCollapseCompletion = false
    var ignoreCollapse = false
    
    let avatarListNode: PeerInfoAvatarListNode
    
    let buttonsContainerNode: SparseNode
    let regularContentNode: PeerInfoHeaderRegularContentNode
    let editingContentNode: PeerInfoHeaderEditingContentNode
    let avatarOverlayNode: PeerInfoEditingAvatarOverlayNode
    let titleNodeContainer: ASDisplayNode
    let titleNodeRawContainer: ASDisplayNode
    let titleNode: MultiScaleTextNode
    
    let titleCredibilityIconView: ComponentHostView<Empty>
    var credibilityIconSize: CGSize?
    let titleExpandedCredibilityIconView: ComponentHostView<Empty>
    var titleExpandedCredibilityIconSize: CGSize?
    
    let titlePeerTypeIconView: UIImageView
    var titlePeerTypeIconSize: CGSize = .zero
    let titleExpandedPeerTypeIconView: UIImageView
    var titleExpandedPeerTypeIconSize: CGSize = .zero
    
    let titleAdultIconView: UIImageView
    var titleAdultIconSize: CGSize = .zero
    let titleExpandedAdultIconView: UIImageView
    var titleExpandedAdultIconSize: CGSize = .zero
    
    let subtitleNodeContainer: ASDisplayNode
    let subtitleNodeRawContainer: ASDisplayNode
    let subtitleNode: MultiScaleTextNode
    let panelSubtitleNode: MultiScaleTextNode
    let nextPanelSubtitleNode: MultiScaleTextNode
    let usernameNodeContainer: ASDisplayNode
    let usernameNodeRawContainer: ASDisplayNode
    let usernameNode: MultiScaleTextNode
    var buttonNodes: [PeerInfoHeaderButtonKey: PeerInfoHeaderButtonNode] = [:]
    let backgroundNode: NavigationBackgroundNode
    let expandedBackgroundNode: NavigationBackgroundNode
    let separatorNode: ASDisplayNode
    let navigationBackgroundNode: ASDisplayNode
    let navigationBackgroundBackgroundNode: ASDisplayNode
    var navigationTitle: String?
    let navigationTitleNode: ImmediateTextNode
    let navigationSeparatorNode: ASDisplayNode
    let navigationButtonContainer: PeerInfoHeaderNavigationButtonContainerNode
    
    let avatarActionsButtonNode: PeerInfoHeaderRegularContentNode
    let referenceNode: ContextReferenceContentNode
    
    var performButtonAction: ((PeerInfoHeaderButtonKey, ContextGesture?) -> Void)?
    var requestAvatarExpansion: ((Bool, [AvatarGalleryEntry], AvatarGalleryEntry?, (ASDisplayNode, CGRect, () -> (UIView?, UIView?))?) -> Void)?
    var requestOpenAvatarForEditing: ((Bool) -> Void)?
    var cancelUpload: (() -> Void)?
    var requestUpdateLayout: ((Bool) -> Void)?
    var animateOverlaysFadeIn: (() -> Void)?
    
    var displayAvatarContextMenu: ((ASDisplayNode, ContextGesture?) -> Void)?
    var displayCopyContextMenu: ((ASDisplayNode, Bool, Bool) -> Void)?
    
    var displayPremiumIntro: ((UIView, PeerEmojiStatus?, Signal<(ElloAppMediaFile, LoadedStickerPack)?, NoError>, Bool) -> Void)?
    var displaySubscriptionIntro: ((UIView, PeerEmojiStatus?, Signal<(ElloAppMediaFile, LoadedStickerPack)?, NoError>, Bool) -> Void)?
    
    var navigationTransition: PeerInfoHeaderNavigationTransition?
    
    var backgroundAlpha: CGFloat = 1.0
    var updateHeaderAlpha: ((CGFloat, ContainedViewLayoutTransition) -> Void)?
    
    let animationCache: AnimationCache
    let animationRenderer: MultiAnimationRenderer
    
    var emojiStatusPackDisposable = MetaDisposable()
    var emojiStatusFileAndPackTitle = Promise<(ElloAppMediaFile, LoadedStickerPack)?>()
    
    init(context: AccountContext, avatarInitiallyExpanded: Bool, isOpenedFromChat: Bool, isMediaOnly: Bool, isSettings: Bool) {
        self.context = context
        self.isAvatarExpanded = avatarInitiallyExpanded
        self.isOpenedFromChat = isOpenedFromChat
        self.isSettings = isSettings
        self.videoCallsEnabled = false
        
        self.avatarListNode = PeerInfoAvatarListNode(context: context, readyWhenGalleryLoads: avatarInitiallyExpanded, isSettings: isSettings)
        
        self.titleNodeContainer = ASDisplayNode()
        self.titleNodeRawContainer = ASDisplayNode()
        self.titleNode = MultiScaleTextNode(stateKeys: [TitleNodeStateRegular, TitleNodeStateExpanded])
        self.titleNode.displaysAsynchronously = false
        
        self.titleCredibilityIconView = ComponentHostView<Empty>()
        self.titleNode.stateNode(forKey: TitleNodeStateRegular)?.view.addSubview(self.titleCredibilityIconView)
        
        self.titleExpandedCredibilityIconView = ComponentHostView<Empty>()
        self.titleNode.stateNode(forKey: TitleNodeStateExpanded)?.view.addSubview(self.titleExpandedCredibilityIconView)
        
        self.titlePeerTypeIconView = UIImageView(
            frame: CGRect(origin: .zero, size: CGSize(width: 30.0, height: 30.0))
        )
        self.titlePeerTypeIconView.tintColor = UIColor(bundleColorName: "IconsDark")
        self.titleNode.stateNode(forKey: TitleNodeStateRegular)?.view.addSubview(self.titlePeerTypeIconView)
        
        self.titleExpandedPeerTypeIconView = UIImageView(
            frame: CGRect(origin: .zero, size: CGSize(width: 30.0, height: 30.0))
        )
        self.titleExpandedPeerTypeIconView.tintColor = .white
        self.titleNode.stateNode(forKey: TitleNodeStateExpanded)?.view.addSubview(self.titleExpandedPeerTypeIconView)
        
        self.titleAdultIconView = UIImageView(
            frame: CGRect(origin: .zero, size: CGSize(width: 30.0, height: 30.0))
        )
        self.titleAdultIconView.tintColor = UIColor(bundleColorName: "IconsDark")
        self.titleNode.stateNode(forKey: TitleNodeStateRegular)?.view.addSubview(self.titleAdultIconView)
        
        self.titleExpandedAdultIconView = UIImageView(
            frame: CGRect(origin: .zero, size: CGSize(width: 30.0, height: 30.0))
        )
        self.titleExpandedAdultIconView.tintColor = .white
        self.titleNode.stateNode(forKey: TitleNodeStateExpanded)?.view.addSubview(self.titleExpandedAdultIconView)
        
        self.subtitleNodeContainer = ASDisplayNode()
        self.subtitleNodeRawContainer = ASDisplayNode()
        self.subtitleNode = MultiScaleTextNode(stateKeys: [TitleNodeStateRegular, TitleNodeStateExpanded])
        self.subtitleNode.displaysAsynchronously = false

        self.panelSubtitleNode = MultiScaleTextNode(stateKeys: [TitleNodeStateRegular, TitleNodeStateExpanded])
        self.panelSubtitleNode.displaysAsynchronously = false
        
        self.nextPanelSubtitleNode = MultiScaleTextNode(stateKeys: [TitleNodeStateRegular, TitleNodeStateExpanded])
        self.nextPanelSubtitleNode.displaysAsynchronously = false
        
        self.usernameNodeContainer = ASDisplayNode()
        self.usernameNodeRawContainer = ASDisplayNode()
        self.usernameNode = MultiScaleTextNode(stateKeys: [TitleNodeStateRegular, TitleNodeStateExpanded])
        self.usernameNode.displaysAsynchronously = false
        
        avatarActionsButtonNode = PeerInfoHeaderRegularContentNode()
        referenceNode = ContextReferenceContentNode()

        self.buttonsContainerNode = SparseNode()
        self.buttonsContainerNode.clipsToBounds = true
        
        self.regularContentNode = PeerInfoHeaderRegularContentNode()
        var requestUpdateLayoutImpl: (() -> Void)?
        self.editingContentNode = PeerInfoHeaderEditingContentNode(context: context, requestUpdateLayout: {
            requestUpdateLayoutImpl?()
        })
        self.editingContentNode.alpha = 0.0
        
        self.avatarOverlayNode = PeerInfoEditingAvatarOverlayNode(context: context)
        self.avatarOverlayNode.isUserInteractionEnabled = false
        
        self.navigationBackgroundNode = ASDisplayNode()
        self.navigationBackgroundNode.isHidden = true
        self.navigationBackgroundNode.isUserInteractionEnabled = false

        self.navigationBackgroundBackgroundNode = ASDisplayNode()
        self.navigationBackgroundBackgroundNode.isUserInteractionEnabled = false
        
        self.navigationTitleNode = ImmediateTextNode()
        
        self.navigationSeparatorNode = ASDisplayNode()
        
        self.navigationButtonContainer = PeerInfoHeaderNavigationButtonContainerNode()
        
        self.backgroundNode = NavigationBackgroundNode(color: .clear)
        self.backgroundNode.isHidden = true
        self.backgroundNode.isUserInteractionEnabled = false
        self.expandedBackgroundNode = NavigationBackgroundNode(color: .clear)
        self.expandedBackgroundNode.isHidden = false
        self.expandedBackgroundNode.isUserInteractionEnabled = false
        
        self.separatorNode = ASDisplayNode()
        self.separatorNode.isLayerBacked = true
        
        self.animationCache = context.animationCache
        self.animationRenderer = context.animationRenderer
        
        super.init()
        
        requestUpdateLayoutImpl = { [weak self] in
            self?.requestUpdateLayout?(false)
        }
        
        if !isMediaOnly {
            self.addSubnode(self.buttonsContainerNode)
        }
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.expandedBackgroundNode)
        self.titleNodeContainer.addSubnode(self.titleNode)
        self.subtitleNodeContainer.addSubnode(self.subtitleNode)
        self.subtitleNodeContainer.addSubnode(self.panelSubtitleNode)
        // EM-2638
//        self.subtitleNodeContainer.addSubnode(self.nextPanelSubtitleNode)
        self.usernameNodeContainer.addSubnode(self.usernameNode)

        self.regularContentNode.addSubnode(self.avatarListNode)
        self.regularContentNode.addSubnode(self.avatarListNode.listContainerNode.controlsClippingOffsetNode)
        self.regularContentNode.addSubnode(self.titleNodeContainer)
        self.regularContentNode.addSubnode(self.subtitleNodeContainer)
        self.regularContentNode.addSubnode(self.subtitleNodeRawContainer)
        self.regularContentNode.addSubnode(self.usernameNodeContainer)
        self.regularContentNode.addSubnode(self.usernameNodeRawContainer)
        
        self.addSubnode(self.regularContentNode)
        self.addSubnode(self.editingContentNode)
        self.addSubnode(self.avatarOverlayNode)
        self.addSubnode(self.navigationBackgroundNode)
        self.navigationBackgroundNode.addSubnode(self.navigationBackgroundBackgroundNode)
        self.navigationBackgroundNode.addSubnode(self.navigationTitleNode)
        self.navigationBackgroundNode.addSubnode(self.navigationSeparatorNode)
        self.addSubnode(self.navigationButtonContainer)
        self.addSubnode(self.separatorNode)
        

        self.avatarListNode.avatarContainerNode.tapped = { [weak self] in
            self?.initiateAvatarExpansion(gallery: false, first: false)
        }
        
        self.avatarListNode.avatarContainerNode.contextAction = { [weak self] node, gesture in
            self?.displayAvatarContextMenu?(node, gesture)
        }
        
        self.editingContentNode.avatarNode.tapped = { [weak self] confirm in
            self?.initiateAvatarExpansion(gallery: true, first: true)
        }
        
        self.editingContentNode.requestEditing = { [weak self] in
            self?.requestOpenAvatarForEditing?(true)
        }
        
        self.avatarListNode.itemsUpdated = { [weak self] items in
            guard let strongSelf = self, let state = strongSelf.state, let peer = strongSelf.peer, let presentationData = strongSelf.presentationData, let avatarSize = strongSelf.avatarSize else {
                return
            }
            
            strongSelf.editingContentNode.avatarNode.update(peer: peer, item: strongSelf.avatarListNode.item, updatingAvatar: state.updatingAvatar, uploadProgress: state.avatarUploadProgress, theme: presentationData.theme, avatarSize: avatarSize, isEditing: state.isEditing)
        }

        self.avatarListNode.animateOverlaysFadeIn = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationButtonContainer.layer.animateAlpha(from: 0.0, to: strongSelf.navigationButtonContainer.alpha, duration: 0.25)
            strongSelf.avatarListNode.listContainerNode.topShadowNode.layer.animateAlpha(from: 0.0, to: strongSelf.avatarListNode.listContainerNode.topShadowNode.alpha, duration: 0.25)
            
            strongSelf.avatarListNode.listContainerNode.bottomShadowNode.alpha = 1.0
            strongSelf.avatarListNode.listContainerNode.bottomShadowNode.layer.animateAlpha(from: 0.0, to: strongSelf.avatarListNode.listContainerNode.bottomShadowNode.alpha, duration: 0.25)
            strongSelf.avatarListNode.listContainerNode.controlsContainerNode.layer.animateAlpha(from: 0.0, to: strongSelf.avatarListNode.listContainerNode.controlsContainerNode.alpha, duration: 0.25)
            
            strongSelf.titleNode.layer.animateAlpha(from: 0.0, to: strongSelf.titleNode.alpha, duration: 0.25)
            strongSelf.subtitleNode.layer.animateAlpha(from: 0.0, to: strongSelf.subtitleNode.alpha, duration: 0.25)

            strongSelf.animateOverlaysFadeIn?()
        }
        
        let optionView = ProfileOptionsView( onTapOption: { [weak self] in
            print("selected: \($0)")
            switch $0 {
                case .chat:
                    self?.performButtonAction?(.message, nil)
                case .search:
                    self?.performButtonAction?(.search, nil)
                case .call:
                    self?.performButtonAction?(.call, nil)
                case .more:
                    self?.performButtonAction?(.more, nil)
            }
        })
        self.addSubnode(referenceNode)
                
        avatarActionsButtonNode.view.addSubviewWithSameSize(optionView)
        self.addSubnode(avatarActionsButtonNode)
    }
    
    deinit {
        self.emojiStatusPackDisposable.dispose()
    }
    
    override func didLoad() {
        super.didLoad()
        
        let usernameGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleUsernameLongPress(_:)))
        self.usernameNodeRawContainer.view.addGestureRecognizer(usernameGestureRecognizer)
        
        let phoneGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePhoneLongPress(_:)))
        self.subtitleNodeRawContainer.view.addGestureRecognizer(phoneGestureRecognizer)
    }
    
    @objc private func handleUsernameLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.displayCopyContextMenu?(self.usernameNodeRawContainer, !self.isAvatarExpanded, true)
        }
    }
    
    @objc private func handlePhoneLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.displayCopyContextMenu?(self.subtitleNodeRawContainer, true, !self.isAvatarExpanded)
        }
    }
    
    func invokeDisplayPremiumIntro() {
        self.displayPremiumIntro?(self.isAvatarExpanded ? self.titleExpandedCredibilityIconView : self.titleCredibilityIconView, nil, .never(), self.isAvatarExpanded)
    }
    
    func invokeDisplaySubscriptionIntro() {
        self.displaySubscriptionIntro?(self.isAvatarExpanded ? self.titleExpandedPeerTypeIconView : self.titlePeerTypeIconView, nil, .never(), self.isAvatarExpanded)
    }
    
    func initiateAvatarExpansion(gallery: Bool, first: Bool) {
        if let peer = self.peer, peer.profileImageRepresentations.isEmpty && gallery {
            self.requestOpenAvatarForEditing?(false)
            return
        }
        if self.isAvatarExpanded || gallery {
            if let currentEntry = self.avatarListNode.listContainerNode.currentEntry, let firstEntry = self.avatarListNode.listContainerNode.galleryEntries.first {
                let entry = first ? firstEntry : currentEntry
                self.requestAvatarExpansion?(true, self.avatarListNode.listContainerNode.galleryEntries, entry, self.avatarTransitionArguments(entry: currentEntry))
            }
        } else if let entry = self.avatarListNode.listContainerNode.galleryEntries.first {
            let _ = self.avatarListNode.avatarContainerNode.avatarNode
            self.requestAvatarExpansion?(false, self.avatarListNode.listContainerNode.galleryEntries, nil, self.avatarTransitionArguments(entry: entry))
        } else {
            self.cancelUpload?()
        }
    }
    
    func avatarTransitionArguments(entry: AvatarGalleryEntry) -> (ASDisplayNode, CGRect, () -> (UIView?, UIView?))? {
        if self.isAvatarExpanded {
            if let avatarNode = self.avatarListNode.listContainerNode.currentItemNode?.imageNode {
                return (avatarNode, avatarNode.bounds, { [weak avatarNode] in
                    return (avatarNode?.view.snapshotContentTree(unhide: true), nil)
                })
            } else {
                return nil
            }
        } else if entry == self.avatarListNode.listContainerNode.galleryEntries.first {
            let avatarNode = self.avatarListNode.avatarContainerNode.avatarNode
            return (avatarNode, avatarNode.bounds, { [weak avatarNode] in
                return (avatarNode?.view.snapshotContentTree(unhide: true), nil)
            })
        } else {
            return nil
        }
    }
    
    func addToAvatarTransitionSurface(view: UIView) {
        if self.isAvatarExpanded {
            self.avatarListNode.listContainerNode.view.addSubview(view)
        } else {
            self.view.addSubview(view)
        }
    }
    
    func updateAvatarIsHidden(entry: AvatarGalleryEntry?) {
        if let entry = entry {
            self.avatarListNode.avatarContainerNode.avatarNode.isHidden = entry == self.avatarListNode.listContainerNode.galleryEntries.first
            self.editingContentNode.avatarNode.isHidden = entry == self.avatarListNode.listContainerNode.galleryEntries.first
        } else {
            self.avatarListNode.avatarContainerNode.avatarNode.isHidden = false
            self.editingContentNode.avatarNode.isHidden = false
        }
        self.avatarListNode.listContainerNode.updateEntryIsHidden(entry: entry)
    }
        
    private enum CredibilityIcon: Equatable {
        case none
        case premium
        case verified
        case fake
        case scam
        case emojiStatus(PeerEmojiStatus)
    }
    
    private enum PeerTypeIcon: Equatable {
        case none
        case subscription
        case course
        case privateGroup
        case privateChannel
    }
    
    private enum AdultIcon: Equatable {
        case none
        case adult
    }
    
    private var currentCredibilityIcon: CredibilityIcon?
    private var currentPeerTypeIcon: PeerTypeIcon?
    private var currentAdultIcon: AdultIcon?
    
    enum PeerState {
        case ownAccount
        case otherAccount
        case notAccount
    }
    
    private var currentPanelStatusData: PeerInfoStatusData?
    private var peerState = PeerState.notAccount

    
    // MARK: - update(width)
    
    private func userStatus(_ user: ElloAppUser, presentationData: PresentationData) -> String {
        let publicString = user.isPublic ? presentationData.strings.User_Status_Public : presentationData.strings.User_Status_Private
        if user.isBusiness {
            return presentationData.strings.User_Status_Business + " (\(publicString))"
        } else {
            return presentationData.strings.User_Status_Personal + " (\(publicString))"
        }
    }
    
    func update(width: CGFloat,
                containerHeight: CGFloat,
                containerInset: CGFloat,
                statusBarHeight: CGFloat,
                navigationHeight: CGFloat,
                isModalOverlay: Bool,
                isMediaOnly: Bool,
                contentOffset: CGFloat,
                paneContainerY: CGFloat,
                presentationData: PresentationData,
                peer: Peer?,
                cachedData: CachedPeerData?,
                notificationSettings: ElloAppPeerNotificationSettings?,
                statusData: PeerInfoStatusData?,
                panelStatusData: (PeerInfoStatusData?, PeerInfoStatusData?, CGFloat?),
                isSecretChat: Bool,
                isContact: Bool,
                isSettings: Bool,
                state: PeerInfoState,
                metrics: LayoutMetrics,
                transition: ContainedViewLayoutTransition,
                additive: Bool) -> CGFloat {
        
        if let peer = peer {
            if peer.id == context.account.peerId {
                peerState = .ownAccount
            } else {
//                if let _ = peer as? ElloAppUser {
//
//                    peerState = .otherAccount
//                } else {
//                    peerState = .notAccount
//                }
                peerState = .otherAccount
                if !isContact {
                    peerState = .notAccount
                }
            }
        } else {
            peerState = .notAccount
        }
                
        self.state = state
        self.peer = peer
        self.avatarListNode.listContainerNode.peer = peer
        
        let previousPanelStatusData = self.currentPanelStatusData
        self.currentPanelStatusData = panelStatusData.0
        
        let avatarSize: CGFloat = isModalOverlay ? 200.0 : 90.0
        self.avatarSize = avatarSize
        
        var contentOffset = contentOffset
        
        if isMediaOnly {
            if isModalOverlay {
                contentOffset = 312.0
            } else {
                contentOffset = 212.0
            }
        }
        
        let themeUpdated = self.presentationData?.theme !== presentationData.theme
        self.presentationData = presentationData
        
        let premiumConfiguration = PremiumConfiguration.with(appConfiguration: self.context.currentAppConfiguration.with { $0 })
        
        let credibilityIcon: CredibilityIcon
        let peerTypeIcon: PeerTypeIcon
        let adultIcon: AdultIcon
        if let peer = peer {
            if peer.isFake {
                credibilityIcon = .fake
            } else if peer.isScam {
                credibilityIcon = .scam
            } else if let user = peer as? ElloAppUser, let emojiStatus = user.emojiStatus, !premiumConfiguration.isPremiumDisabled {
                credibilityIcon = .emojiStatus(emojiStatus)
            } else if peer.isVerified {
                credibilityIcon = .verified
            } else if peer.isPremium && !premiumConfiguration.isPremiumDisabled && (peer.id != self.context.account.peerId || self.isSettings) {
                credibilityIcon = .premium
            } else {
                credibilityIcon = .none
            }
            if let channel = peer as? ElloAppChannel {
                if channel.isPaid {
                    switch channel.payType {
                    case .free:
                        peerTypeIcon = .none
                    case .onlineCourse:
                        peerTypeIcon = .course
                    case .subscription:
                        peerTypeIcon = .subscription
                    }
                } else if channel.isPrivate {
                    peerTypeIcon = channel.isGroup ? .privateGroup : .privateChannel
                } else {
                    peerTypeIcon = .none
                }
                adultIcon = channel.isAdult ? .adult : .none
            } else {
                peerTypeIcon = .none
                adultIcon = .none
            }
        } else {
            credibilityIcon = .none
            peerTypeIcon = .none
            adultIcon = .none
        }
        
        if themeUpdated || currentPeerTypeIcon != peerTypeIcon {
            currentPeerTypeIcon = peerTypeIcon
            switch peerTypeIcon {
            case .none:
                titlePeerTypeIconView.image = nil
                titlePeerTypeIconSize = .zero
                
                titleExpandedPeerTypeIconView.image = nil
                titleExpandedPeerTypeIconSize = .zero
            case .subscription:
                titlePeerTypeIconView.image = PresentationResourcesChatList.peerTypeIcon(payType: .subscription)
                titlePeerTypeIconSize = titlePeerTypeIconView.frame.size
                
                titleExpandedPeerTypeIconView.image = PresentationResourcesChatList.peerTypeIcon(payType: .subscription)?
                    .withRenderingMode(.alwaysTemplate)
                titleExpandedPeerTypeIconSize = titleExpandedPeerTypeIconView.frame.size
            case .course:
                titlePeerTypeIconView.image = PresentationResourcesChatList.peerTypeIcon(payType: .onlineCourse)
                titlePeerTypeIconSize = titlePeerTypeIconView.frame.size
                
                titleExpandedPeerTypeIconView.image = PresentationResourcesChatList.peerTypeIcon(payType: .onlineCourse)
                titleExpandedPeerTypeIconSize = titleExpandedPeerTypeIconView.frame.size
            case .privateGroup:
                titlePeerTypeIconView.image = PresentationResourcesChatList.privateChannelIcon()?
                    .withRenderingMode(.alwaysTemplate)
                titlePeerTypeIconView.tintColor = presentationData.theme.chatList.titlePrivateGroupColor
                titlePeerTypeIconSize = titlePeerTypeIconView.frame.size
                
                titleExpandedPeerTypeIconView.image = PresentationResourcesChatList.privateChannelIcon()?
                    .withRenderingMode(.alwaysTemplate)
                titleExpandedPeerTypeIconSize = titleExpandedPeerTypeIconView.frame.size
            case .privateChannel:
                titlePeerTypeIconView.image = PresentationResourcesChatList.privateChannelIcon()?
                    .withRenderingMode(.alwaysTemplate)
                titlePeerTypeIconView.tintColor = presentationData.theme.chatList.titlePrivateChannelColor
                titlePeerTypeIconSize = titlePeerTypeIconView.frame.size
                
                titleExpandedPeerTypeIconView.image = PresentationResourcesChatList.privateChannelIcon()?
                    .withRenderingMode(.alwaysTemplate)
                titleExpandedPeerTypeIconSize = titleExpandedPeerTypeIconView.frame.size
            }
        }
        
        if currentAdultIcon != adultIcon {
            currentAdultIcon = adultIcon
            switch adultIcon {
            case .none:
                titleAdultIconView.image = nil
                titleAdultIconSize = .zero
                
                titleExpandedAdultIconView.image = nil
                titleExpandedAdultIconSize = .zero
            case .adult:
                titleAdultIconView.image = PresentationResourcesChatList.adultIcon()
                titleAdultIconSize = titleAdultIconView.frame.size
                
                titleExpandedAdultIconView.image = PresentationResourcesChatList.adultIcon()
                titleExpandedAdultIconSize = titleExpandedAdultIconView.frame.size
            }
        }
        
        if themeUpdated || self.currentCredibilityIcon != credibilityIcon {
            self.currentCredibilityIcon = credibilityIcon
            
            var currentEmojiStatus: PeerEmojiStatus?
            let emojiRegularStatusContent: EmojiStatusComponent.Content
            let emojiExpandedStatusContent: EmojiStatusComponent.Content
            switch credibilityIcon {
            case .none:
                emojiRegularStatusContent = .none
                emojiExpandedStatusContent = .none
            case .premium:
                emojiRegularStatusContent = .premium(color: presentationData.theme.list.itemAccentColor)
                emojiExpandedStatusContent = .premium(color: UIColor(rgb: 0xffffff, alpha: 0.75))
            case .verified:
                emojiRegularStatusContent = .verified(fillColor: presentationData.theme.list.itemCheckColors.fillColor, foregroundColor: presentationData.theme.list.itemCheckColors.foregroundColor, sizeType: .large)
                emojiExpandedStatusContent = .verified(fillColor: UIColor(rgb: 0xffffff, alpha: 0.75), foregroundColor: .clear, sizeType: .large)
            case .fake:
                emojiRegularStatusContent = .text(color: presentationData.theme.chat.message.incoming.scamColor, string: presentationData.strings.Message_FakeAccount.uppercased())
                emojiExpandedStatusContent = emojiRegularStatusContent
            case .scam:
                emojiRegularStatusContent = .text(color: presentationData.theme.chat.message.incoming.scamColor, string: presentationData.strings.Message_ScamAccount.uppercased())
                emojiExpandedStatusContent = emojiRegularStatusContent
            case let .emojiStatus(emojiStatus):
                currentEmojiStatus = emojiStatus
                emojiRegularStatusContent = .animation(content: .customEmoji(fileId: emojiStatus.fileId), size: CGSize(width: 80.0, height: 80.0), placeholderColor: presentationData.theme.list.mediaPlaceholderColor, themeColor: presentationData.theme.list.itemAccentColor, loopMode: .forever)
                emojiExpandedStatusContent = .animation(content: .customEmoji(fileId: emojiStatus.fileId), size: CGSize(width: 80.0, height: 80.0), placeholderColor: UIColor(rgb: 0xffffff, alpha: 0.15), themeColor: presentationData.theme.list.itemAccentColor, loopMode: .forever)
            }
            
            let animateStatusIcon = !self.titleCredibilityIconView.bounds.isEmpty
            
            let iconSize = self.titleCredibilityIconView.update(
                transition: animateStatusIcon ? Transition(animation: .curve(duration: 0.3, curve: .easeInOut)) : .immediate,
                component: AnyComponent(EmojiStatusComponent(
                    context: self.context,
                    animationCache: self.animationCache,
                    animationRenderer: self.animationRenderer,
                    content: emojiRegularStatusContent,
                    isVisibleForAnimations: true,
                    useSharedAnimation: true,
                    action: { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.displayPremiumIntro?(strongSelf.titleCredibilityIconView, currentEmojiStatus, strongSelf.emojiStatusFileAndPackTitle.get(), false)
                    },
                    emojiFileUpdated: { [weak self] emojiFile in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        if let emojiFile = emojiFile {
                            strongSelf.emojiStatusFileAndPackTitle.set(.never())
                            
                            for attribute in emojiFile.attributes {
                                if case let .CustomEmoji(_, _, packReference) = attribute, let packReference = packReference {
                                    strongSelf.emojiStatusPackDisposable.set((strongSelf.context.engine.stickers.loadedStickerPack(reference: packReference, forceActualized: false)
                                    |> filter { result in
                                        if case .result = result {
                                            return true
                                        } else {
                                            return false
                                        }
                                    }
                                    |> mapToSignal { result -> Signal<(ElloAppMediaFile, LoadedStickerPack)?, NoError> in
                                        if case let .result(_, items, _) = result {
                                            return .single(items.first.flatMap { ($0.file, result) })
                                        } else {
                                            return .complete()
                                        }
                                    }).start(next: { fileAndPackTitle in
                                        guard let strongSelf = self else {
                                            return
                                        }
                                        strongSelf.emojiStatusFileAndPackTitle.set(.single(fileAndPackTitle))
                                    }))
                                    break
                                }
                            }
                        } else {
                            strongSelf.emojiStatusFileAndPackTitle.set(.never())
                        }
                    }
                )),
                environment: {},
                containerSize: CGSize(width: 34.0, height: 34.0)
            )
            let expandedIconSize = self.titleExpandedCredibilityIconView.update(
                transition: animateStatusIcon ? Transition(animation: .curve(duration: 0.3, curve: .easeInOut)) : .immediate,
                component: AnyComponent(EmojiStatusComponent(
                    context: self.context,
                    animationCache: self.animationCache,
                    animationRenderer: self.animationRenderer,
                    content: emojiExpandedStatusContent,
                    isVisibleForAnimations: true,
                    useSharedAnimation: true,
                    action: { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.displayPremiumIntro?(strongSelf.titleExpandedCredibilityIconView, currentEmojiStatus, strongSelf.emojiStatusFileAndPackTitle.get(), true)
                    }
                )),
                environment: {},
                containerSize: CGSize(width: 34.0, height: 34.0)
            )
            
            self.credibilityIconSize = iconSize
            self.titleExpandedCredibilityIconSize = expandedIconSize
        }
        
        self.regularContentNode.alpha = state.isEditing ? 0.0 : 1.0
        self.buttonsContainerNode.alpha = self.regularContentNode.alpha
        self.editingContentNode.alpha = state.isEditing ? 1.0 : 0.0
        
        let editingContentHeight = self.editingContentNode.update(width: width, safeInset: containerInset, statusBarHeight: statusBarHeight, navigationHeight: navigationHeight, isModalOverlay: isModalOverlay, peer: state.isEditing ? peer : nil, cachedData: cachedData, isContact: isContact, isSettings: isSettings, presentationData: presentationData, transition: transition)
        transition.updateFrame(node: self.editingContentNode, frame: CGRect(origin: CGPoint(x: 0.0, y: -contentOffset), size: CGSize(width: width, height: editingContentHeight)))
        
        let avatarOverlayFarme = self.editingContentNode.convert(self.editingContentNode.avatarNode.frame, to: self)
        transition.updateFrame(node: self.avatarOverlayNode, frame: avatarOverlayFarme)
        
        var transitionSourceHeight: CGFloat = 0.0
        var transitionFraction: CGFloat = 0.0
        var transitionSourceAvatarFrame = CGRect()
        var transitionSourceTitleFrame = CGRect()
        var transitionSourceSubtitleFrame = CGRect()
        
        self.backgroundNode.updateColor(color: presentationData.theme.rootController.navigationBar.blurredBackgroundColor, transition: .immediate)
        
        let headerBackgroundColor: UIColor = presentationData.theme.list.blocksBackgroundColor
        var effectiveSeparatorAlpha: CGFloat
        if let navigationTransition = self.navigationTransition, let sourceAvatarNode = (navigationTransition.sourceNavigationBar.rightButtonNode.singleCustomNode as? ChatAvatarNavigationNode)?.avatarNode {
            transitionSourceHeight = navigationTransition.sourceNavigationBar.backgroundNode.bounds.height
            transitionFraction = navigationTransition.fraction
            transitionSourceAvatarFrame = sourceAvatarNode.view.convert(sourceAvatarNode.view.bounds, to: navigationTransition.sourceNavigationBar.view)
            transitionSourceTitleFrame = navigationTransition.sourceTitleFrame
            transitionSourceSubtitleFrame = navigationTransition.sourceSubtitleFrame

            self.expandedBackgroundNode.updateColor(color: presentationData.theme.rootController.navigationBar.blurredBackgroundColor.mixedWith(headerBackgroundColor, alpha: 1.0 - transitionFraction), forceKeepBlur: true, transition: transition)
            effectiveSeparatorAlpha = transitionFraction
            
            if self.isAvatarExpanded, case .animated = transition, transitionFraction == 1.0 {
                self.avatarListNode.animateAvatarCollapse(transition: transition)
            }
        } else {
            let contentOffset = max(0.0, contentOffset - 140.0)
            let backgroundTransitionFraction: CGFloat = max(0.0, min(1.0, contentOffset / 30.0))

            self.expandedBackgroundNode.updateColor(color: presentationData.theme.rootController.navigationBar.opaqueBackgroundColor.mixedWith(headerBackgroundColor, alpha: 1.0 - backgroundTransitionFraction), forceKeepBlur: true, transition: transition)
            effectiveSeparatorAlpha = backgroundTransitionFraction
        }
        
        self.avatarListNode.avatarContainerNode.updateTransitionFraction(transitionFraction, transition: transition)
        self.avatarListNode.listContainerNode.currentItemNode?.updateTransitionFraction(transitionFraction, transition: transition)
        self.avatarOverlayNode.updateTransitionFraction(transitionFraction, transition: transition)
        
        if self.navigationTitle != presentationData.strings.EditProfile_Title || themeUpdated {
            self.navigationTitleNode.attributedText = NSAttributedString(string: presentationData.strings.EditProfile_Title, 
                                                                         font: Font.semibold(17.0),
                                                                         textColor: presentationData.theme.rootController.navigationBar.primaryTextColor)
        }
        
        let navigationTitleSize = self.navigationTitleNode.updateLayout(CGSize(width: width, height: navigationHeight))
        self.navigationTitleNode.frame = CGRect(origin: CGPoint(x: floorToScreenPixels((width - navigationTitleSize.width) / 2.0), y: navigationHeight - 44.0 + floorToScreenPixels((44.0 - navigationTitleSize.height) / 2.0)), size: navigationTitleSize)
        
        self.navigationBackgroundNode.frame = CGRect(origin: CGPoint(), size: CGSize(width: width, height: navigationHeight))
        self.navigationBackgroundBackgroundNode.frame = CGRect(origin: CGPoint(), size: CGSize(width: width, height: navigationHeight))
        self.navigationSeparatorNode.frame = CGRect(origin: CGPoint(x: 0.0, y: navigationHeight), size: CGSize(width: width, height: UIScreenPixel))
        self.navigationBackgroundBackgroundNode.backgroundColor = presentationData.theme.rootController.navigationBar.opaqueBackgroundColor
        self.navigationSeparatorNode.backgroundColor = presentationData.theme.rootController.navigationBar.separatorColor

        let navigationSeparatorAlpha: CGFloat = state.isEditing && self.isSettings ? min(1.0, contentOffset / (navigationHeight * 0.5)) : 0.0
        transition.updateAlpha(node: self.navigationBackgroundBackgroundNode, alpha: 1.0 - navigationSeparatorAlpha)
        transition.updateAlpha(node: self.navigationSeparatorNode, alpha: navigationSeparatorAlpha)

        self.separatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        
        let expandedAvatarControlsHeight: CGFloat = 61.0
        let expandedAvatarListHeight = min(width, containerHeight - expandedAvatarControlsHeight)
        let expandedAvatarListSize = CGSize(width: width, height: expandedAvatarListHeight)
        
        let buttonKeys: [PeerInfoHeaderButtonKey] = self.isSettings ? [] : peerInfoHeaderButtons(peer: peer, cachedData: cachedData, isOpenedFromChat: self.isOpenedFromChat, isExpanded: true, videoCallsEnabled: width > 320.0 && self.videoCallsEnabled, isSecretChat: isSecretChat, isContact: isContact)
        
        var isPremium = false
        var isVerified = false
        var isFake = false
        
        let titleString: NSAttributedString
        let expandedTitleString: NSAttributedString
        let subtitleString: NSAttributedString
        let expandedSubtitleString: NSAttributedString
        var panelSubtitleString: NSAttributedString?
        var nextPanelSubtitleString: NSAttributedString?
        let usernameString: NSAttributedString
        
        if let peer = peer {
            isPremium = peer.isPremium
            isVerified = peer.isVerified
            isFake = peer.isFake || peer.isScam
        }
        
        if let peer = peer {
            func title() -> String {
                var title: String
                if peer.id == self.context.account.peerId && !self.isSettings {
                    title = presentationData.strings.Conversation_SavedMessages
                } else if peer.id == self.context.account.peerId && !self.isSettings {
                    title = presentationData.strings.DialogList_Replies
                } else {
                    title = EnginePeer(peer).displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
                }
                
                title = title.replacingOccurrences(of: "\u{1160}", with: "").replacingOccurrences(of: "\u{3164}", with: "")
                if title.isEmpty {
                    if let peer = peer as? ElloAppUser, let phone = peer.phone {
                        title = formatPhoneNumber(phone)
                    } else if let addressName = peer.addressName {
                        title = "@\(addressName)"
                    } else {
                        title = " "
                    }
                }

                return title
            }

            var titleColor = presentationData.theme.list.itemPrimaryTextColor
            if let channel = peer as? ElloAppChannel, channel.isPrivate {
                titleColor = channel.isGroup
                ? presentationData.theme.chatList.titlePrivateGroupColor
                : presentationData.theme.chatList.titlePrivateChannelColor
            }
            let title: String = title()
            titleString = NSAttributedString(string: title, font: Font.regular(30.0), textColor: titleColor)
            expandedTitleString = NSAttributedString(string: title, font: Font.regular(30.0), textColor: .white)
            
            if peer.id.isNotificationsBotID {
                subtitleString = NSAttributedString()
                expandedSubtitleString = NSAttributedString()
                usernameString = NSAttributedString()
            } else if self.isSettings, let user = peer as? ElloAppUser {
                let userStatus = userStatus(user, presentationData: presentationData)
                var userName: String = formatPhoneNumber(user.phone ?? "")
                if let addressName = user.addressName {
                    userName = "@\(addressName)"
                }
                
                if userStatus.isEmpty {
                    
                    expandedSubtitleString = NSAttributedString(string: userName, font: Font.regular(15.0), textColor: UIColor(rgb: 0xffffff, alpha: 0.7))
                    subtitleString = NSAttributedString(string: userName, font: Font.regular(17.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
                    usernameString = NSAttributedString(string: "", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
                } else {
                    func text(status: String, userName: String, font: UIFont, statusColor: UIColor = .black, userNameColor: UIColor) -> NSAttributedString {
                        let text = NSMutableAttributedString()
                        text.append(NSAttributedString(string: userStatus, font: font, textColor: statusColor))
                        text.append(NSAttributedString(string: " • \(userName)", font: font, textColor: userNameColor))
                        return text
                    }
                    
                    expandedSubtitleString = text(status: userStatus, userName: userName, font: Font.regular(15.0), statusColor: UIColor.white, userNameColor: presentationData.theme.list.itemSecondaryTextColor)
                    subtitleString = text(status: userStatus, userName: userName, font: Font.regular(17.0), userNameColor: presentationData.theme.list.itemSecondaryTextColor)
                    usernameString = NSAttributedString(string: "", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
                }
                
            } else if let statusData = statusData {
                let subtitleColor: UIColor
                if statusData.isActivity {
                    subtitleColor = presentationData.theme.list.itemAccentColor
                } else {
                    subtitleColor = presentationData.theme.list.itemSecondaryTextColor
                }
                
                expandedSubtitleString = NSAttributedString(string: statusData.text, font: Font.regular(15.0), textColor: UIColor(rgb: 0xffffff, alpha: 0.7))
                subtitleString = NSAttributedString(string: statusData.text, font: Font.regular(17.0), textColor: subtitleColor)
                usernameString = NSAttributedString(string: "", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)

                let (maybePanelStatusData, maybeNextPanelStatusData, _) = panelStatusData
                if let panelStatusData = maybePanelStatusData {
                    let subtitleColor: UIColor
                    if panelStatusData.isActivity {
                        subtitleColor = presentationData.theme.list.itemAccentColor
                    } else {
                        subtitleColor = presentationData.theme.list.itemSecondaryTextColor
                    }
                    panelSubtitleString = NSAttributedString(string: panelStatusData.text, font: Font.regular(17.0), textColor: subtitleColor)
                }
                
                if let nextPanelStatusData = maybeNextPanelStatusData {
                    nextPanelSubtitleString = NSAttributedString(string: nextPanelStatusData.text, font: Font.regular(17.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
                }
            } else {
                subtitleString = NSAttributedString(string: " ", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
                expandedSubtitleString = subtitleString
                usernameString = NSAttributedString(string: "", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
            }
        } else {
            titleString = NSAttributedString(string: " ", font: Font.semibold(24.0), textColor: presentationData.theme.list.itemPrimaryTextColor)
            expandedTitleString = titleString
            subtitleString = NSAttributedString(string: " ", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
            expandedSubtitleString = subtitleString
            usernameString = NSAttributedString(string: "", font: Font.regular(15.0), textColor: presentationData.theme.list.itemSecondaryTextColor)
        }
        
//        if let addressName = user.addressName, !addressName.isEmpty {
//            subtitle = "\(subtitle) • @\(addressName)"
//        }

        
        let textSideInset: CGFloat = 36.0
        let expandedAvatarHeight: CGFloat = expandedAvatarListSize.height
        
        var adultIconSizeWithInset = 0.0
        if titleAdultIconSize != .zero {
            adultIconSizeWithInset = titleAdultIconSize.width + 8.0
        }
        var peerTypeSizeWithInset = 0.0
        if titlePeerTypeIconSize != .zero {
            peerTypeSizeWithInset = titlePeerTypeIconSize.width + 8.0
        }
        var credibilityIconSizeWithInset = 0.0
        if let credibilityIconSize = credibilityIconSize, isVerified {
            credibilityIconSizeWithInset = credibilityIconSize.width + 4.0
        }
        let titleConstrainedSize = CGSize(
            width: width - peerTypeSizeWithInset - adultIconSizeWithInset - textSideInset - credibilityIconSizeWithInset - (isPremium || isFake ? 20.0 : 0.0),
            height: .greatestFiniteMagnitude
        )
        
        let titleNodeLayout = self.titleNode.updateLayout(states: [
            TitleNodeStateRegular: MultiScaleTextState(attributedText: titleString, constrainedSize: titleConstrainedSize),
            TitleNodeStateExpanded: MultiScaleTextState(attributedText: expandedTitleString, constrainedSize: titleConstrainedSize)
        ], mainState: TitleNodeStateRegular)
        self.titleNode.accessibilityLabel = titleString.string
        
        let subtitleNodeLayout = self.subtitleNode.updateLayout(states: [
            TitleNodeStateRegular: MultiScaleTextState(attributedText: subtitleString, constrainedSize: titleConstrainedSize),
            TitleNodeStateExpanded: MultiScaleTextState(attributedText: expandedSubtitleString, constrainedSize: titleConstrainedSize)
        ], mainState: TitleNodeStateRegular)
        self.subtitleNode.accessibilityLabel = subtitleString.string
        
        if let previousPanelStatusData = previousPanelStatusData, let currentPanelStatusData = panelStatusData.0, let previousPanelStatusDataKey = previousPanelStatusData.key, let currentPanelStatusDataKey = currentPanelStatusData.key, previousPanelStatusDataKey != currentPanelStatusDataKey {
            if let snapshotView = self.panelSubtitleNode.view.snapshotContentTree() {
                let direction: CGFloat = previousPanelStatusDataKey.rawValue > currentPanelStatusDataKey.rawValue ? 1.0 : -1.0
                
                self.panelSubtitleNode.view.superview?.addSubview(snapshotView)
                snapshotView.frame = self.panelSubtitleNode.frame
                snapshotView.layer.animatePosition(from: CGPoint(), to: CGPoint(x: 100.0 * direction, y: 0.0), duration: 0.4, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false, additive: true, completion: { [weak snapshotView] _ in
                    snapshotView?.removeFromSuperview()
                })
                snapshotView.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.3, removeOnCompletion: false)
                
                self.panelSubtitleNode.layer.animatePosition(from: CGPoint(x: 100.0 * direction * -1.0, y: 0.0), to: CGPoint(), duration: 0.4, timingFunction: kCAMediaTimingFunctionSpring, additive: true)
                self.panelSubtitleNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
            }
        }
        
        let panelSubtitleNodeLayout = self.panelSubtitleNode.updateLayout(states: [
            TitleNodeStateRegular: MultiScaleTextState(attributedText: panelSubtitleString ?? subtitleString, constrainedSize: titleConstrainedSize),
            TitleNodeStateExpanded: MultiScaleTextState(attributedText: panelSubtitleString ?? subtitleString, constrainedSize: titleConstrainedSize)
        ], mainState: TitleNodeStateRegular)
        self.panelSubtitleNode.accessibilityLabel = (panelSubtitleString ?? subtitleString).string
        
        let nextPanelSubtitleNodeLayout = self.nextPanelSubtitleNode.updateLayout(states: [
            TitleNodeStateRegular: MultiScaleTextState(attributedText: nextPanelSubtitleString ?? subtitleString, constrainedSize: titleConstrainedSize),
            TitleNodeStateExpanded: MultiScaleTextState(attributedText: nextPanelSubtitleString ?? subtitleString, constrainedSize: titleConstrainedSize)
        ], mainState: TitleNodeStateRegular)
        if let _ = nextPanelSubtitleString {
            self.nextPanelSubtitleNode.isHidden = false
        }
        
        let usernameNodeLayout = self.usernameNode.updateLayout(states: [
            TitleNodeStateRegular: MultiScaleTextState(attributedText: usernameString, constrainedSize: CGSize(width: titleConstrainedSize.width, height: titleConstrainedSize.height)),
            TitleNodeStateExpanded: MultiScaleTextState(attributedText: usernameString, constrainedSize: CGSize(width: width - titleNodeLayout[TitleNodeStateExpanded]!.size.width - 8.0, height: titleConstrainedSize.height))
        ], mainState: TitleNodeStateRegular)
        self.usernameNode.accessibilityLabel = usernameString.string
        
        let avatarFrame = CGRect(origin: CGPoint(x: floor((width - avatarSize) / 2.0), y: statusBarHeight + 13.0), size: CGSize(width: avatarSize, height: avatarSize))
        let avatarCenter = CGPoint(x: (1.0 - transitionFraction) * avatarFrame.midX + transitionFraction * transitionSourceAvatarFrame.midX, y: (1.0 - transitionFraction) * avatarFrame.midY + transitionFraction * transitionSourceAvatarFrame.midY)
        
        let titleSize = titleNodeLayout[TitleNodeStateRegular]!.size
        let titleExpandedSize = titleNodeLayout[TitleNodeStateExpanded]!.size
        let subtitleSize = subtitleNodeLayout[TitleNodeStateRegular]!.size
        let _ = panelSubtitleNodeLayout[TitleNodeStateRegular]!.size
        let _ = nextPanelSubtitleNodeLayout[TitleNodeStateRegular]!.size
        let usernameSize = usernameNodeLayout[TitleNodeStateRegular]!.size
        
        let titleHorizontalOffset: CGFloat = 0.0
        if let credibilityIconSize = self.credibilityIconSize, let titleExpandedCredibilityIconSize = self.titleExpandedCredibilityIconSize {
//            titleHorizontalOffset = -(credibilityIconSize.width + 4.0) / 2.0
            var collapsedTransitionOffset: CGFloat = 0.0
            if let navigationTransition = self.navigationTransition {
                collapsedTransitionOffset = -10.0 * navigationTransition.fraction
            }
            
            transition.updateFrame(view: self.titleCredibilityIconView, frame: CGRect(origin: CGPoint(x: titleSize.width + 4.0 + collapsedTransitionOffset, y: floor((titleSize.height - credibilityIconSize.height) / 2.0) + 2.0), size: credibilityIconSize))
            transition.updateFrame(view: self.titleExpandedCredibilityIconView, frame: CGRect(origin: CGPoint(x: titleExpandedSize.width + 4.0, y: floor((titleExpandedSize.height - titleExpandedCredibilityIconSize.height) / 2.0) + 1.0), size: titleExpandedCredibilityIconSize))
        }
        
        if titleAdultIconView.image != nil, titleExpandedAdultIconView.image != nil {
            var collapsedTransitionOffset: CGFloat = 0.0
            if let navigationTransition = self.navigationTransition {
                collapsedTransitionOffset = -10.0 * navigationTransition.fraction
            }
            
            let iconFrame = CGRect(
                origin: CGPoint(
                    x: -adultIconSizeWithInset - collapsedTransitionOffset,
                    y: floor((titleSize.height - titleAdultIconSize.height) / 2.0) + 2.0
                ),
                size: titleAdultIconSize
            )
            transition.updateFrame(view: titleAdultIconView, frame: iconFrame)
            
            let expandedIconFrame = CGRect(
                origin: CGPoint(
                    x: -adultIconSizeWithInset,
                    y: floor((titleExpandedSize.height - titleExpandedAdultIconSize.height) / 2.0) + 1.0
                ),
                size: titleExpandedAdultIconSize
            )
            transition.updateFrame(view: self.titleExpandedAdultIconView, frame: expandedIconFrame)
        }
        
        if titlePeerTypeIconView.image != nil, titleExpandedPeerTypeIconView.image != nil {
            var collapsedTransitionOffset: CGFloat = 0.0
            if let navigationTransition = self.navigationTransition {
                collapsedTransitionOffset = -10.0 * navigationTransition.fraction
            }
            
            let titleIconFrame = CGRect(
                origin: CGPoint(
                    x: titleAdultIconView.frame.minX - peerTypeSizeWithInset - collapsedTransitionOffset,
                    y: floor((titleSize.height - titlePeerTypeIconSize.height) / 2.0) + 2.0
                ),
                size: titlePeerTypeIconSize
            )
            transition.updateFrame(view: titlePeerTypeIconView, frame: titleIconFrame)
            
            let titleExpandedIconFrame = CGRect(
                origin: CGPoint(
                    x: titleExpandedAdultIconView.frame.minX - peerTypeSizeWithInset,
                    y: floor((titleExpandedSize.height - titleExpandedPeerTypeIconSize.height) / 2.0) + 1.0
                ),
                size: titleExpandedPeerTypeIconSize
            )
            transition.updateFrame(view: titleExpandedPeerTypeIconView, frame: titleExpandedIconFrame)
        }
        
        var titleFrame: CGRect
        let subtitleFrame: CGRect
        let usernameFrame: CGRect
        let usernameSpacing: CGFloat = 4.0
        
        transition.updateFrame(node: self.avatarListNode.listContainerNode.bottomShadowNode, frame: CGRect(origin: CGPoint(x: 0.0, y: expandedAvatarHeight - 70.0), size: CGSize(width: width, height: 70.0)))
        
        if self.isAvatarExpanded {
            let scale = 0.7
            let minTitleSize = CGSize(width: titleSize.width * scale, height: titleSize.height * scale)
            subtitleFrame = CGRect(origin: CGPoint(x: 16.0, y: expandedAvatarHeight - subtitleSize.height - 11.0), size: subtitleSize)
            
            titleFrame = CGRect(
                origin: CGPoint(
                    x: subtitleFrame.origin.x + (peerTypeSizeWithInset + adultIconSizeWithInset) * scale,
                    y: subtitleFrame.minY - minTitleSize.height - 3.0
                ),
                size: minTitleSize
            )
            usernameFrame = CGRect(origin: CGPoint(x: width - usernameSize.width - 16.0, y: titleFrame.midY - usernameSize.height / 2.0), size: usernameSize)
        } else {
            titleFrame = CGRect(origin: CGPoint(x: floorToScreenPixels((width - titleSize.width + peerTypeSizeWithInset + adultIconSizeWithInset - credibilityIconSizeWithInset) / 2.0), y: avatarFrame.maxY + 9.0 + (subtitleSize.height.isZero ? 11.0 : 0.0)), size: titleSize)
                        
            let totalSubtitleWidth = subtitleSize.width + usernameSpacing + usernameSize.width
            if usernameSize.width == 0.0 {
                subtitleFrame = CGRect(origin: CGPoint(x: floorToScreenPixels((width - subtitleSize.width) / 2.0), y: titleFrame.maxY + 1.0), size: subtitleSize)
                usernameFrame = CGRect(origin: CGPoint(x: floorToScreenPixels((width - usernameSize.width) / 2.0), y: subtitleFrame.maxY + 1.0), size: usernameSize)
            } else {
                subtitleFrame = CGRect(origin: CGPoint(x: floorToScreenPixels((width - totalSubtitleWidth) / 2.0), y: titleFrame.maxY + 1.0), size: subtitleSize)
                usernameFrame = CGRect(origin: CGPoint(x: subtitleFrame.maxX + usernameSpacing, y: titleFrame.maxY + 1.0), size: usernameSize)
            }
        }
        
        let singleTitleLockOffset: CGFloat = (peer?.id == self.context.account.peerId || subtitleSize.height.isZero) ? 8.0 : 0.0
        
        let titleLockOffset: CGFloat = 7.0 + singleTitleLockOffset
        let titleMaxLockOffset: CGFloat = 7.0
        var titleCollapseOffset = titleFrame.midY - statusBarHeight - titleLockOffset
        if case .regular = metrics.widthClass {
            titleCollapseOffset -= 7.0
        }
        let titleOffset = -min(titleCollapseOffset, contentOffset)
        let titleCollapseFraction = max(0.0, min(1.0, contentOffset / titleCollapseOffset))
        
        let titleMinScale: CGFloat = 0.6
        let subtitleMinScale: CGFloat = 0.8
        let avatarMinScale: CGFloat = 0.7
        
        let apparentTitleLockOffset = (1.0 - titleCollapseFraction) * 0.0 + titleCollapseFraction * titleMaxLockOffset

        let paneAreaExpansionDistance: CGFloat = 32.0
        let effectiveAreaExpansionFraction: CGFloat
        if state.isEditing {
            effectiveAreaExpansionFraction = 0.0
        } else if isSettings {
            var paneAreaExpansionDelta = (self.frame.maxY - navigationHeight) - contentOffset
            paneAreaExpansionDelta = max(0.0, min(paneAreaExpansionDelta, paneAreaExpansionDistance))
            effectiveAreaExpansionFraction = 1.0 - paneAreaExpansionDelta / paneAreaExpansionDistance
        } else {
            var paneAreaExpansionDelta = (paneContainerY - navigationHeight) - contentOffset
            paneAreaExpansionDelta = max(0.0, min(paneAreaExpansionDelta, paneAreaExpansionDistance))
            effectiveAreaExpansionFraction = 1.0 - paneAreaExpansionDelta / paneAreaExpansionDistance
        }
        
        let secondarySeparatorAlpha = 1.0 - effectiveAreaExpansionFraction
        if self.navigationTransition == nil && !self.isSettings && effectiveSeparatorAlpha == 1.0 && secondarySeparatorAlpha < 1.0 {
            effectiveSeparatorAlpha = secondarySeparatorAlpha
        }
        transition.updateAlpha(node: self.separatorNode, alpha: effectiveSeparatorAlpha)
        
        self.titleNode.update(stateFractions: [
            TitleNodeStateRegular: self.isAvatarExpanded ? 0.0 : 1.0,
            TitleNodeStateExpanded: self.isAvatarExpanded ? 1.0 : 0.0
        ], transition: transition)
        
        let subtitleAlpha: CGFloat
        var subtitleOffset: CGFloat = 0.0
        let panelSubtitleAlpha: CGFloat
        var panelSubtitleOffset: CGFloat = 0.0
        if self.isSettings {
            subtitleAlpha = 1.0 - titleCollapseFraction
            panelSubtitleAlpha = 0.0
        } else {
            if (panelSubtitleString ?? subtitleString) != subtitleString {
                subtitleAlpha = 1.0 - effectiveAreaExpansionFraction
                panelSubtitleAlpha = effectiveAreaExpansionFraction
                subtitleOffset = -effectiveAreaExpansionFraction * 5.0
                panelSubtitleOffset = (1.0 - effectiveAreaExpansionFraction) * 5.0
            } else {
                subtitleAlpha = 1.0
                panelSubtitleAlpha = 0.0
            }
        }
        self.subtitleNode.update(stateFractions: [
            TitleNodeStateRegular: self.isAvatarExpanded ? 0.0 : 1.0,
            TitleNodeStateExpanded: self.isAvatarExpanded ? 1.0 : 0.0
        ], alpha: subtitleAlpha, transition: transition)

        self.panelSubtitleNode.update(stateFractions: [
            TitleNodeStateRegular: self.isAvatarExpanded ? 0.0 : 1.0,
            TitleNodeStateExpanded: self.isAvatarExpanded ? 1.0 : 0.0
        ], alpha: panelSubtitleAlpha, transition: transition)
        self.nextPanelSubtitleNode.update(stateFractions: [
            TitleNodeStateRegular: self.isAvatarExpanded ? 0.0 : 1.0,
            TitleNodeStateExpanded: self.isAvatarExpanded ? 1.0 : 0.0
        ], alpha: panelSubtitleAlpha, transition: transition)
        
        self.usernameNode.update(stateFractions: [
            TitleNodeStateRegular: self.isAvatarExpanded ? 0.0 : 1.0,
            TitleNodeStateExpanded: self.isAvatarExpanded ? 1.0 : 0.0
        ], alpha: subtitleAlpha, transition: transition)
        
        let avatarScale: CGFloat
        let avatarOffset: CGFloat
        if self.navigationTransition != nil {
            avatarScale = ((1.0 - transitionFraction) * avatarFrame.width + transitionFraction * transitionSourceAvatarFrame.width) / avatarFrame.width
            avatarOffset = 0.0
        } else {
            avatarScale = 1.0 * (1.0 - titleCollapseFraction) + avatarMinScale * titleCollapseFraction
            avatarOffset = apparentTitleLockOffset + 0.0 * (1.0 - titleCollapseFraction) + 10.0 * titleCollapseFraction
        }
                
        if self.isAvatarExpanded {
            self.avatarListNode.listContainerNode.isHidden = false
            if !transitionSourceAvatarFrame.width.isZero {
                transition.updateCornerRadius(node: self.avatarListNode.listContainerNode,
                                              cornerRadius: transitionFraction * AvatarNodeClipStyle.defaultCornerRadius)
                transition.updateCornerRadius(node: self.avatarListNode.listContainerNode.controlsClippingNode,
                                              cornerRadius: AvatarNodeClipStyle.defaultCornerRadius)
            } else {
                transition.updateCornerRadius(node: self.avatarListNode.listContainerNode, cornerRadius: 0.0)
                transition.updateCornerRadius(node: self.avatarListNode.listContainerNode.controlsClippingNode, cornerRadius: 0.0)
            }
        } else if self.avatarListNode.listContainerNode.cornerRadius != AvatarNodeClipStyle.defaultCornerRadius {
            transition.updateCornerRadius(node: self.avatarListNode.listContainerNode.controlsClippingNode,
                                          cornerRadius: AvatarNodeClipStyle.defaultCornerRadius)
            transition.updateCornerRadius(node: self.avatarListNode.listContainerNode,
                                          cornerRadius: AvatarNodeClipStyle.defaultCornerRadius, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.avatarListNode.avatarContainerNode.canAttachVideo = true
                strongSelf.avatarListNode.listContainerNode.isHidden = true
                if !strongSelf.skipCollapseCompletion {
                    DispatchQueue.main.async {
                        strongSelf.avatarListNode.listContainerNode.isCollapsing = false
                    }
                }
            })
        }
        
        self.avatarListNode.update(size: CGSize(), avatarSize: avatarSize, isExpanded: self.isAvatarExpanded, peer: peer, theme: presentationData.theme, transition: transition)
        self.editingContentNode.avatarNode.update(peer: peer, 
                                                  item: self.avatarListNode.item,
                                                  updatingAvatar: state.updatingAvatar,
                                                  uploadProgress: state.avatarUploadProgress,
                                                  theme: presentationData.theme,
                                                  avatarSize: avatarSize,
                                                  isEditing: state.isEditing)
        self.avatarOverlayNode.update(peer: peer, 
                                      item: self.avatarListNode.item,
                                      updatingAvatar: state.updatingAvatar,
                                      uploadProgress: state.avatarUploadProgress,
                                      theme: presentationData.theme,
                                      avatarSize: avatarSize,
                                      isEditing: state.isEditing)
        
        if additive {
            transition.updateSublayerTransformScaleAdditive(node: self.avatarListNode.avatarContainerNode, scale: avatarScale)
            transition.updateSublayerTransformScaleAdditive(node: self.avatarOverlayNode, scale: avatarScale)
        } else {
            transition.updateSublayerTransformScale(node: self.avatarListNode.avatarContainerNode, scale: avatarScale)
            transition.updateSublayerTransformScale(node: self.avatarOverlayNode, scale: avatarScale)
        }
        
        let apparentAvatarFrame: CGRect
        let controlsClippingFrame: CGRect
        if self.isAvatarExpanded {
            let expandedAvatarCenter = CGPoint(x: expandedAvatarListSize.width / 2.0, y: expandedAvatarListSize.height / 2.0 - contentOffset / 2.0)
            apparentAvatarFrame = CGRect(origin: CGPoint(x: expandedAvatarCenter.x * (1.0 - transitionFraction) + transitionFraction * avatarCenter.x, y: expandedAvatarCenter.y * (1.0 - transitionFraction) + transitionFraction * avatarCenter.y), size: CGSize())
            if !transitionSourceAvatarFrame.width.isZero {
                let expandedFrame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: expandedAvatarListSize)
                controlsClippingFrame = CGRect(origin: CGPoint(x: transitionFraction * transitionSourceAvatarFrame.minX + (1.0 - transitionFraction) * expandedFrame.minX, y: transitionFraction * transitionSourceAvatarFrame.minY + (1.0 - transitionFraction) * expandedFrame.minY), size: CGSize(width: transitionFraction * transitionSourceAvatarFrame.width + (1.0 - transitionFraction) * expandedFrame.width, height: transitionFraction * transitionSourceAvatarFrame.height + (1.0 - transitionFraction) * expandedFrame.height))
            } else {
                controlsClippingFrame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: expandedAvatarListSize)
            }
        } else {
            apparentAvatarFrame = CGRect(origin: CGPoint(x: avatarCenter.x - avatarFrame.width / 2.0,
                                                         y: -contentOffset + avatarOffset + avatarCenter.y - avatarFrame.height / 2.0),
                                         size: avatarFrame.size)
            controlsClippingFrame = apparentAvatarFrame
        }
        
        transition.updateFrameAdditive(node: self.avatarListNode, frame: CGRect(origin: apparentAvatarFrame.center, size: CGSize()))
        transition.updateFrameAdditive(node: self.avatarOverlayNode, frame: CGRect(origin: apparentAvatarFrame.center, size: CGSize()))
        
        let avatarListContainerFrame: CGRect
        let avatarListContainerScale: CGFloat
        if self.isAvatarExpanded {
            if !transitionSourceAvatarFrame.width.isZero {
                let neutralAvatarListContainerSize = expandedAvatarListSize
                let avatarListContainerSize = CGSize(width: neutralAvatarListContainerSize.width * (1.0 - transitionFraction) + transitionSourceAvatarFrame.width * transitionFraction, height: neutralAvatarListContainerSize.height * (1.0 - transitionFraction) + transitionSourceAvatarFrame.height * transitionFraction)
                avatarListContainerFrame = CGRect(origin: CGPoint(x: -avatarListContainerSize.width / 2.0, y: -avatarListContainerSize.height / 2.0), size: avatarListContainerSize)
            } else {
                avatarListContainerFrame = CGRect(origin: CGPoint(x: -expandedAvatarListSize.width / 2.0, y: -expandedAvatarListSize.height / 2.0), size: expandedAvatarListSize)
            }
            avatarListContainerScale = 1.0 + max(0.0, -contentOffset / avatarListContainerFrame.height)
        } else {
            avatarListContainerFrame = CGRect(origin: CGPoint(x: -apparentAvatarFrame.width / 2.0, y: -apparentAvatarFrame.height / 2.0), size: apparentAvatarFrame.size)
            avatarListContainerScale = avatarScale
        }
        
        transition.updateFrame(node: self.avatarListNode.listContainerNode, frame: avatarListContainerFrame)
        let innerScale = avatarListContainerFrame.height / expandedAvatarListSize.height
        let innerDeltaX = (avatarListContainerFrame.width - expandedAvatarListSize.width) / 2.0
        let innerDeltaY = (avatarListContainerFrame.height - expandedAvatarListSize.height) / 2.0
        transition.updateSublayerTransformScale(node: self.avatarListNode.listContainerNode, scale: innerScale)
        transition.updateFrameAdditive(node: self.avatarListNode.listContainerNode.contentNode, frame: CGRect(origin: CGPoint(x: innerDeltaX + expandedAvatarListSize.width / 2.0, y: innerDeltaY + expandedAvatarListSize.height / 2.0), size: CGSize()))
        
        transition.updateFrameAdditive(node: self.avatarListNode.listContainerNode.controlsClippingOffsetNode, frame: CGRect(origin: controlsClippingFrame.center, size: CGSize()))
        transition.updateFrame(node: self.avatarListNode.listContainerNode.controlsClippingNode, frame: CGRect(origin: CGPoint(x: -controlsClippingFrame.width / 2.0, y: -controlsClippingFrame.height / 2.0), size: controlsClippingFrame.size))
        transition.updateFrameAdditive(node: self.avatarListNode.listContainerNode.controlsContainerNode, frame: CGRect(origin: CGPoint(x: -controlsClippingFrame.minX, y: -controlsClippingFrame.minY), size: CGSize(width: expandedAvatarListSize.width, height: expandedAvatarListSize.height)))
        
        transition.updateFrame(node: self.avatarListNode.listContainerNode.topShadowNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: expandedAvatarListSize.width, height: navigationHeight + 20.0)))
        transition.updateFrame(node: self.avatarListNode.listContainerNode.stripContainerNode, frame: CGRect(origin: CGPoint(x: 0.0, y: statusBarHeight < 25.0 ? (statusBarHeight + 2.0) : (statusBarHeight - 3.0)), size: CGSize(width: expandedAvatarListSize.width, height: 2.0)))
        transition.updateFrame(node: self.avatarListNode.listContainerNode.highlightContainerNode, frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: expandedAvatarListSize.width, height: expandedAvatarListSize.height)))
        transition.updateAlpha(node: self.avatarListNode.listContainerNode.controlsContainerNode, alpha: self.isAvatarExpanded ? (1.0 - transitionFraction) : 0.0)
        
        if additive {
            transition.updateSublayerTransformScaleAdditive(node: self.avatarListNode.listContainerTransformNode, scale: avatarListContainerScale)
        } else {
            transition.updateSublayerTransformScale(node: self.avatarListNode.listContainerTransformNode, scale: avatarListContainerScale)
        }
        
        self.avatarListNode.listContainerNode.update(size: expandedAvatarListSize, peer: peer, isExpanded: self.isAvatarExpanded, transition: transition)
        if self.avatarListNode.listContainerNode.isCollapsing && !self.ignoreCollapse {
            self.avatarListNode.avatarContainerNode.canAttachVideo = false
        }
        
        let panelWithAvatarHeight: CGFloat = 35.0 + avatarSize // + (peerState == .otherAccount ? 100 : 0)
        
        let rawHeight: CGFloat
        let height: CGFloat
        let maxY: CGFloat
        if self.isAvatarExpanded {
            rawHeight = expandedAvatarHeight
            height = max(navigationHeight, rawHeight - contentOffset)
            maxY = height
        } else {
            rawHeight = navigationHeight + panelWithAvatarHeight
            height = navigationHeight + max(0.0, panelWithAvatarHeight - contentOffset)
            maxY = navigationHeight + panelWithAvatarHeight - contentOffset
        }
        
        let apparentHeight = (1.0 - transitionFraction) * height + transitionFraction * transitionSourceHeight
        
        if !titleSize.width.isZero && !titleSize.height.isZero {
            if self.navigationTransition != nil {
                var neutralTitleScale: CGFloat = 1.0
                var neutralSubtitleScale: CGFloat = 1.0
                if self.isAvatarExpanded {
                    neutralTitleScale = 0.7
                    neutralSubtitleScale = 1.0
                }
                                
                let titleScale = (transitionFraction * transitionSourceTitleFrame.height + (1.0 - transitionFraction) * titleFrame.height * neutralTitleScale) / (titleFrame.height)
                let subtitleScale = max(0.01, min(10.0, (transitionFraction * transitionSourceSubtitleFrame.height + (1.0 - transitionFraction) * subtitleFrame.height * neutralSubtitleScale) / (subtitleFrame.height)))
                
                var titleFrame = titleFrame
                if !self.isAvatarExpanded {
                    titleFrame = titleFrame.offsetBy(dx: self.isAvatarExpanded ? 0.0 : titleHorizontalOffset * titleScale, dy: 0.0)
                }
                
                let titleCenter = CGPoint(x: transitionFraction * transitionSourceTitleFrame.midX + (1.0 - transitionFraction) * titleFrame.midX, y: transitionFraction * transitionSourceTitleFrame.midY + (1.0 - transitionFraction) * titleFrame.midY)
                let subtitleCenter = CGPoint(x: transitionFraction * transitionSourceSubtitleFrame.midX + (1.0 - transitionFraction) * subtitleFrame.midX, y: transitionFraction * transitionSourceSubtitleFrame.midY + (1.0 - transitionFraction) * subtitleFrame.midY)
                
                let rawTitleFrame = CGRect(origin: CGPoint(x: titleCenter.x - titleFrame.size.width * neutralTitleScale / 2.0, y: titleCenter.y - titleFrame.size.height * neutralTitleScale / 2.0), size: CGSize(width: titleFrame.size.width * neutralTitleScale, height: titleFrame.size.height * neutralTitleScale))
                
                self.titleNodeRawContainer.frame = rawTitleFrame
                
                transition.updateFrameAdditiveToCenter(node: self.titleNodeContainer, frame: CGRect(origin: rawTitleFrame.center, size: CGSize()))
                transition.updateFrame(node: self.titleNode, frame: CGRect(origin: CGPoint(), size: CGSize()))
                let rawSubtitleFrame = CGRect(origin: CGPoint(x: subtitleCenter.x - subtitleFrame.size.width / 2.0, y: subtitleCenter.y - subtitleFrame.size.height / 2.0), size: subtitleFrame.size)
                
                self.subtitleNodeRawContainer.frame = rawSubtitleFrame
                
                transition.updateFrameAdditiveToCenter(node: self.subtitleNodeContainer, frame: CGRect(origin: rawSubtitleFrame.center, size: CGSize()))
                transition.updateFrame(node: self.subtitleNode, frame: CGRect(origin: CGPoint(x: 0.0, y: subtitleOffset), size: CGSize()))
                transition.updateFrame(node: self.panelSubtitleNode, frame: CGRect(origin: CGPoint(x: 0.0, y: panelSubtitleOffset), size: CGSize()))
                transition.updateFrame(node: self.nextPanelSubtitleNode, frame: CGRect(origin: CGPoint(x: 0.0, y: panelSubtitleOffset), size: CGSize()))
                transition.updateFrame(node: self.usernameNode, frame: CGRect(origin: CGPoint(), size: CGSize()))
                transition.updateSublayerTransformScale(node: self.titleNodeContainer, scale: titleScale)
                transition.updateSublayerTransformScale(node: self.subtitleNodeContainer, scale: subtitleScale)
                transition.updateSublayerTransformScale(node: self.usernameNodeContainer, scale: subtitleScale)
            } else {
                let titleScale: CGFloat
                let subtitleScale: CGFloat
                var subtitleOffset: CGFloat = 0.0
                if self.isAvatarExpanded {
                    titleScale = 0.7
                    subtitleScale = 1.0
                } else {
                    titleScale = (1.0 - titleCollapseFraction) * 1.0 + titleCollapseFraction * titleMinScale
                    subtitleScale = (1.0 - titleCollapseFraction) * 1.0 + titleCollapseFraction * subtitleMinScale
                    subtitleOffset = titleCollapseFraction * -2.0
                }
                
                let rawTitleFrame = titleFrame.offsetBy(dx: self.isAvatarExpanded ? 0.0 : titleHorizontalOffset * titleScale, dy: 0.0)
                self.titleNodeRawContainer.frame = rawTitleFrame
                transition.updateFrame(node: self.titleNode, frame: CGRect(origin: CGPoint(), size: CGSize()))
                let rawSubtitleFrame = subtitleFrame
                self.subtitleNodeRawContainer.frame = rawSubtitleFrame
                let rawUsernameFrame = usernameFrame
                self.usernameNodeRawContainer.frame = rawUsernameFrame
                if self.isAvatarExpanded {
                    transition.updateFrameAdditive(node: self.titleNodeContainer, frame: CGRect(origin: rawTitleFrame.center, size: CGSize()).offsetBy(dx: 0.0, dy: titleOffset + apparentTitleLockOffset))
                    transition.updateFrameAdditive(node: self.subtitleNodeContainer, frame: CGRect(origin: rawSubtitleFrame.center, size: CGSize()).offsetBy(dx: 0.0, dy: titleOffset))
                    transition.updateFrameAdditive(node: self.usernameNodeContainer, frame: CGRect(origin: rawUsernameFrame.center, size: CGSize()).offsetBy(dx: 0.0, dy: titleOffset))
                } else {
                    transition.updateFrameAdditiveToCenter(node: self.titleNodeContainer, frame: CGRect(origin: rawTitleFrame.center, size: CGSize()).offsetBy(dx: 0.0, dy: titleOffset + apparentTitleLockOffset))
                    
                    var subtitleCenter = rawSubtitleFrame.center
                    subtitleCenter.x = rawTitleFrame.center.x + (subtitleCenter.x - rawTitleFrame.center.x) * subtitleScale
                    subtitleCenter.y += subtitleOffset
                    transition.updateFrameAdditiveToCenter(node: self.subtitleNodeContainer, frame: CGRect(origin: subtitleCenter, size: CGSize()).offsetBy(dx: 0.0, dy: titleOffset))
                    
                    var usernameCenter = rawUsernameFrame.center
                    usernameCenter.x = rawTitleFrame.center.x + (usernameCenter.x - rawTitleFrame.center.x) * subtitleScale
                    transition.updateFrameAdditiveToCenter(node: self.usernameNodeContainer, frame: CGRect(origin: usernameCenter, size: CGSize()).offsetBy(dx: 0.0, dy: titleOffset))
                }
                transition.updateFrame(node: self.subtitleNode, frame: CGRect(origin: CGPoint(x: 0.0, y: subtitleOffset), size: CGSize()))
                transition.updateFrame(node: self.panelSubtitleNode, frame: CGRect(origin: CGPoint(x: 0.0, y: panelSubtitleOffset), size: CGSize()))
                transition.updateFrame(node: self.nextPanelSubtitleNode, frame: CGRect(origin: CGPoint(x: 0.0, y: panelSubtitleOffset), size: CGSize()))
                transition.updateFrame(node: self.usernameNode, frame: CGRect(origin: CGPoint(), size: CGSize()))
                transition.updateSublayerTransformScaleAdditive(node: self.titleNodeContainer, scale: titleScale)
                transition.updateSublayerTransformScaleAdditive(node: self.subtitleNodeContainer, scale: subtitleScale)
                transition.updateSublayerTransformScaleAdditive(node: self.usernameNodeContainer, scale: subtitleScale)
            }
        }
        
        if peerState != .otherAccount {
            avatarActionsButtonNode.alpha = 0
        } else {
            avatarActionsButtonNode.alpha = 1
        }
        
        let buttonSpacing: CGFloat = 8.0
        let buttonSideInset = max(16.0, containerInset)
        var buttonRightOrigin = CGPoint(x: width - buttonSideInset, y: maxY + 25.0 - navigationHeight - UIScreenPixel)
        let buttonWidth = (width - buttonSideInset * 2.0 + buttonSpacing) / CGFloat(buttonKeys.count) - buttonSpacing
        
        let apparentButtonSize = CGSize(width: buttonWidth, height: 58.0)
        let buttonsAlpha: CGFloat = 1.0
        let buttonsVerticalOffset: CGFloat = 0.0
        
        let buttonsAlphaTransition = transition
        
        for buttonKey in buttonKeys.reversed() {
            let buttonNode: PeerInfoHeaderButtonNode
            var wasAdded = false
            if let current = self.buttonNodes[buttonKey] {
                buttonNode = current
            } else {
                wasAdded = true
                buttonNode = PeerInfoHeaderButtonNode(key: buttonKey, action: { [weak self] buttonNode, gesture in
                    self?.buttonPressed(buttonNode, gesture: gesture)
                })
                self.buttonNodes[buttonKey] = buttonNode
                self.buttonsContainerNode.addSubnode(buttonNode)
            }

            let buttonFrame = CGRect(origin: CGPoint(x: buttonRightOrigin.x - apparentButtonSize.width, y: buttonRightOrigin.y), size: apparentButtonSize)
            let buttonTransition: ContainedViewLayoutTransition = wasAdded ? .immediate : transition

            let apparentButtonFrame = buttonFrame.offsetBy(dx: 0.0, dy: buttonsVerticalOffset)
            if additive {
                buttonTransition.updateFrameAdditiveToCenter(node: buttonNode, frame: apparentButtonFrame)
            } else {
                buttonTransition.updateFrame(node: buttonNode, frame: apparentButtonFrame)
            }
            
            let buttonText: String
            let buttonIcon: PeerInfoHeaderButtonIcon
            switch buttonKey {
            case .message:
                buttonText = presentationData.strings.PeerInfo_ButtonMessage
                buttonIcon = .message
            case .discussion:
                buttonText = presentationData.strings.PeerInfo_ButtonDiscuss
                buttonIcon = .message
            case .call:
                buttonText = presentationData.strings.PeerInfo_ButtonCall
                buttonIcon = .call
            case .videoCall:
                buttonText = presentationData.strings.PeerInfo_ButtonVideoCall
                buttonIcon = .videoCall
            case .voiceChat:
                if let channel = peer as? ElloAppChannel, case .broadcast = channel.info {
                    buttonText = presentationData.strings.PeerInfo_ButtonLiveStream
                } else {
                    buttonText = presentationData.strings.PeerInfo_ButtonVoiceChat
                }
                buttonIcon = .voiceChat
            case .mute:
                if let notificationSettings = notificationSettings, case .muted = notificationSettings.muteState {
                    buttonText = presentationData.strings.PeerInfo_ButtonUnmute
                    buttonIcon = .unmute
                } else {
                    buttonText = presentationData.strings.PeerInfo_ButtonMute
                    buttonIcon = .mute
                }
            case .more:
                buttonText = presentationData.strings.PeerInfo_ButtonMore
                buttonIcon = .more
            case .addMember:
                buttonText = presentationData.strings.PeerInfo_ButtonAddMember
                buttonIcon = .addMember
            case .search:
                buttonText = presentationData.strings.PeerInfo_ButtonSearch
                buttonIcon = .search
            case .leave:
                buttonText = presentationData.strings.PeerInfo_ButtonLeave
                buttonIcon = .leave
            case .stop:
                buttonText = presentationData.strings.PeerInfo_ButtonStop
                buttonIcon = .stop
            }

            var isActive = true
            if let highlightedButton = state.highlightedButton {
                isActive = buttonKey == highlightedButton
            }

            buttonNode.update(size: buttonFrame.size, text: buttonText, icon: buttonIcon, isActive: isActive, isExpanded: false, presentationData: presentationData, transition: buttonTransition)

            if wasAdded {
                buttonNode.alpha = 0.0
            }
            buttonsAlphaTransition.updateAlpha(node: buttonNode, alpha: buttonsAlpha)

            if case .mute = buttonKey, buttonNode.containerNode.alpha.isZero, additive {
                if case let .animated(duration, curve) = transition {
                    ContainedViewLayoutTransition.animated(duration: duration * 0.3, curve: curve).updateAlpha(node: buttonNode.containerNode, alpha: 1.0)
                } else {
                    transition.updateAlpha(node: buttonNode.containerNode, alpha: 1.0)
                }
            } else {
                transition.updateAlpha(node: buttonNode.containerNode, alpha: 1.0)
            }
            buttonRightOrigin.x -= apparentButtonSize.width + buttonSpacing
            
            buttonNode.isEnabled = true
            buttonNode.isUserInteractionEnabled = true
            buttonNode.supernode?.isUserInteractionEnabled = true
            buttonNode.supernode?.supernode?.isUserInteractionEnabled = true
        }

        for key in self.buttonNodes.keys {
            if !buttonKeys.contains(key) {
                if let buttonNode = self.buttonNodes[key] {
                    self.buttonNodes.removeValue(forKey: key)
                    transition.updateAlpha(node: buttonNode, alpha: 0.0) { [weak buttonNode] _ in
                        buttonNode?.removeFromSupernode()
                    }
                }
            }
        }
        
        let resolvedRegularHeight: CGFloat
        if self.isAvatarExpanded {
            resolvedRegularHeight = expandedAvatarListSize.height
        } else {
            resolvedRegularHeight = panelWithAvatarHeight + navigationHeight
        }
        
        let backgroundFrame: CGRect
        let separatorFrame: CGRect
        
        var resolvedHeight: CGFloat
        
        if state.isEditing {
            resolvedHeight = editingContentHeight
            backgroundFrame = CGRect(origin: CGPoint(x: 0.0, y: -2000.0 + max(navigationHeight, resolvedHeight - contentOffset)), size: CGSize(width: width, height: 2000.0))
            separatorFrame = CGRect(origin: CGPoint(x: 0.0, y: max(navigationHeight, resolvedHeight - contentOffset)), size: CGSize(width: width, height: UIScreenPixel))
        } else {
            resolvedHeight = resolvedRegularHeight
            backgroundFrame = CGRect(origin: CGPoint(x: 0.0, y: -2000.0 + apparentHeight), size: CGSize(width: width, height: 2000.0))
            separatorFrame = CGRect(origin: CGPoint(x: 0.0, y: apparentHeight), size: CGSize(width: width, height: UIScreenPixel))
        }
        
        transition.updateFrame(node: self.regularContentNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: width, height: resolvedHeight)))
//        transition.updateFrame(node: self.buttonsContainer ht: resolvedHeight - navigationHeight + 180.0)))
        transition.updateFrame(node: self.buttonsContainerNode, frame: CGRect(origin: CGPoint(x: 0.0, y: navigationHeight + UIScreenPixel), size: CGSize(width: width, height: resolvedHeight - navigationHeight + 180.0)))
        if additive {
            transition.updateFrameAdditive(node: self.backgroundNode, frame: backgroundFrame)
            self.backgroundNode.update(size: self.backgroundNode.bounds.size, transition: transition)
            transition.updateFrameAdditive(node: self.expandedBackgroundNode, frame: backgroundFrame)
            self.expandedBackgroundNode.update(size: self.expandedBackgroundNode.bounds.size, transition: transition)
            transition.updateFrameAdditive(node: self.separatorNode, frame: separatorFrame)
        } else {
            transition.updateFrame(node: self.backgroundNode, frame: backgroundFrame)
            self.backgroundNode.update(size: self.backgroundNode.bounds.size, transition: transition)
            transition.updateFrame(node: self.expandedBackgroundNode, frame: backgroundFrame)
            self.expandedBackgroundNode.update(size: self.expandedBackgroundNode.bounds.size, transition: transition)
            transition.updateFrame(node: self.separatorNode, frame: separatorFrame)
        }
        
        if self.isAvatarExpanded {
//            self.cornerRadius = 18
            self.avatarListNode.cornerRadius = 18
            self.avatarListNode.cornerRoundingType = .clipping

            self.avatarOverlayNode.cornerRoundingType = .clipping
            self.avatarOverlayNode.cornerRadius = 18
        }

        return resolvedHeight
    }
    
    private func buttonPressed(_ buttonNode: PeerInfoHeaderButtonNode, gesture: ContextGesture?) {
        self.performButtonAction?(buttonNode.key, gesture)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event) else {
            return nil
        }
        if !self.backgroundNode.frame.contains(point) {
            return nil
        }
        
        if !(self.state?.isEditing ?? false) {
            switch self.currentCredibilityIcon {
            case .premium, .emojiStatus:
                let iconFrame = self.titleCredibilityIconView.convert(self.titleCredibilityIconView.bounds, to: self.view)
                let expandedIconFrame = self.titleExpandedCredibilityIconView.convert(self.titleExpandedCredibilityIconView.bounds, to: self.view)
                if expandedIconFrame.contains(point) && self.isAvatarExpanded {
                    return self.titleExpandedCredibilityIconView.hitTest(self.view.convert(point, to: self.titleExpandedCredibilityIconView), with: event)
                } else if iconFrame.contains(point) {
                    return self.titleCredibilityIconView.hitTest(self.view.convert(point, to: self.titleCredibilityIconView), with: event)
                }
            default:
                break
            }
        }
        
        if result.isDescendant(of: self.navigationButtonContainer.view) {
            return result
        }
        
        if result == self.view || result == self.regularContentNode.view || result == self.editingContentNode.view {
            return nil
        }
        return result
    }
    
    func updateIsAvatarExpanded(_ isAvatarExpanded: Bool, transition: ContainedViewLayoutTransition) {
        if self.isAvatarExpanded != isAvatarExpanded {
            self.isAvatarExpanded = isAvatarExpanded
            if isAvatarExpanded {
                self.avatarListNode.listContainerNode.selectFirstItem()
            }
            if case .animated = transition, !isAvatarExpanded {
                self.avatarListNode.animateAvatarCollapse(transition: transition)
            }
        }
    }
}
