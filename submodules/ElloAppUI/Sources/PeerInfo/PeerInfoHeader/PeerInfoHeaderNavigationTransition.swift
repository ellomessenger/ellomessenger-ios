//
//  PeerInfoHeaderNavigationTransition.swift
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

// MARK: - PeerInfoHeaderNavigationTransition

final class PeerInfoHeaderNavigationTransition {
    let sourceNavigationBar: NavigationBar
    let sourceTitleView: ChatTitleView
    let sourceTitleFrame: CGRect
    let sourceSubtitleFrame: CGRect
    let fraction: CGFloat
    
    init(sourceNavigationBar: NavigationBar, sourceTitleView: ChatTitleView, sourceTitleFrame: CGRect, sourceSubtitleFrame: CGRect, fraction: CGFloat) {
        self.sourceNavigationBar = sourceNavigationBar
        self.sourceTitleView = sourceTitleView
        self.sourceTitleFrame = sourceTitleFrame
        self.sourceSubtitleFrame = sourceSubtitleFrame
        self.fraction = fraction
    }
}
