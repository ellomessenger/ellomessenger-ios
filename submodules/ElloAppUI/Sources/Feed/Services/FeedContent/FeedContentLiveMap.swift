//
//  FeedContentLiveMapItem.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import Foundation
import Postbox
import AccountContext
import ElloAppPresentationData
import ElloAppCore
import SwiftSignalKit
import Display
import UIKit
import Contacts
import CoreLocation

extension FeedContentLiveMapItem: Hashable {
    static func == (lhs: FeedContentLiveMapItem, rhs: FeedContentLiveMapItem) -> Bool {
        lhs.message == rhs.message && lhs.media == rhs.media && lhs.peerId == rhs.peerId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(message)
        hasher.combine(media)
        hasher.combine(peerId)
    }
}

class FeedContentLiveMapItem {
    let message: FeedRootItem
    let media: ElloAppMediaMap
    let accountContext: AccountContext
    let presentationData: PresentationData
    let peerId: PeerId
    var controller: ViewController?
    
    private let defaultSize = CGSize(width: 128, height: 128)
    
    init(message: FeedRootItem, media: ElloAppMediaMap, accountContext: AccountContext, presentationData: PresentationData, peerId: PeerId, controller: ViewController? = nil) {
        self.message = message
        self.media = media
        self.accountContext = accountContext
        self.presentationData = presentationData
        self.peerId = peerId
        self.controller = controller
    }
    
    func openFile() {
        guard let messageId = message.messageId else {
            return
        }
        
        _ = (accountContext.account.postbox.messageAtId(messageId)
             |> deliverOnMainQueue).start { [weak self] message in
            guard let message, let self, let controller else {
                return
            }
            
            let navigationController = controller.navigationController as! NavigationController
            let chatParams = OpenChatMessageParams(
                context: accountContext,
                chatLocation: nil,
                chatLocationContextHolder: nil,
                message: message,
                standalone: false,
                reverseMessageGalleryOrder: true,
                navigationController: navigationController,
                dismissInput: { },
                present: {_,_ in },
                transitionNode: {_,_ in return nil },
                addToTransitionSurface: {_ in },
                openUrl: {_ in },
                openPeer: {_,_ in },
                callPeer: {_,_ in },
                enqueueMessage: {_ in },
                sendSticker: nil,
                sendEmoji: nil,
                setupTemporaryHiddenMedia: {_,_,_ in },
                chatAvatarHiddenMedia: {_,_ in })
            
            _ = accountContext.sharedContext.openChatMessage(chatParams)
        }
    }
    
    func arguments() -> TransformImageArguments {
        let mediaSize = size(for: media)
        return TransformImageArguments(
            corners: ImageCorners(),
            imageSize: mediaSize,
            boundingSize: mediaSize,
            intrinsicInsets: UIEdgeInsets()
        )
    }
    
    private func size(for media: Media?) -> CGSize {
        guard let media else {
            return defaultSize
        }
        
        var pixelDemensions: PixelDimensions?
        switch media {
        case let media as ElloAppMediaImage:
            pixelDemensions = largestImageRepresentation(media.representations)?.dimensions
        case let media as ElloAppMediaFile:
            pixelDemensions = media.dimensions
        default:
            return defaultSize
        }
        
        let mediaSize = pixelDemensions?.cgSize ?? defaultSize
        return mediaSize
    }
    
    func getAddress(completionHandler: @escaping (_ address: String) -> Void) {
        let location = CLLocation(latitude: media.latitude, longitude: media.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error {
                debugPrint("reverse geodcode fail: \(error.localizedDescription)")
            }
            guard let placemark = placemarks?.first else {
                completionHandler("Unknown location")
                return
            }
            
            var addressString = ""
            if let subLocality = placemark.subLocality {
                addressString = addressString + subLocality + ", "
            }
            if let subThoroughfare = placemark.subThoroughfare {
                addressString = addressString + subThoroughfare
            }
            if let thoroughfare = placemark.thoroughfare {
                addressString = addressString + thoroughfare + ", "
            }
            if let locality = placemark.locality {
                addressString = addressString + locality + ", "
            }
            if let country = placemark.country {
                addressString = addressString + country
            }
            
            completionHandler(addressString)
        }
    }
}
