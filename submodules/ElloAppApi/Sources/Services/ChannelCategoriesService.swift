//
//  WalletService.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

struct ChannelCategoriesService: MTProtoClient {
    typealias CategoriesResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    func channelCategories() -> CategoriesResponse<ChannelCategoriesItem> {
        sendRequest(endpoint: ChannelCategoryListEndpoint.categoryList)
    }
    
    func channelGenres() -> CategoriesResponse<ChannelGenresItem> {
        sendRequest(endpoint: ChannelCategoryListEndpoint.genreList)
    }
}
