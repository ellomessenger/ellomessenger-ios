import Foundation
import Postbox

public enum ElloAppMediaExpiredContentData: Int32 {
    case image
    case file
}

public final class ElloAppMediaExpiredContent: Media {
    public let data: ElloAppMediaExpiredContentData
    
    public let id: MediaId? = nil
    public let peerIds: [PeerId] = []
    
    public init(data: ElloAppMediaExpiredContentData) {
        self.data = data
    }
    
    public init(decoder: PostboxDecoder) {
        self.data = ElloAppMediaExpiredContentData(rawValue: decoder.decodeInt32ForKey("d", orElse: 0))!
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.data.rawValue, forKey: "d")
    }
    
    public func isEqual(to other: Media) -> Bool {
        if let other = other as? ElloAppMediaExpiredContent {
            return self.data == other.data
        } else {
            return false
        }
    }
    
    public func isSemanticallyEqual(to other: Media) -> Bool {
        return self.isEqual(to: other)
    }
}
