//
//  PeerInfoHeaderNavigationButton.swift
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


// MARK: - PeerInfoHeaderNavigationButton

final class PeerInfoHeaderNavigationButton: HighlightableButtonNode {
    let containerNode: ContextControllerSourceNode
    let contextSourceNode: ContextReferenceContentNode
    private let regularTextNode: ImmediateTextNode
    private let whiteTextNode: ImmediateTextNode
    private let iconNode: ASImageNode
    private var animationNode: MoreIconNode?
    
    private var key: PeerInfoHeaderNavigationButtonKey?
    private var theme: PresentationTheme?
    
    var isWhite: Bool = false {
        didSet {
            if self.isWhite != oldValue {
                if case .qrCode = self.key, let theme = self.theme {
                    self.iconNode.image = self.isWhite ? generateTintedImage(image: PresentationResourcesRootController.navigationQrCodeIcon(theme), color: .white) : PresentationResourcesRootController.navigationQrCodeIcon(theme)
                }
                
                self.regularTextNode.isHidden = self.isWhite
                self.whiteTextNode.isHidden = !self.isWhite
            }
        }
    }
    
    var action: ((ASDisplayNode, ContextGesture?) -> Void)?
    
    init() {
        self.contextSourceNode = ContextReferenceContentNode()
        self.containerNode = ContextControllerSourceNode()
        self.containerNode.animateScale = false
        
        self.regularTextNode = ImmediateTextNode()
        self.whiteTextNode = ImmediateTextNode()
        self.whiteTextNode.isHidden = true
        
        self.iconNode = ASImageNode()
        self.iconNode.displaysAsynchronously = false
        self.iconNode.displayWithoutProcessing = true
        
        super.init(pointerStyle: .insetRectangle(-8.0, 2.0))
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = .button
        
        self.containerNode.addSubnode(self.contextSourceNode)
        self.contextSourceNode.addSubnode(self.regularTextNode)
        self.contextSourceNode.addSubnode(self.whiteTextNode)
        self.contextSourceNode.addSubnode(self.iconNode)
        
        self.addSubnode(self.containerNode)
        
        self.containerNode.activated = { [weak self] gesture, _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.action?(strongSelf.contextSourceNode, gesture)
        }
        
        self.addTarget(self, action: #selector(self.pressed), forControlEvents: .touchUpInside)
    }
    
    @objc private func pressed() {
        self.animationNode?.play()
        self.action?(self.contextSourceNode, nil)
    }
    
    func update(key: PeerInfoHeaderNavigationButtonKey, presentationData: PresentationData, height: CGFloat) -> CGSize {
        let textSize: CGSize
        let isFirstTime = self.key == nil
        if self.key != key || self.theme !== presentationData.theme {
            self.key = key
            self.theme = presentationData.theme
            
            let text: String
            var icon: UIImage?
            var isBold = false
            var isGestureEnabled = false
            var isAnimation = false
            var animationState: MoreIconNodeState = .more
            switch key {
                case .edit:
                    text = presentationData.strings.Common_Edit
                case .done, .cancel, .selectionDone:
                    text = presentationData.strings.Common_Done
                    isBold = true
                case .select:
                    text = presentationData.strings.Common_Select
                case .search:
                    text = ""
                    icon = nil// PresentationResourcesRootController.navigationCompactSearchIcon(presentationData.theme)
                    isAnimation = true
                    animationState = .search
                case .editPhoto:
                    text = presentationData.strings.Settings_EditPhoto
                case .editVideo:
                    text = presentationData.strings.Settings_EditVideo
                case .more:
                    text = ""
                    icon = nil// PresentationResourcesRootController.navigationMoreCircledIcon(presentationData.theme)
                    isGestureEnabled = true
                    isAnimation = true
                    animationState = .more
                case .qrCode:
                    text = ""
                    icon = PresentationResourcesRootController.navigationQrCodeIcon(presentationData.theme)
                case .moreToSearch:
                    text = ""
                case .settingEdit:
                    text = presentationData.strings.Common_Edit
//                    icon = PresentationResourcesRootController.navigationEditIcon(presentationData.theme)
            }
            self.accessibilityLabel = text
            self.containerNode.isGestureEnabled = isGestureEnabled
            
            let font: UIFont = isBold ? Font.semibold(17.0) : Font.regular(17.0)
            
            self.regularTextNode.attributedText = NSAttributedString(string: text, font: font, textColor: presentationData.theme.rootController.navigationBar.accentTextColor)
            self.whiteTextNode.attributedText = NSAttributedString(string: text, font: font, textColor: .white)
            self.iconNode.image = icon
            
            if isAnimation {
                self.iconNode.isHidden = true
                let animationNode: MoreIconNode
                if let current = self.animationNode {
                    animationNode = current
                } else {
                    animationNode = MoreIconNode()
                    self.animationNode = animationNode
                    self.contextSourceNode.addSubnode(animationNode)
                }
                animationNode.customColor = presentationData.theme.rootController.navigationBar.accentTextColor
                animationNode.enqueueState(animationState, animated: !isFirstTime)
            } else {
                self.iconNode.isHidden = false
                if let current = self.animationNode {
                    self.animationNode = nil
                    current.removeFromSupernode()
                }
            }
            
            textSize = self.regularTextNode.updateLayout(CGSize(width: 200.0, height: .greatestFiniteMagnitude))
            let _ = self.whiteTextNode.updateLayout(CGSize(width: 200.0, height: .greatestFiniteMagnitude))
        } else {
            textSize = self.regularTextNode.bounds.size
        }
        
        let inset: CGFloat = 0.0
        
        let textFrame = CGRect(origin: CGPoint(x: inset, y: floor((height - textSize.height) / 2.0)), size: textSize)
        self.regularTextNode.frame = textFrame
        self.whiteTextNode.frame = textFrame
        
        if let animationNode = self.animationNode {
            let animationSize = CGSize(width: 30.0, height: 30.0)
            
            animationNode.frame = CGRect(origin: CGPoint(x: inset, y: floor((height - animationSize.height) / 2.0)), size: animationSize)
            
            let size = CGSize(width: animationSize.width + inset * 2.0, height: height)
            self.containerNode.frame = CGRect(origin: CGPoint(), size: size)
            self.contextSourceNode.frame = CGRect(origin: CGPoint(), size: size)
            return size
        } else if let image = self.iconNode.image {
            self.iconNode.frame = CGRect(origin: CGPoint(x: inset, y: floor((height - image.size.height) / 2.0)), size: image.size)
            
            let size = CGSize(width: image.size.width + inset * 2.0, height: height)
            self.containerNode.frame = CGRect(origin: CGPoint(), size: size)
            self.contextSourceNode.frame = CGRect(origin: CGPoint(), size: size)
            return size
        } else {
            let size = CGSize(width: textSize.width + inset * 2.0, height: height)
            self.containerNode.frame = CGRect(origin: CGPoint(), size: size)
            self.contextSourceNode.frame = CGRect(origin: CGPoint(), size: size)
            return size
        }
    }
}

enum PeerInfoHeaderNavigationButtonKey {
    case edit
    case done
    case cancel
    case select
    case selectionDone
    case search
    case editPhoto
    case editVideo
    case more
    case qrCode
    case moreToSearch
    case settingEdit
}

struct PeerInfoHeaderNavigationButtonSpec: Equatable {
    let key: PeerInfoHeaderNavigationButtonKey
    let isForExpandedView: Bool
}

final class PeerInfoHeaderNavigationButtonContainerNode: ASDisplayNode {
    private var presentationData: PresentationData?
    private(set) var leftButtonNodes: [PeerInfoHeaderNavigationButtonKey: PeerInfoHeaderNavigationButton] = [:]
    private(set) var rightButtonNodes: [PeerInfoHeaderNavigationButtonKey: PeerInfoHeaderNavigationButton] = [:]
    
    private var currentLeftButtons: [PeerInfoHeaderNavigationButtonSpec] = []
    private var currentRightButtons: [PeerInfoHeaderNavigationButtonSpec] = []
    
    var isWhite: Bool = false {
        didSet {
            if self.isWhite != oldValue {
                for (_, buttonNode) in self.leftButtonNodes {
                    buttonNode.isWhite = self.isWhite
                }
                for (_, buttonNode) in self.rightButtonNodes {
                    buttonNode.isWhite = self.isWhite
                }
            }
        }
    }
    
    var performAction: ((PeerInfoHeaderNavigationButtonKey, ContextReferenceContentNode?, ContextGesture?) -> Void)?
    
    func update(size: CGSize, presentationData: PresentationData, leftButtons: [PeerInfoHeaderNavigationButtonSpec], rightButtons: [PeerInfoHeaderNavigationButtonSpec], expandFraction: CGFloat, transition: ContainedViewLayoutTransition) {
        let maximumExpandOffset: CGFloat = 14.0
        let expandOffset: CGFloat = -expandFraction * maximumExpandOffset
        
        if self.currentLeftButtons != leftButtons || presentationData.strings !== self.presentationData?.strings {
            self.currentLeftButtons = leftButtons
            
            var nextRegularButtonOrigin = 16.0
            var nextExpandedButtonOrigin = 16.0
            for spec in leftButtons.reversed() {
                let buttonNode: PeerInfoHeaderNavigationButton
                var wasAdded = false
                if let current = self.leftButtonNodes[spec.key] {
                    buttonNode = current
                } else {
                    wasAdded = true
                    buttonNode = PeerInfoHeaderNavigationButton()
                    self.leftButtonNodes[spec.key] = buttonNode
                    self.addSubnode(buttonNode)
                    buttonNode.isWhite = self.isWhite
                    buttonNode.action = { [weak self] _, gesture in
                        guard let strongSelf = self, let buttonNode = strongSelf.leftButtonNodes[spec.key] else {
                            return
                        }
                        strongSelf.performAction?(spec.key, buttonNode.contextSourceNode, gesture)
                    }
                }
                let buttonSize = buttonNode.update(key: spec.key, presentationData: presentationData, height: size.height)
                var nextButtonOrigin = spec.isForExpandedView ? nextExpandedButtonOrigin : nextRegularButtonOrigin
                let buttonFrame = CGRect(origin: CGPoint(x: nextButtonOrigin, y: expandOffset + (spec.isForExpandedView ? maximumExpandOffset : 0.0)), size: buttonSize)
                nextButtonOrigin += buttonSize.width + 4.0
                if spec.isForExpandedView {
                    nextExpandedButtonOrigin = nextButtonOrigin
                } else {
                    nextRegularButtonOrigin = nextButtonOrigin
                }
                let alphaFactor: CGFloat = spec.isForExpandedView ? expandFraction : (1.0 - expandFraction)
                if wasAdded {
                    buttonNode.frame = buttonFrame
                    buttonNode.alpha = 0.0
                    transition.updateAlpha(node: buttonNode, alpha: alphaFactor * alphaFactor)
                } else {
                    transition.updateFrameAdditiveToCenter(node: buttonNode, frame: buttonFrame)
                    transition.updateAlpha(node: buttonNode, alpha: alphaFactor * alphaFactor)
                }
            }
            var removeKeys: [PeerInfoHeaderNavigationButtonKey] = []
            for (key, _) in self.leftButtonNodes {
                if !leftButtons.contains(where: { $0.key == key }) {
                    removeKeys.append(key)
                }
            }
            for key in removeKeys {
                if let buttonNode = self.leftButtonNodes.removeValue(forKey: key) {
                    buttonNode.removeFromSupernode()
                }
            }
        } else {
            var nextRegularButtonOrigin = 16.0
            var nextExpandedButtonOrigin = 16.0
            for spec in leftButtons.reversed() {
                if let buttonNode = self.leftButtonNodes[spec.key] {
                    let buttonSize = buttonNode.bounds.size
                    var nextButtonOrigin = spec.isForExpandedView ? nextExpandedButtonOrigin : nextRegularButtonOrigin
                    let buttonFrame = CGRect(origin: CGPoint(x: nextButtonOrigin, y: expandOffset + (spec.isForExpandedView ? maximumExpandOffset : 0.0)), size: buttonSize)
                    nextButtonOrigin += buttonSize.width + 4.0
                    if spec.isForExpandedView {
                        nextExpandedButtonOrigin = nextButtonOrigin
                    } else {
                        nextRegularButtonOrigin = nextButtonOrigin
                    }
                    transition.updateFrameAdditiveToCenter(node: buttonNode, frame: buttonFrame)
                    let alphaFactor: CGFloat = spec.isForExpandedView ? expandFraction : (1.0 - expandFraction)
                    
                    var buttonTransition = transition
                    if case let .animated(duration, curve) = buttonTransition, alphaFactor == 0.0 {
                        buttonTransition = .animated(duration: duration * 0.25, curve: curve)
                    }
                    buttonTransition.updateAlpha(node: buttonNode, alpha: alphaFactor * alphaFactor)
                }
            }
        }
        
        if self.currentRightButtons != rightButtons || presentationData.strings !== self.presentationData?.strings {
            self.currentRightButtons = rightButtons
            
            var nextRegularButtonOrigin = size.width - 16.0
            var nextExpandedButtonOrigin = size.width - 16.0
            for spec in rightButtons.reversed() {
                let buttonNode: PeerInfoHeaderNavigationButton
                var wasAdded = false
                
                var key = spec.key
                if key == .more || key == .search {
                    key = .moreToSearch
                }
                
                if let current = self.rightButtonNodes[key] {
                    buttonNode = current
                } else {
                    wasAdded = true
                    buttonNode = PeerInfoHeaderNavigationButton()
                    self.rightButtonNodes[key] = buttonNode
                    self.addSubnode(buttonNode)
                    buttonNode.isWhite = self.isWhite
                }
                buttonNode.action = { [weak self] _, gesture in
                    guard let strongSelf = self, let buttonNode = strongSelf.rightButtonNodes[key] else {
                        return
                    }
                    strongSelf.performAction?(spec.key, buttonNode.contextSourceNode, gesture)
                }
                let buttonSize = buttonNode.update(key: spec.key, presentationData: presentationData, height: size.height)
                var nextButtonOrigin = spec.isForExpandedView ? nextExpandedButtonOrigin : nextRegularButtonOrigin
                let buttonFrame = CGRect(origin: CGPoint(x: nextButtonOrigin - buttonSize.width, y: expandOffset + (spec.isForExpandedView ? maximumExpandOffset : 0.0)), size: buttonSize)
                nextButtonOrigin -= buttonSize.width + 4.0
                if spec.isForExpandedView {
                    nextExpandedButtonOrigin = nextButtonOrigin
                } else {
                    nextRegularButtonOrigin = nextButtonOrigin
                }
                let alphaFactor: CGFloat = spec.isForExpandedView ? expandFraction : (1.0 - expandFraction)
                if wasAdded {
                    if key == .moreToSearch {
                        buttonNode.layer.animateScale(from: 0.001, to: 1.0, duration: 0.2)
                    }
                    
                    buttonNode.frame = buttonFrame
                    buttonNode.alpha = 0.0
                    transition.updateAlpha(node: buttonNode, alpha: alphaFactor * alphaFactor)
                } else {
                    transition.updateFrameAdditiveToCenter(node: buttonNode, frame: buttonFrame)
                    transition.updateAlpha(node: buttonNode, alpha: alphaFactor * alphaFactor)
                }
            }
            var removeKeys: [PeerInfoHeaderNavigationButtonKey] = []
            for (key, _) in self.rightButtonNodes {
                if key == .moreToSearch {
                    if !rightButtons.contains(where: { $0.key == .more || $0.key == .search }) {
                        removeKeys.append(key)
                    }
                } else if !rightButtons.contains(where: { $0.key == key }) {
                    removeKeys.append(key)
                }
            }
            for key in removeKeys {
                if let buttonNode = self.rightButtonNodes.removeValue(forKey: key) {
                    if key == .moreToSearch {
                        buttonNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak buttonNode] _ in
                            buttonNode?.removeFromSupernode()
                        })
                        buttonNode.layer.animateScale(from: 1.0, to: 0.001, duration: 0.2, removeOnCompletion: false)
                    } else {
                        buttonNode.removeFromSupernode()
                    }
                }
            }
        } else {
            var nextRegularButtonOrigin = size.width - 16.0
            var nextExpandedButtonOrigin = size.width - 16.0
            
            for spec in rightButtons.reversed() {
                var key = spec.key
                if key == .more || key == .search {
                    key = .moreToSearch
                }
                
                if let buttonNode = self.rightButtonNodes[key] {
                    let buttonSize = buttonNode.bounds.size
                    var nextButtonOrigin = spec.isForExpandedView ? nextExpandedButtonOrigin : nextRegularButtonOrigin
                    let buttonFrame = CGRect(origin: CGPoint(x: nextButtonOrigin - buttonSize.width, y: expandOffset + (spec.isForExpandedView ? maximumExpandOffset : 0.0)), size: buttonSize)
                    nextButtonOrigin -= buttonSize.width + 4.0
                    if spec.isForExpandedView {
                        nextExpandedButtonOrigin = nextButtonOrigin
                    } else {
                        nextRegularButtonOrigin = nextButtonOrigin
                    }
                    transition.updateFrameAdditiveToCenter(node: buttonNode, frame: buttonFrame)
                    let alphaFactor: CGFloat = spec.isForExpandedView ? expandFraction : (1.0 - expandFraction)
                    
                    var buttonTransition = transition
                    if case let .animated(duration, curve) = buttonTransition, alphaFactor == 0.0 {
                        buttonTransition = .animated(duration: duration * 0.25, curve: curve)
                    }
                    buttonTransition.updateAlpha(node: buttonNode, alpha: alphaFactor * alphaFactor)
                }
            }
        }
        self.presentationData = presentationData
    }
}
