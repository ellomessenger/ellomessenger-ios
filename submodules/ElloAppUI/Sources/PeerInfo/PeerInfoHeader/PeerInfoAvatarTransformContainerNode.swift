//
//  PeerInfoAvatarTransformContainerNode.swift
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

// MARK: - PeerInfoAvatarTransformContainerNode

final class PeerInfoAvatarTransformContainerNode: ASDisplayNode {
    let context: AccountContext
    
    private let containerNode: ContextControllerSourceNode
    
    let avatarNode: AvatarNode
    var videoNode: UniversalVideoNode?
    private var videoContent: NativeVideoContent?
    private var videoStartTimestamp: Double?
    
    var isExpanded: Bool = false
    var canAttachVideo: Bool = true {
        didSet {
            if oldValue != self.canAttachVideo {
                self.videoNode?.canAttachContent = !self.isExpanded && self.canAttachVideo
            }
        }
    }
    
    var tapped: (() -> Void)?
    var contextAction: ((ASDisplayNode, ContextGesture?) -> Void)?
    
    private var isFirstAvatarLoading = true
    var item: PeerInfoAvatarListItem?
    
    private let playbackStartDisposable = MetaDisposable()
    
    init(context: AccountContext) {
        self.context = context
        self.containerNode = ContextControllerSourceNode()
        
        let avatarFont = avatarPlaceholderFont(size: floor(100.0 * 16.0 / 37.0))
        self.avatarNode = AvatarNode(font: avatarFont)
        
        super.init()
        
        self.addSubnode(self.containerNode)
        self.containerNode.addSubnode(self.avatarNode)
        self.containerNode.frame = CGRect(origin: CGPoint(x: -50.0, y: -50.0), size: CGSize(width: 100.0, height: 100.0))
        self.avatarNode.frame = self.containerNode.bounds
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        self.avatarNode.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.containerNode.activated = { [weak self] gesture, _ in
            guard let strongSelf = self else {
                return
            }
            tapGestureRecognizer.isEnabled = false
            tapGestureRecognizer.isEnabled = true
            strongSelf.contextAction?(strongSelf.containerNode, gesture)
        }
    }
    
    deinit {
        self.playbackStartDisposable.dispose()
    }
    
    @objc private func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            self.tapped?()
        }
    }
    
    func updateTransitionFraction(_ fraction: CGFloat, transition: ContainedViewLayoutTransition) {
        if let videoNode = self.videoNode {
            if case .immediate = transition, fraction == 1.0 {
                return
            }
            if fraction > 0.0 {
                self.videoNode?.pause()
            } else {
                self.videoNode?.play()
            }
            transition.updateAlpha(node: videoNode, alpha: 1.0 - fraction)
        }
    }
    
    var removedPhotoResourceIds = Set<String>()
    func update(peer: Peer?, item: PeerInfoAvatarListItem?, theme: PresentationTheme, avatarSize: CGFloat, isExpanded: Bool, isSettings: Bool) {
        if let peer = peer {
            let previousItem = self.item
            var item = item
            self.item = item
            
            //            let maskPath = UIBezierPath()
            //            maskPath.append(UIBezierPath(roundedRect: self.containerNode.bounds, cornerRadius: 18.0))
            //            maskPath.append(UIBezierPath(rect: self.containerNode.bounds))
            //            self.containerNode.layer.path = maskPath.cgPath
            
            
            var overrideImage: AvatarNodeImageOverride?
            if peer.isDeleted {
                overrideImage = .deletedIcon
            } else if let previousItem = previousItem, item == nil {
                if case let .image(_, representations, _, _) = previousItem, let rep = representations.last {
                    self.removedPhotoResourceIds.insert(rep.representation.resource.id.stringRepresentation)
                }
                overrideImage = AvatarNodeImageOverride.none
                item = nil
            } else if let rep = peer.profileImageRepresentations.last, self.removedPhotoResourceIds.contains(rep.resource.id.stringRepresentation) {
                overrideImage = AvatarNodeImageOverride.none
                item = nil
            }
            
            if let _ = overrideImage {
                self.containerNode.isGestureEnabled = false
            } else if peer.profileImageRepresentations.isEmpty {
                self.containerNode.isGestureEnabled = false
            } else {
                self.containerNode.isGestureEnabled = false
            }
            
            self.avatarNode.setPeer(context: self.context,
                                    theme: theme,
                                    peer: EnginePeer(peer),
                                    overrideImage: overrideImage,
                                    clipStyle: AvatarNodeClipStyle.defaultCorner,
                                    synchronousLoad: self.isFirstAvatarLoading,
                                    displayDimensions: CGSize(width: avatarSize, height: avatarSize),
                                    storeUnrounded: true)
            self.isFirstAvatarLoading = false
            
            self.containerNode.frame = CGRect(origin: CGPoint(x: -avatarSize / 2.0, y: -avatarSize / 2.0), size: CGSize(width: avatarSize, height: avatarSize))
            self.avatarNode.frame = self.containerNode.bounds
            self.avatarNode.font = avatarPlaceholderFont(size: floor(avatarSize * 16.0 / 37.0))
            
            if let item = item {
                let representations: [ImageRepresentationWithReference]
                let videoRepresentations: [VideoRepresentationWithReference]
                let immediateThumbnailData: Data?
                var videoId: Int64
                switch item {
                    case .custom:
                        representations = []
                        videoRepresentations = []
                        immediateThumbnailData = nil
                        videoId = 0
                    case let .topImage(topRepresentations, videoRepresentationsValue, immediateThumbnail):
                        representations = topRepresentations
                        videoRepresentations = videoRepresentationsValue
                        immediateThumbnailData = immediateThumbnail
                        videoId = peer.id.id._internalGetInt64Value()
                        if let resource = videoRepresentations.first?.representation.resource as? CloudPhotoSizeMediaResource {
                            videoId = videoId &+ resource.photoId
                        }
                    case let .image(reference, imageRepresentations, videoRepresentationsValue, immediateThumbnail):
                        representations = imageRepresentations
                        videoRepresentations = videoRepresentationsValue
                        immediateThumbnailData = immediateThumbnail
                        if case let .cloud(imageId, _, _) = reference {
                            videoId = imageId
                        } else {
                            videoId = peer.id.id._internalGetInt64Value()
                        }
                }
                
                self.containerNode.isGestureEnabled = !isSettings
                
                if let video = videoRepresentations.last, let peerReference = PeerReference(peer) {
                    let videoFileReference = FileMediaReference.avatarList(peer: peerReference, media: ElloAppMediaFile(fileId: MediaId(namespace: Namespaces.Media.LocalFile, id: 0), partialReference: nil, resource: video.representation.resource, previewRepresentations: representations.map { $0.representation }, videoThumbnails: [], immediateThumbnailData: immediateThumbnailData, mimeType: "video/mp4", size: nil, attributes: [.Animated, .Video(duration: 0, size: video.representation.dimensions, flags: [])]))
                    let videoContent = NativeVideoContent(id: .profileVideo(videoId, nil), fileReference: videoFileReference, streamVideo: isMediaStreamable(resource: video.representation.resource) ? .conservative : .none, loopVideo: true, enableSound: false, fetchAutomatically: true, onlyFullSizeThumbnail: false, useLargeThumbnail: true, autoFetchFullSizeThumbnail: true, startTimestamp: video.representation.startTimestamp, continuePlayingWithoutSoundOnLostAudioSession: false, placeholderColor: .clear, captureProtected: peer.isCopyProtectionEnabled)
                    if videoContent.id != self.videoContent?.id {
                        self.videoNode?.removeFromSupernode()
                        
                        let mediaManager = self.context.sharedContext.mediaManager
                        let videoNode = UniversalVideoNode(postbox: self.context.account.postbox, audioSession: mediaManager.audioSession, manager: mediaManager.universalVideoManager, decoration: GalleryVideoDecoration(), content: videoContent, priority: .embedded)
                        videoNode.isUserInteractionEnabled = false
                        videoNode.isHidden = true
                        
                        if let startTimestamp = video.representation.startTimestamp {
                            self.videoStartTimestamp = startTimestamp
                            self.playbackStartDisposable.set((videoNode.status
                                                              |> map { status -> Bool in
                                if let status = status, case .playing = status.status {
                                    return true
                                } else {
                                    return false
                                }
                            }
                                                              |> filter { playing in
                                return playing
                            }
                                                              |> take(1)
                                                              |> deliverOnMainQueue).start(completed: { [weak self] in
                                if let strongSelf = self {
                                    Queue.mainQueue().after(0.15) {
                                        strongSelf.videoNode?.isHidden = false
                                    }
                                }
                            }))
                        } else {
                            self.videoStartTimestamp = nil
                            self.playbackStartDisposable.set(nil)
                            videoNode.isHidden = false
                        }
                        
                        self.videoContent = videoContent
                        self.videoNode = videoNode
                        
                        let maskPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(), size: self.avatarNode.frame.size))
                        let shape = CAShapeLayer()
                        shape.path = maskPath.cgPath
                        videoNode.layer.mask = shape
                        
                        self.containerNode.addSubnode(videoNode)
                    }
                } else if let videoNode = self.videoNode {
                    self.videoContent = nil
                    self.videoNode = nil
                    
                    videoNode.removeFromSupernode()
                }
            } else if let videoNode = self.videoNode {
                self.videoContent = nil
                self.videoNode = nil
                
                videoNode.removeFromSupernode()
                
                self.containerNode.isGestureEnabled = false
            }
            
            if let videoNode = self.videoNode {
                if self.canAttachVideo {
                    videoNode.updateLayout(size: self.avatarNode.frame.size, transition: .immediate)
                }
                videoNode.frame = self.avatarNode.frame
                
                if isExpanded == videoNode.canAttachContent {
                    self.isExpanded = isExpanded
                    let update = {
                        videoNode.canAttachContent = !self.isExpanded && self.canAttachVideo
                        if videoNode.canAttachContent {
                            videoNode.play()
                        }
                    }
                    if isExpanded {
                        DispatchQueue.main.async {
                            update()
                        }
                    } else {
                        update()
                    }
                }
            }
        }
    }
}
