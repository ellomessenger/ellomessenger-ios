//
//  FeedContentManager.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import Foundation
import AccountContext
import ElloAppPresentationData
import Postbox
import SwiftSignalKit
import Display
import PhotoResources
import ElloAppCore
import LocationResources

extension FeedContentManager.FeedType: Hashable {
    static func == (lhs: FeedContentManager.FeedType, rhs: FeedContentManager.FeedType) -> Bool {
        switch (lhs, rhs) {
        case (.image(_, let lhsArguments), .image(_, let rhsArguments)):
            return lhsArguments == rhsArguments
        case (.video(_, let lhsArguments), .video(_, let rhsArguments)):
            return lhsArguments == rhsArguments
        case (.audio(let lhsArguments), .audio(let rhsArguments)):
            return lhsArguments == rhsArguments
        case (.file(let lhsArguments), .file(let rhsArguments)):
            return lhsArguments == rhsArguments
        case (.map(_, let lhsArguments), .map(_, let rhsArguments)):
            return lhsArguments == rhsArguments
        case (.liveMap(_, let lhsArguments), .liveMap(_, let rhsArguments)):
            return lhsArguments == rhsArguments
        case (.webPage(let lhsArguments, _), .webPage(let rhsArguments, _)):
            return lhsArguments == rhsArguments
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .image(_, let arguments):
            hasher.combine(arguments)
        case .video(_, let arguments):
            hasher.combine(arguments)
        case .audio(let arguments):
            hasher.combine(arguments)
        case .file(let arguments):
            hasher.combine(arguments)
        case .map(_, let arguments):
            hasher.combine(arguments)
        case .liveMap(_, let arguments):
            hasher.combine(arguments)
        case .webPage(let arguments, _):
            hasher.combine(arguments)
        }
    }
    
}

class FeedContentManager {
    indirect enum FeedType {
        case image(signal: Signal<(TransformImageArguments) -> DrawingContext?, NoError>, arguments: FeedContentPhotoItem)
        case video(signal: Signal<(TransformImageArguments) -> DrawingContext?, NoError>, arguments: FeedContentPhotoItem)
        case audio(arguments: FeedContentAudioItem)
        case file(arguments: FeedContentFileItem)
        case map(signal: Signal<(TransformImageArguments) -> DrawingContext?, NoError>, arguments: FeedContentMapItem)
        case liveMap(signal: Signal<(TransformImageArguments) -> DrawingContext?, NoError>, arguments: FeedContentLiveMapItem)
        case webPage(arguments: FeedContentWebPageItem, feedType: FeedType?)
        
        var cellIdentifier: String {
            switch self {
            case .image:
                return "FeedRootMediaCollectionViewCell"
            case .video:
                return "FeedRootVideoCollectionViewCell"
            case .audio:
                return "FeedRootAudioCollectionViewCell"
            case .file:
                return "FeedRootFileCollectionViewCell"
            case .map:
                return "FeedRootMapCollectionViewCell"
            case .liveMap:
                return "FeedRootLiveMapCollectionViewCell"
            case .webPage:
                return "FeedRootWebPageCollectionViewCell"
            }
        }
    }
    
    let accountContext: AccountContext
    let feedItem: FeedRootItem
    private var presentationData: PresentationData {
        accountContext.sharedContext.currentPresentationData.with { $0 }
    }
    private (set) lazy var feedTypes: [FeedType] = {
        getFeedType()
    }()
    private var controller: ViewController?
    
    init(accountContext: AccountContext, feedItem: FeedRootItem, controller: ViewController?) {
        self.accountContext = accountContext
        self.feedItem = feedItem
        self.controller = controller
    }
    
    private func getFeedType() -> [FeedType] {
        feedItem.media.compactMap { media in
            switch media {
            case let media as ElloAppMediaImage:
                return .image(
                    signal: mediaGridMessagePhoto(
                        account: accountContext.account,
                        photoReference: .standalone(media: media)),
                    arguments: FeedContentPhotoItem(
                        message: feedItem,
                        media: media,
                        accountContext: accountContext,
                        controller: controller)
                )
            case let media as ElloAppMediaFile where media.isVideo:
                return .video(
                    signal: mediaGridMessageVideo(
                        postbox: accountContext.account.postbox,
                        videoReference: .standalone(media: media),
                        autoFetchFullSizeThumbnail: true),
                    arguments: FeedContentPhotoItem(
                        message: feedItem,
                        media: media,
                        accountContext: accountContext,
                        controller: controller)
                )
            case let media as ElloAppMediaFile where media.isVoice || media.isMusic:
                return .audio(
                    arguments: FeedContentAudioItem(
                        message: feedItem,
                        media: media,
                        accountContext: accountContext,
                        presentationData: presentationData,
                        peerId: feedItem.id.peerId,
                        controller: controller)
                )
            case let media as ElloAppMediaFile:
                return .file(
                    arguments: FeedContentFileItem(
                        message: feedItem,
                        media: media,
                        accountContext: accountContext,
                        presentationData: presentationData,
                        peerId: feedItem.id.peerId,
                        controller: controller)
                )
            case let media as ElloAppMediaMap:
                let timestamp = Int32(Date().timeIntervalSince1970)
                let timestampSinceMessageSent = timestamp - feedItem.timestamp
                
                if let liveBroadcastingTimeout = media.liveBroadcastingTimeout,
                   timestampSinceMessageSent < liveBroadcastingTimeout {
                    return .liveMap(
                        signal: signal(selectedMedia: media),
                        arguments: FeedContentLiveMapItem(
                            message: feedItem,
                            media: media,
                            accountContext: accountContext,
                            presentationData: presentationData,
                            peerId: feedItem.id.peerId,
                            controller: controller)
                    )
                }
                
                return .map(
                    signal: signal(selectedMedia: media),
                    arguments: FeedContentMapItem(
                        message: feedItem,
                        media: media,
                        accountContext: accountContext,
                        presentationData: presentationData,
                        peerId: feedItem.id.peerId,
                        controller: controller)
                )
            case let media as ElloAppMediaWebpage:
                guard case .Loaded(let content) = media.content else { return nil }
                
                var feedType: FeedType?
                if let image = content.image {
                    feedType = .image(
                        signal: mediaGridMessagePhoto(
                            account: accountContext.account,
                            photoReference: .standalone(media: image)),
                        arguments: FeedContentPhotoItem(
                            message: feedItem,
                            media: media,
                            accountContext: accountContext,
                            controller: controller)
                        )
                }
                
                return .webPage(
                    arguments: FeedContentWebPageItem(media: content),
                    feedType: feedType)
            default:
                debugPrint(media)
                return nil
            }
        }
    }
    
    func signal(selectedMedia: ElloAppMediaMap) -> Signal<(TransformImageArguments) -> DrawingContext?, NoError> {
        var updateImageSignal: Signal<(TransformImageArguments) -> DrawingContext?, NoError>
//        let previousMedia: ElloAppMediaMap? = nil
        let imageSize = CGSize(width: 356, height: 356)
//        if previousMedia == nil || !previousMedia!.isEqual(to: selectedMedia) {
//            var updated = true
//            if let previousMedia = previousMedia {
//                if previousMedia.latitude.isEqual(to: selectedMedia.latitude) && previousMedia.longitude.isEqual(to: selectedMedia.longitude) {
//                    updated = false
//                }
//            }
//            if updated {
                updateImageSignal = chatMapSnapshotImage(engine: accountContext.engine, resource: MapSnapshotMediaResource(latitude: selectedMedia.latitude, longitude: selectedMedia.longitude, width: Int32(imageSize.width), height: Int32(imageSize.height)))
//            }
//        }
        
        return updateImageSignal
    }
}
