//
//  LikesEndpoint.swift
//  _idx_ElloAppApi_28230D29_ios_min14.0
//
//

import Foundation

public enum LikesEndpoint {
    case getLikes(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64)
    case addLike(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64)
    case removeLike(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64)
}

extension LikesEndpoint: Endpoint {
    public var service: MTProtoService {
        .likes
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .getLikes:
            return LikesMethod.likes
        case .addLike:
            return LikesMethod.addLike
        case .removeLike:
            return LikesMethod.removeLike
        }
    }
    
    public var data: [String : Any] {
        switch self {
        case let .getLikes(userId, messageId, peerType, peerId):
            ["user_id": userId, "msg_id": messageId, "fromId": ["peer_type": peerType.rawValue, "peer_id": peerId]]
        case let .addLike(userId, messageId, peerType, peerId):
            ["user_id": userId, "msg_id": messageId, "fromId": ["peer_type": peerType.rawValue, "peer_id": peerId]]
        case let .removeLike(userId, messageId, peerType, peerId):
            ["user_id": userId, "msg_id": messageId, "fromId": ["peer_type": peerType.rawValue, "peer_id": peerId]]
        }
    }
}
