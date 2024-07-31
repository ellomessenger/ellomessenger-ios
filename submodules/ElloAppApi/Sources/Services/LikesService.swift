//
//  ShareLinkService.swift
//  _idx_ElloAppApi_28230D29_ios_min14.0
//
//

import Foundation

struct LikesService: MTProtoClient {
    func getLikes(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<UserIdsItem>) {
        sendRequest(endpoint: LikesEndpoint.getLikes(userId: userId, messageId: messageId, peerType: peerType, peerId: peerId))
    }
    func addLike(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<LikesStatusItem>) {
        sendRequest(endpoint: LikesEndpoint.addLike(userId: userId, messageId: messageId, peerType: peerType, peerId: peerId))
    }
    func removeLike(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<LikesStatusItem>) {
        sendRequest(endpoint: LikesEndpoint.removeLike(userId: userId, messageId: messageId, peerType: peerType, peerId: peerId))
    }
}
