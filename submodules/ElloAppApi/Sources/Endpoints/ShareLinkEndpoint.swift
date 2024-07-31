//
//  ShareLinkEndpoint.swift
//  _idx_ElloAppApi_28230D29_ios_min14.0
//
//

import Foundation

public enum ShareLinkEndpoint {
    case generateLink(peerId: Int, peerType: SharedLinkItem.PeerType, messageId: Int)
    case checkLink(hash: String)
}

extension ShareLinkEndpoint: Endpoint {
    public var service: MTProtoService {
        .shareLink
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .generateLink:
            return ShareLinkMethod.generateLink
        case .checkLink:
            return ShareLinkMethod.checkHash
        }
    }
    
    public var data: [String : Any] {
        switch self {
        case let .generateLink(peerId, peerType, messageId):
            return ["peer_id": peerId, "peer_type": peerType.rawValue, "msg_id": messageId]
        case let .checkLink(hash):
            return ["hash": hash]
        }
    }
}
