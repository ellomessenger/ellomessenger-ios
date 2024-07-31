//
//  FeedFilterItem.swift
//  ElloAppUI
//
//

import Foundation

struct FeedRecomendedFilterItem: Hashable {
    let dataField: DataField
    let title: String
    let isList: Bool
}

extension FeedRecomendedFilterItem {
    static var filterItems: [FeedRecomendedFilterItem] {
        [
            FeedRecomendedFilterItem(dataField: .all, title: "All", isList: false),
            FeedRecomendedFilterItem(dataField: .isNew, title: "New", isList: false),
            FeedRecomendedFilterItem(dataField: .isCourse, title: "Course", isList: false),
            FeedRecomendedFilterItem(dataField: .isPaid, title: "Paid", isList: false),
            FeedRecomendedFilterItem(dataField: .isFree, title: "Free", isList: false),
            FeedRecomendedFilterItem(dataField: .country("", ""), title: "All Country", isList: true),
            FeedRecomendedFilterItem(dataField: .category(""), title: "All Categories", isList: true),
        ]
    }
}
