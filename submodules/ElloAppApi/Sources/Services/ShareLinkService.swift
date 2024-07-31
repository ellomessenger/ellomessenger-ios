//
//  ShareLinkService.swift
//  _idx_ElloAppApi_28230D29_ios_min14.0
//
//

import Foundation

struct ShareLinkService: MTProtoClient {
    func generateLink(peerId: Int, peerType: SharedLinkItem.PeerType, messageId: Int) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<HashItem>) {
        sendRequest(endpoint: ShareLinkEndpoint.generateLink(peerId: peerId, peerType: peerType, messageId: messageId))
    }
    func checkLink(hash: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<SharedLinkItem>) {
        sendRequest(endpoint: ShareLinkEndpoint.checkLink(hash: hash))
    }
}
