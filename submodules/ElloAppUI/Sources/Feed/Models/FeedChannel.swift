//
//  FeedChannel.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import UIKit
import ElloAppCore

class FeedChannel {
    let channel: ElloAppChannel
    var id: Int {
        Int(channel.id.id._internalGetInt64Value())
    }
    var title: String {
        channel.title
    }
    var description = ""
    var isMuted = false
    var isPayed = false
    var isAdult = false
    var isActive = false
    
    init(channel: ElloAppChannel) {
        self.channel = channel
    }
}
