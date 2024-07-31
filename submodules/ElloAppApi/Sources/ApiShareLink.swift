//
//  ApiShareLink.swift
//  _idx_ElloAppApi_28230D29_ios_min14.0
//
//

import Foundation

public extension Api.shareLink {
    typealias ShareLinkResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    internal static var shareLinkServiceService: ShareLinkService {
        ShareLinkService()
    }
    
    static func generateLink(peerId: Int, peerType: SharedLinkItem.PeerType, messageId: Int) -> ShareLinkResponse<HashItem> {
        shareLinkServiceService.generateLink(peerId: peerId, peerType: peerType, messageId: messageId)
    }
    
    static func checkLink(hash: String) -> ShareLinkResponse<SharedLinkItem> {
        shareLinkServiceService.checkLink(hash: hash)
    }
}
