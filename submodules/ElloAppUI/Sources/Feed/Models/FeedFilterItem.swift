//
//  FeedChannel.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import Foundation
import ElloAppApi

struct FeedFilterItem: Encodable {
    var all: [Int] = []
    var hidden: [Int] = []
    var pinned: [Int] = []
    var showRecommended = false
    var showOnlySubscriptions = false
    var showAdult = false
    
    enum CodingKeys: String, CodingKey {
        case all, hidden, pinned
        case showRecommended = "show_recommended"
        case showOnlySubscriptions = "show_only_subs"
        case showAdult = "show_adult"
    }
}

extension FeedFilterItem {
    init(responseObject: Api.functions.feeds.FeedFilterResponse) {
        all = responseObject.all
        pinned = responseObject.pinned
        hidden = responseObject.hidden
        showRecommended = responseObject.showRecommended
        showOnlySubscriptions = responseObject.showOnlySubscriptions
        showAdult = responseObject.showAdult
    }
}

extension FeedFilterItem {
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        return (try? JSONSerialization.jsonObject(with: encoder.encode(self))) as? [String: Any] ?? [:]
    }
}
