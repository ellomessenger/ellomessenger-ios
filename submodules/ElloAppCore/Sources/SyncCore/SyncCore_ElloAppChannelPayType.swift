import Foundation

public enum ElloAppChannelPayType {
    case free
    case onlineCourse
    case subscription
    
    var rawValue: Int32 {
        switch self {
        case .free:
            return 0
        case .onlineCourse:
            return 1
        case .subscription:
            return 2
        }
    }
    
    init(rawValue: Int32?) {
        switch rawValue {
        case 0:
            self = .free
        case 1:
            self = .onlineCourse
        case 2:
            self = .subscription
        default:
            self = .free
        }
    }
}
