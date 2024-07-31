//
//  SharedLinkItem.swift
//  _idx_ElloAppApi_28230D29_ios_min14.0
//
//

import Foundation

public struct SharedLinkItem: MTProtoResponse {
    public enum PeerType: Int, Codable {
        case group = 3
        case channel = 4
    }
    
    /// channel_id or group_id
    let peerId: Int
    /// 4: channel, 3: group
    let peerType: PeerType
    /// Message Id
    let msgId: Int
}
