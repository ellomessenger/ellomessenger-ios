//
//  PeerInfoHeaderButtonNode.swift
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

// MARK: - PeerInfoHeaderButtonNode

final class PeerInfoHeaderButtonNode: HighlightableButtonNode {
    let key: PeerInfoHeaderButtonKey
    private let action: (PeerInfoHeaderButtonNode, ContextGesture?) -> Void
    let referenceNode: ContextReferenceContentNode
    let containerNode: ContextControllerSourceNode
    private let backgroundNode: ASDisplayNode
    private let iconNode: ASImageNode
    private let textNode: ImmediateTextNode
    private var animationNode: AnimationNode?
    
    private var theme: PresentationTheme?
    private var icon: PeerInfoHeaderButtonIcon?
    private var isActive: Bool?
    
    init(key: PeerInfoHeaderButtonKey, action: @escaping (PeerInfoHeaderButtonNode, ContextGesture?) -> Void) {
        self.key = key
        self.action = action
        
        self.referenceNode = ContextReferenceContentNode()
        self.containerNode = ContextControllerSourceNode()
        self.containerNode.animateScale = false
        
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.cornerRadius = 11.0
        
        self.iconNode = ASImageNode()
        self.iconNode.displaysAsynchronously = false
        self.iconNode.displayWithoutProcessing = true
        self.iconNode.isUserInteractionEnabled = false
        
        self.textNode = ImmediateTextNode()
        self.textNode.displaysAsynchronously = false
        self.textNode.isUserInteractionEnabled = false
        
        super.init()
        
        self.accessibilityTraits = .button
        
        self.containerNode.addSubnode(self.referenceNode)
        self.referenceNode.addSubnode(self.backgroundNode)
        self.referenceNode.addSubnode(self.iconNode)
        self.addSubnode(self.containerNode)
        self.addSubnode(self.textNode)
        
        self.highligthedChanged = { [weak self] highlighted in
            if let strongSelf = self {
                if highlighted {
                    strongSelf.layer.removeAnimation(forKey: "opacity")
                    strongSelf.alpha = 0.4
                } else {
                    strongSelf.alpha = 1.0
                    strongSelf.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
                }
            }
        }
        
        self.containerNode.activated = { [weak self] gesture, _ in
            if let strongSelf = self {
                strongSelf.action(strongSelf, gesture)
            }
        }
        
        self.addTarget(self, action: #selector(self.buttonPressed), forControlEvents: .touchUpInside)
    }
    
    @objc private func buttonPressed() {
        switch self.icon {
            case .voiceChat, .more, .leave:
                self.animationNode?.playOnce()
            default:
                break
        }
        self.action(self, nil)
    }
    
    func update(size: CGSize, text: String, icon: PeerInfoHeaderButtonIcon, isActive: Bool, isExpanded: Bool, presentationData: PresentationData, transition: ContainedViewLayoutTransition) {
        let previousIcon = self.icon
        let themeUpdated = self.theme != presentationData.theme
        let iconUpdated = self.icon != icon
        let isActiveUpdated = self.isActive != isActive
        self.isActive = isActive
        
        let iconSize = CGSize(width: 36.0, height: 36.0)
        
        if themeUpdated || iconUpdated {
            self.theme = presentationData.theme
            self.icon = icon
            
            var isGestureEnabled = false
            if [.mute, .voiceChat, .more].contains(icon) {
                isGestureEnabled = true
            }
            self.containerNode.isGestureEnabled = isGestureEnabled
            
            let animationName: String?
            var colors: [String: UIColor] = [:]
            var playOnce = false
            var seekToEnd = false
            let iconColor = presentationData.theme.list.itemAccentColor
            switch icon {
                case .voiceChat:
                    animationName = "anim_profilevc"
                    colors = ["Line 3.Group 1.Stroke 1": iconColor,
                              "Line 1.Group 1.Stroke 1": iconColor,
                              "Line 2.Group 1.Stroke 1": iconColor]
                
                case .mute:
                    animationName = "anim_profileunmute"
                    colors = ["Middle.Group 1.Fill 1": iconColor,
                              "Top.Group 1.Fill 1": iconColor,
                              "Bottom.Group 1.Fill 1": iconColor,
                              "EXAMPLE.Group 1.Fill 1": iconColor,
                              "Line.Group 1.Stroke 1": iconColor]
                    if previousIcon == .unmute {
                        playOnce = true
                    } else {
                        seekToEnd = true
                    }
                case .unmute:
                    animationName = "anim_profilemute"
                    colors = ["Middle.Group 1.Fill 1": iconColor,
                              "Top.Group 1.Fill 1": iconColor,
                              "Bottom.Group 1.Fill 1": iconColor,
                              "EXAMPLE.Group 1.Fill 1": iconColor,
                              "Line.Group 1.Stroke 1": iconColor]
                    if previousIcon == .mute {
                        playOnce = true
                    } else {
                        seekToEnd = true
                    }
                case .more:
                    animationName = "anim_profilemore"
                    colors = ["Ellipse 4.Ellipse 4.Заливка 1": iconColor,
                              "Ellipse 5.Ellipse 5.Заливка 1": iconColor,
                              "Ellipse 6.Ellipse 6.Заливка 1": iconColor]
                case .leave:
                    animationName = "anim_profileleave"
                    colors = ["Out.Arrow.Arrow 2.Arrow 2.Обводка 1": iconColor,
                              "Out.Arrow.Arrow 1.Arrow 1.Обводка 1": iconColor,
                              "Out.Vector.Vector.Обводка 1": iconColor]
                default:
                    animationName = nil
            }
            
            if let animationName = animationName {
                let animationNode: AnimationNode
                if let current = self.animationNode {
                    animationNode = current
                    animationNode.setAnimation(name: animationName, colors: colors)
                } else {
                    animationNode = AnimationNode(animation: animationName, colors: colors, scale: 1.0)
                    self.referenceNode.addSubnode(animationNode)
                    self.animationNode = animationNode
                    self.animationNode?.contentMode = .scaleToFill
                }
            } else if let animationNode = self.animationNode {
                self.animationNode = nil
                animationNode.removeFromSupernode()
            }
            
            if playOnce {
                self.animationNode?.play()
            } else if seekToEnd {
                self.animationNode?.seekToEnd()
            }
            
            self.backgroundNode.backgroundColor = presentationData.theme.list.itemBlocksBackgroundColor
            transition.updateFrame(node: self.backgroundNode, frame: CGRect(origin: CGPoint(), size: size))
            self.iconNode.image = generateImage(iconSize, contextGenerator: { size, context in
                context.clear(CGRect(origin: CGPoint(), size: size))
                context.setBlendMode(.normal)
                context.setFillColor(iconColor.cgColor)
                let imageName: String?
                switch icon {
                    case .message:
                        imageName = "Peer Info/ButtonMessage"
                    case .call:
                        imageName = "Peer Info/ButtonCall"
                    case .videoCall:
                        imageName = "Peer Info/ButtonVideo"
                    case .voiceChat:
                        imageName = nil
                    case .mute:
                        imageName = nil
                    case .unmute:
                        imageName = nil
                    case .more:
                        imageName = nil
                    case .addMember:
                        imageName = "Peer Info/ButtonAddMember"
                    case .search:
                        imageName = "Peer Info/ButtonSearch"
                    case .leave:
                        imageName = nil
                    case .stop:
                        imageName = "Peer Info/ButtonStop"
                }
                if let imageName = imageName, let image = generateTintedImage(image: UIImage(bundleImageName: imageName), color: .white) {
                    let imageRect = CGRect(origin: CGPoint(x: floor((size.width - image.size.width) / 2.0), y: floor((size.height - image.size.height) / 2.0)), size: image.size)
                    context.clip(to: imageRect, mask: image.cgImage!)
                    context.fill(imageRect)
                }
            })
        }
        
        if isActiveUpdated {
            let alphaTransition = ContainedViewLayoutTransition.animated(duration: 0.2, curve: .easeInOut)
            alphaTransition.updateAlpha(node: self.iconNode, alpha: isActive ? 1.0 : 0.3)
            if let animationNode = self.animationNode {
                alphaTransition.updateAlpha(node: animationNode, alpha: isActive ? 1.0 : 0.3)
            }
            alphaTransition.updateAlpha(node: self.textNode, alpha: isActive ? 1.0 : 0.3)
        }
        
        self.textNode.attributedText = NSAttributedString(string: text, font: Font.medium(11.0), textColor: presentationData.theme.list.itemAccentColor)
        self.accessibilityLabel = text
        let titleSize = self.textNode.updateLayout(CGSize(width: 120.0, height: .greatestFiniteMagnitude))
        
        transition.updateFrame(node: self.containerNode, frame: CGRect(origin: CGPoint(), size: size))
        transition.updateFrame(node: self.backgroundNode, frame: CGRect(origin: CGPoint(), size: size))
        transition.updateFrame(node: self.iconNode, frame: CGRect(origin: CGPoint(x: floor((size.width - iconSize.width) / 2.0), y: 3.0), size: iconSize))
        if let animationNode = self.animationNode {
            transition.updateFrame(node: animationNode, frame: CGRect(origin: CGPoint(x: floor((size.width - iconSize.width) / 2.0), y: 3.0), size: iconSize))
        }
        transition.updateFrameAdditiveToCenter(node: self.textNode, frame: CGRect(origin: CGPoint(x: floor((size.width - titleSize.width) / 2.0), y: size.height - titleSize.height - 9.0), size: titleSize))
        
        self.referenceNode.frame = self.containerNode.bounds
    }
}
