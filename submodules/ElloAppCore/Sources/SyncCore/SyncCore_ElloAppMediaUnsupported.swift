import Foundation
import Postbox


public final class ElloAppMediaUnsupported: Media {
    public let id: MediaId? = nil
    public let peerIds: [PeerId] = []
    
    public init() {
    }
    
    public init(decoder: PostboxDecoder) {
    }
    
    public func encode(_ encoder: PostboxEncoder) {
    }
    
    public func isEqual(to other: Media) -> Bool {
        if other is ElloAppMediaUnsupported {
            return true
        }
        return false
    }
    
    public func isSemanticallyEqual(to other: Media) -> Bool {
        return self.isEqual(to: other)
    }
}
