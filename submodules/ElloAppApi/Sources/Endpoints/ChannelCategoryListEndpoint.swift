//
//  ChannelCategoryListEndpoint.swift
//  _idx_ElloAppApi_36395C1E_ios_min14.0
//
//

import Foundation

public enum ChannelCategoryListEndpoint {
    case categoryList
    case genreList
}

extension ChannelCategoryListEndpoint: Endpoint {
    public var service: MTProtoService {
        .channelsCustomize
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .categoryList:
            ChannelsCustomizeMethod.channelCategoryList
        case .genreList:
            ChannelsCustomizeMethod.channelGenreList
        }
        
    }
    
    public var data: [String : Any] {
        return [:]
    }
    
}
