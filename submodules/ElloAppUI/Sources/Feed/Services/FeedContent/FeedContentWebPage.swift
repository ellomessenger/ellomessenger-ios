//
//  FeedContentPhoto.swift
//  _idx_ELFeedUI_D7AD696F_ios_min11.0
//
//

import Foundation
import Display
import ElloAppCore
import UIKit
import Postbox

extension FeedContentWebPageItem: Hashable {
    static func == (lhs: FeedContentWebPageItem, rhs: FeedContentWebPageItem) -> Bool {
        lhs.media == rhs.media
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(media.url)
        hasher.combine(media.displayUrl)
        hasher.combine(media.hash)
        hasher.combine(media.type)
        hasher.combine(media.websiteName)
        hasher.combine(media.title)
        hasher.combine(media.text)
        hasher.combine(media.embedUrl)
        hasher.combine(media.embedSize?.hashValue)
        hasher.combine(media.author)
    }
}

class FeedContentWebPageItem {
    let media: ElloAppMediaWebpageLoadedContent
    
    init(media: ElloAppMediaWebpageLoadedContent) {
        self.media = media
    }
}
