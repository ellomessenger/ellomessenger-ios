import Foundation
import Postbox
import ElloAppApi


extension ElloAppChatBannedRights {
    init(apiBannedRights: Api.ChatBannedRights) {
        switch apiBannedRights {
            case let .chatBannedRights(flags, untilDate):
                self.init(flags: ElloAppChatBannedRightsFlags(rawValue: flags), untilDate: untilDate)
        }
    }
    
    var apiBannedRights: Api.ChatBannedRights {
        return .chatBannedRights(flags: self.flags.rawValue, untilDate: self.untilDate)
    }
}
