//
//  ChannelCategoriesItem.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public struct ChannelGenresItem: MTProtoResponse {
    public let genres: [ChannelGenreItem]
}

public struct ChannelGenreItem: MTProtoResponse {
    let id: Int
    public let genre: String
}
