import Foundation

public enum ElloAppPeerAccessHash: Hashable {
    case personal(Int64)
    case genericPublic(Int64)
    
    public var value: Int64 {
        switch self {
        case let .personal(personal):
            return personal
        case let .genericPublic(genericPublic):
            return genericPublic
        }
    }
}
