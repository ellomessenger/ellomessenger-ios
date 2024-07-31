//
//  PeerInfoEditingAvatar.swift
//  _idx_ElloAppUI_415295EC_ios_min11.0
//
//

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

// MARK: - PeerInfoEditingAvatarOverlayNode

final class PeerInfoEditingAvatarOverlayNode: ASDisplayNode {
    private let context: AccountContext
    
    private let imageNode: ImageNode
    private let updatingAvatarOverlay: ASImageNode
    private let iconNode: ASImageNode
    private var statusNode: RadialStatusNode
    
    private var currentRepresentation: ElloAppMediaImageRepresentation?
    
    init(context: AccountContext) {
        self.context = context
        
        self.imageNode = ImageNode(enableEmpty: true)
        
        self.updatingAvatarOverlay = ASImageNode()
        self.updatingAvatarOverlay.displayWithoutProcessing = true
        self.updatingAvatarOverlay.displaysAsynchronously = false
        self.updatingAvatarOverlay.alpha = 0.0
        
        self.statusNode = RadialStatusNode(backgroundNodeColor: UIColor(rgb: 0x000000, alpha: 0.6))
        self.statusNode.isUserInteractionEnabled = false
        
        self.iconNode = ASImageNode()
        self.iconNode.image = generateTintedImage(image: UIImage(bundleImageName: "Avatar/EditAvatarIconLarge"), color: .white)
        self.iconNode.alpha = 0.0
        
        super.init()
        
        self.imageNode.frame = CGRect(origin: CGPoint(x: -50.0, y: -50.0), size: CGSize(width: 100.0, height: 100.0))
        self.updatingAvatarOverlay.frame = self.imageNode.frame
        
        let radialStatusSize: CGFloat = 50.0
        let imagePosition = self.imageNode.position
        self.statusNode.frame = CGRect(origin: CGPoint(x: floor(imagePosition.x - radialStatusSize / 2.0), y: floor(imagePosition.y - radialStatusSize / 2.0)), size: CGSize(width: radialStatusSize, height: radialStatusSize))
        
        if let image = self.iconNode.image {
            self.iconNode.frame = CGRect(origin: CGPoint(x: floor(imagePosition.x - image.size.width / 2.0), y: floor(imagePosition.y - image.size.height / 2.0)), size: image.size)
        }
        
        self.addSubnode(self.imageNode)
        self.addSubnode(self.updatingAvatarOverlay)
        self.addSubnode(self.statusNode)
    }
    
    func updateTransitionFraction(_ fraction: CGFloat, transition: ContainedViewLayoutTransition) {
        transition.updateAlpha(node: self, alpha: 1.0 - fraction)
    }
    
    func update(peer: Peer?, item: PeerInfoAvatarListItem?, updatingAvatar: PeerInfoUpdatingAvatar?, uploadProgress: CGFloat?, theme: PresentationTheme, avatarSize: CGFloat, isEditing: Bool) {
        guard let peer = peer else {
            return
        }
        
        self.imageNode.frame = CGRect(origin: CGPoint(x: -avatarSize / 2.0, y: -avatarSize / 2.0), size: CGSize(width: avatarSize, height: avatarSize))
        self.updatingAvatarOverlay.frame = self.imageNode.frame
        
        let transition = ContainedViewLayoutTransition.animated(duration: 0.2, curve: .linear)
        
        if canEditPeerInfo(context: self.context, peer: peer) {
            var overlayHidden = true
            if let updatingAvatar = updatingAvatar {
                overlayHidden = false
                
                self.statusNode.transitionToState(.progress(color: .white, lineWidth: nil, value: max(0.027, uploadProgress ?? 0.0), cancelEnabled: true, animateRotation: true))
                
                if case let .image(representation) = updatingAvatar {
                    if representation != self.currentRepresentation {
                        self.currentRepresentation = representation
                        if let signal = peerAvatarImage(account: context.account, peerReference: nil, authorOfMessage: nil, representation: representation, displayDimensions: CGSize(width: avatarSize, height: avatarSize), emptyColor: nil, synchronousLoad: false, provideUnrounded: false) {
                            self.imageNode.setSignal(signal |> map { $0?.0 })
                        }
                    }
                }
                
                transition.updateAlpha(node: self.updatingAvatarOverlay, alpha: 1.0)
            } else {
                let targetOverlayAlpha: CGFloat = 0.0
                if self.updatingAvatarOverlay.alpha != targetOverlayAlpha {
                    let update = {
                        self.statusNode.transitionToState(.none)
                        self.currentRepresentation = nil
                        self.imageNode.setSignal(.single(nil))
                        transition.updateAlpha(node: self.updatingAvatarOverlay, alpha: overlayHidden ? 0.0 : 1.0)
                    }
                    Queue.mainQueue().after(0.3) {
                        update()
                    }
                }
            }
            if !overlayHidden && self.updatingAvatarOverlay.image == nil {
                self.updatingAvatarOverlay.image = generateFilledCircleImage(diameter: avatarSize, color: UIColor(white: 0.0, alpha: 0.4), backgroundColor: nil)
            }
        } else {
            self.statusNode.transitionToState(.none)
            self.currentRepresentation = nil
            transition.updateAlpha(node: self.iconNode, alpha: 0.0)
            transition.updateAlpha(node: self.updatingAvatarOverlay, alpha: 0.0)
        }
    }
}

// MARK: - PeerInfoEditingAvatarNode

final class PeerInfoEditingAvatarNode: ASDisplayNode {
    private let context: AccountContext
    let avatarNode: AvatarNode
    fileprivate var videoNode: UniversalVideoNode?
    private var videoContent: NativeVideoContent?
    private var videoStartTimestamp: Double?
    var item: PeerInfoAvatarListItem?
    
    var tapped: ((Bool) -> Void)?
    
    var canAttachVideo: Bool = true
    
    init(context: AccountContext) {
        self.context = context
        let avatarFont = avatarPlaceholderFont(size: floor(100.0 * 16.0 / 37.0))
        self.avatarNode = AvatarNode(font: avatarFont)
        
        super.init()
        
        self.addSubnode(self.avatarNode)
        self.avatarNode.frame = CGRect(origin: CGPoint(x: -50.0, y: -50.0), size: CGSize(width: 100.0, height: 100.0))
        
        self.avatarNode.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:))))
    }
    
    @objc private func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            self.tapped?(false)
        }
    }
    
    func reset() {
        guard let videoNode = self.videoNode else {
            return
        }
        videoNode.isHidden = true
        videoNode.seek(self.videoStartTimestamp ?? 0.0)
        Queue.mainQueue().after(0.15) {
            videoNode.isHidden = false
        }
    }
    
    var removedPhotoResourceIds = Set<String>()
    func update(peer: Peer?, item: PeerInfoAvatarListItem?, updatingAvatar: PeerInfoUpdatingAvatar?, uploadProgress: CGFloat?, theme: PresentationTheme, avatarSize: CGFloat, isEditing: Bool) {
        guard let peer = peer else {
            return
        }
        
        let canEdit = canEditPeerInfo(context: self.context, peer: peer)
        
        let previousItem = self.item
        var item = item
        self.item = item
        
        let overrideImage: AvatarNodeImageOverride?
        if canEdit, peer.profileImageRepresentations.isEmpty {
            overrideImage = .editAvatarIcon(forceNone: true)
        } else if let previousItem = previousItem, item == nil {
            if case let .image(_, representations, _, _) = previousItem, let rep = representations.last {
                self.removedPhotoResourceIds.insert(rep.representation.resource.id.stringRepresentation)
            }
            overrideImage = canEdit ? .editAvatarIcon(forceNone: true) : AvatarNodeImageOverride.none
            item = nil
        } else if let representation = peer.profileImageRepresentations.last, self.removedPhotoResourceIds.contains(representation.resource.id.stringRepresentation) {
            overrideImage = canEdit ? .editAvatarIcon(forceNone: true) : AvatarNodeImageOverride.none
            item = nil
        } else {
            overrideImage = item == nil && canEdit ? .editAvatarIcon(forceNone: true) : nil
        }
        self.avatarNode.font = avatarPlaceholderFont(size: floor(avatarSize * 16.0 / 37.0))
        self.avatarNode.setPeer(context: self.context, 
                                theme: theme,
                                peer: EnginePeer(peer),
                                overrideImage: overrideImage,
                                synchronousLoad: false,
                                displayDimensions: CGSize(width: avatarSize, height: avatarSize))
        self.avatarNode.frame = CGRect(origin: CGPoint(x: -avatarSize / 2.0, y: -avatarSize / 2.0), size: CGSize(width: avatarSize, height: avatarSize))
        
        if let item = item {
            let representations: [ImageRepresentationWithReference]
            let videoRepresentations: [VideoRepresentationWithReference]
            let immediateThumbnailData: Data?
            var id: Int64
            switch item {
                case .custom:
                    representations = []
                    videoRepresentations = []
                    immediateThumbnailData = nil
                    id = 0
                case let .topImage(topRepresentations, videoRepresentationsValue, immediateThumbnail):
                    representations = topRepresentations
                    videoRepresentations = videoRepresentationsValue
                    immediateThumbnailData = immediateThumbnail
                    id = peer.id.id._internalGetInt64Value()
                    if let resource = videoRepresentations.first?.representation.resource as? CloudPhotoSizeMediaResource {
                        id = id &+ resource.photoId
                    }
                case let .image(reference, imageRepresentations, videoRepresentationsValue, immediateThumbnail):
                    representations = imageRepresentations
                    videoRepresentations = videoRepresentationsValue
                    immediateThumbnailData = immediateThumbnail
                    if case let .cloud(imageId, _, _) = reference {
                        id = imageId
                    } else {
                        id = peer.id.id._internalGetInt64Value()
                    }
            }
            
            if let video = videoRepresentations.last, let peerReference = PeerReference(peer) {
                let videoFileReference = FileMediaReference.avatarList(peer: peerReference, media: ElloAppMediaFile(fileId: MediaId(namespace: Namespaces.Media.LocalFile, id: 0), partialReference: nil, resource: video.representation.resource, previewRepresentations: representations.map { $0.representation }, videoThumbnails: [], immediateThumbnailData: immediateThumbnailData, mimeType: "video/mp4", size: nil, attributes: [.Animated, .Video(duration: 0, size: video.representation.dimensions, flags: [])]))
                let videoContent = NativeVideoContent(id: .profileVideo(id, nil), fileReference: videoFileReference, streamVideo: isMediaStreamable(resource: video.representation.resource) ? .conservative : .none, loopVideo: true, enableSound: false, fetchAutomatically: true, onlyFullSizeThumbnail: false, useLargeThumbnail: true, autoFetchFullSizeThumbnail: true, startTimestamp: video.representation.startTimestamp, continuePlayingWithoutSoundOnLostAudioSession: false, placeholderColor: .clear, captureProtected: peer.isCopyProtectionEnabled)
                if videoContent.id != self.videoContent?.id {
                    self.videoNode?.removeFromSupernode()
                    
                    let mediaManager = self.context.sharedContext.mediaManager
                    let videoNode = UniversalVideoNode(postbox: self.context.account.postbox, audioSession: mediaManager.audioSession, manager: mediaManager.universalVideoManager, decoration: GalleryVideoDecoration(), content: videoContent, priority: .gallery)
                    videoNode.isUserInteractionEnabled = false
                    self.videoStartTimestamp = video.representation.startTimestamp
                    self.videoContent = videoContent
                    self.videoNode = videoNode
                    
                    let maskPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(), size: self.avatarNode.frame.size))
                    let shape = CAShapeLayer()
                    shape.path = maskPath.cgPath
                    videoNode.layer.mask = shape
                    
                    self.insertSubnode(videoNode, aboveSubnode: self.avatarNode)
                }
            } else if let videoNode = self.videoNode {
                self.videoStartTimestamp = nil
                self.videoContent = nil
                self.videoNode = nil
                
                videoNode.removeFromSupernode()
            }
        } else if let videoNode = self.videoNode {
            self.videoStartTimestamp = nil
            self.videoContent = nil
            self.videoNode = nil
            
            videoNode.removeFromSupernode()
        }
        
        if let videoNode = self.videoNode {
            if self.canAttachVideo {
                videoNode.updateLayout(size: self.avatarNode.frame.size, transition: .immediate)
            }
            videoNode.frame = self.avatarNode.frame
            
            if isEditing != videoNode.canAttachContent {
                videoNode.canAttachContent = isEditing && self.canAttachVideo
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.avatarNode.frame.contains(point) {
            return self.avatarNode.view
        }
        return super.hitTest(point, with: event)
    }
}

// MARK: - PeerInfoAvatarListNode

final class PeerInfoAvatarListNode: ASDisplayNode {
    private let isSettings: Bool
    let pinchSourceNode: PinchSourceContainerNode
    let avatarContainerNode: PeerInfoAvatarTransformContainerNode
    let listContainerTransformNode: ASDisplayNode
    let listContainerNode: PeerInfoAvatarListContainerNode
    
    let isReady = Promise<Bool>()
    
    var arguments: (Peer?, PresentationTheme, CGFloat, Bool)?
    var item: PeerInfoAvatarListItem?
    
    var itemsUpdated: (([PeerInfoAvatarListItem]) -> Void)?
    var animateOverlaysFadeIn: (() -> Void)?
    
    init(context: AccountContext, readyWhenGalleryLoads: Bool, isSettings: Bool) {
        self.isSettings = isSettings
        
        self.pinchSourceNode = PinchSourceContainerNode()
        
        self.avatarContainerNode = PeerInfoAvatarTransformContainerNode(context: context)
        self.listContainerTransformNode = ASDisplayNode()
        self.listContainerNode = PeerInfoAvatarListContainerNode(context: context)
        self.listContainerNode.clipsToBounds = true
        self.listContainerNode.isHidden = true
        
        super.init()
        
        self.addSubnode(self.pinchSourceNode)
        self.pinchSourceNode.contentNode.addSubnode(self.avatarContainerNode)
        self.listContainerTransformNode.addSubnode(self.listContainerNode)
        self.pinchSourceNode.contentNode.addSubnode(self.listContainerTransformNode)
        
        let avatarReady = (self.avatarContainerNode.avatarNode.ready
                           |> mapToSignal { _ -> Signal<Bool, NoError> in
            return .complete()
        }
                           |> then(.single(true)))
        
        let galleryReady = self.listContainerNode.isReady.get()
        |> filter { value in
            return value
        }
        |> take(1)
        
        let combinedSignal: Signal<Bool, NoError>
        if readyWhenGalleryLoads {
            combinedSignal = combineLatest(queue: .mainQueue(),
                                           avatarReady,
                                           galleryReady
            )
            |> map { lhs, rhs in
                return lhs && rhs
            }
        } else {
            combinedSignal = avatarReady
        }
        
        self.isReady.set(combinedSignal
                         |> filter { value in
            return value
        }
                         |> take(1))
        
        self.listContainerNode.itemsUpdated = { [weak self] items in
            if let strongSelf = self {
                strongSelf.item = items.first
                strongSelf.itemsUpdated?(items)
                if let (peer, theme, avatarSize, isExpanded) = strongSelf.arguments {
                    strongSelf.avatarContainerNode.update(peer: peer, item: strongSelf.item, theme: theme, avatarSize: avatarSize, isExpanded: isExpanded, isSettings: strongSelf.isSettings)
                }
            }
        }
        
        self.pinchSourceNode.activate = { [weak self] sourceNode in
            guard let strongSelf = self, let (_, _, _, isExpanded) = strongSelf.arguments, isExpanded else {
                return
            }
            let pinchController = PinchController(sourceNode: sourceNode, getContentAreaInScreenSpace: {
                return UIScreen.main.bounds
            })
            context.sharedContext.mainWindow?.presentInGlobalOverlay(pinchController)
            
            strongSelf.listContainerNode.bottomShadowNode.alpha = 0.0
        }
        
        self.pinchSourceNode.animatedOut = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.animateOverlaysFadeIn?()
        }
    }
    
    func update(size: CGSize, avatarSize: CGFloat, isExpanded: Bool, peer: Peer?, theme: PresentationTheme, transition: ContainedViewLayoutTransition) {
        self.arguments = (peer, theme, avatarSize, isExpanded)
        self.pinchSourceNode.update(size: size, transition: transition)
        self.pinchSourceNode.frame = CGRect(origin: CGPoint(), size: size)
        self.avatarContainerNode.update(peer: peer, item: self.item, theme: theme, avatarSize: avatarSize, isExpanded: isExpanded, isSettings: self.isSettings)
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.listContainerNode.isHidden {
            if let result = self.listContainerNode.view.hitTest(self.view.convert(point, to: self.listContainerNode.view), with: event) {
                return result
            }
        } else {
            if let result = self.avatarContainerNode.avatarNode.view.hitTest(self.view.convert(point, to: self.avatarContainerNode.avatarNode.view), with: event) {
                return result
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    func animateAvatarCollapse(transition: ContainedViewLayoutTransition) {
        if let currentItemNode = self.listContainerNode.currentItemNode, case .animated = transition {
            if let _ = self.avatarContainerNode.videoNode {
                
            } else if let unroundedImage = self.avatarContainerNode.avatarNode.unroundedImage {
                let avatarCopyView = UIImageView()
                avatarCopyView.image = unroundedImage
                avatarCopyView.frame = self.avatarContainerNode.avatarNode.frame
                avatarCopyView.center = currentItemNode.imageNode.position
                avatarCopyView.roundCorners([.bottomLeft, .bottomRight], radius: 18)
                currentItemNode.view.addSubview(avatarCopyView)
                let scale = currentItemNode.imageNode.bounds.height / avatarCopyView.bounds.height
                avatarCopyView.layer.transform = CATransform3DMakeScale(scale, scale, scale)
                avatarCopyView.alpha = 0.0
                transition.updateAlpha(layer: avatarCopyView.layer, alpha: 1.0, completion: { [weak avatarCopyView] _ in
                    Queue.mainQueue().after(0.1, {
                        avatarCopyView?.removeFromSuperview()
                    })
                })
                
            }
        }
    }
}
