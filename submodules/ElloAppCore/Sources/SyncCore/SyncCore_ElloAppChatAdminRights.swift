import Postbox

public struct ElloAppChatAdminRightsFlags: OptionSet, Hashable {
    public var rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.rawValue = 0
    }
    
    public static let canChangeInfo = ElloAppChatAdminRightsFlags(rawValue: 1 << 0)
    public static let canPostMessages = ElloAppChatAdminRightsFlags(rawValue: 1 << 1)
    public static let canEditMessages = ElloAppChatAdminRightsFlags(rawValue: 1 << 2)
    public static let canDeleteMessages = ElloAppChatAdminRightsFlags(rawValue: 1 << 3)
    public static let canBanUsers = ElloAppChatAdminRightsFlags(rawValue: 1 << 4)
    public static let canInviteUsers = ElloAppChatAdminRightsFlags(rawValue: 1 << 5)
    public static let canPinMessages = ElloAppChatAdminRightsFlags(rawValue: 1 << 7)
    public static let canAddAdmins = ElloAppChatAdminRightsFlags(rawValue: 1 << 9)
    public static let canBeAnonymous = ElloAppChatAdminRightsFlags(rawValue: 1 << 10)
    public static let canManageCalls = ElloAppChatAdminRightsFlags(rawValue: 1 << 11)
    
    public static var all: ElloAppChatAdminRightsFlags {
        return [.canChangeInfo, .canPostMessages, .canEditMessages, .canDeleteMessages, .canBanUsers, .canInviteUsers, /*.canPinMessages,*/ .canAddAdmins, /*.canBeAnonymous,*/ .canManageCalls]
    }
    
    public static var allChannel: ElloAppChatAdminRightsFlags {
        return [.canChangeInfo, .canPostMessages, .canEditMessages, .canDeleteMessages, .canBanUsers, .canInviteUsers, /*.canPinMessages,*/ .canAddAdmins, .canManageCalls]
    }

    
    public static var groupSpecific: ElloAppChatAdminRightsFlags = [
        .canChangeInfo,
        .canDeleteMessages,
        .canBanUsers,
        .canInviteUsers,
//        .canPinMessages,
        .canManageCalls,
//        .canBeAnonymous,
        .canAddAdmins
    ]
    
    public static var broadcastSpecific: ElloAppChatAdminRightsFlags = [
        .canChangeInfo,
        .canPostMessages,
        .canEditMessages,
        .canDeleteMessages,
        .canManageCalls,
        .canInviteUsers,
        .canAddAdmins
    ]
    
    public var count: Int {
        var result = 0
        var index = 0
        while index < 31 {
            let currentValue = self.rawValue >> Int32(index)
            index += 1
            if currentValue == 0 {
                break
            }
            
            if (currentValue & 1) != 0 {
                result += 1
            }
        }
        return result
    }
}

public struct ElloAppChatAdminRights: PostboxCoding, Equatable {
    public let rights: ElloAppChatAdminRightsFlags
    
    public init(rights: ElloAppChatAdminRightsFlags) {
        self.rights = rights
    }
    
    public init(decoder: PostboxDecoder) {
        self.rights = ElloAppChatAdminRightsFlags(rawValue: decoder.decodeInt32ForKey("f", orElse: 0))
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.rights.rawValue, forKey: "f")
    }
    
    public static func ==(lhs: ElloAppChatAdminRights, rhs: ElloAppChatAdminRights) -> Bool {
        return lhs.rights == rhs.rights
    }
}
