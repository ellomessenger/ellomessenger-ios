import Foundation
import ElloAppCore

public enum WebsiteType {
    case generic
    case twitter
    case instagram
}

public func websiteType(of websiteName: String?) -> WebsiteType {
    if let websiteName = websiteName?.lowercased() {
        if websiteName == "twitter" {
            return .twitter
        } else if websiteName == "instagram" {
            return .instagram
        }
    }
    return .generic
}

public enum InstantPageType {
    case generic
    case album
}

public func instantPageType(of webpage: ElloAppMediaWebpageLoadedContent) -> InstantPageType {
    if let type = webpage.type, type == "elloapp_album" {
        return .album
    }
    
    switch websiteType(of: webpage.websiteName) {
        case .instagram, .twitter:
            return .album
        default:
            return .generic
    }
}
