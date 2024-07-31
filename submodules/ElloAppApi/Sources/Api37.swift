//
//  Api37.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public extension Api.functions.help {
    typealias CategoriesResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    private static var categoryService: ChannelCategoriesService {
        ChannelCategoriesService()
    }
    
    static func channelCategories() -> CategoriesResponse<ChannelCategoriesItem> {
        return categoryService.channelCategories()
    }
    
    static func channelGenres() -> CategoriesResponse<ChannelGenresItem> {
        return categoryService.channelGenres()
    }
}
