import Postbox

public struct ElloAppChatBannedRightsFlags: OptionSet, Hashable {
    public var rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.rawValue = 0
    }
    
    public static let banReadMessages = ElloAppChatBannedRightsFlags(rawValue: 1 << 0)
    public static let banSendMessages = ElloAppChatBannedRightsFlags(rawValue: 1 << 1)
    public static let banSendMedia = ElloAppChatBannedRightsFlags(rawValue: 1 << 2)
    public static let banSendStickers = ElloAppChatBannedRightsFlags(rawValue: 1 << 3)
    public static let banSendGifs = ElloAppChatBannedRightsFlags(rawValue: 1 << 4)
    public static let banSendGames = ElloAppChatBannedRightsFlags(rawValue: 1 << 5)
    public static let banSendInline = ElloAppChatBannedRightsFlags(rawValue: 1 << 6)
    public static let banEmbedLinks = ElloAppChatBannedRightsFlags(rawValue: 1 << 7)
    public static let banSendPolls = ElloAppChatBannedRightsFlags(rawValue: 1 << 8)
    public static let banChangeInfo = ElloAppChatBannedRightsFlags(rawValue: 1 << 10)
    public static let banAddMembers = ElloAppChatBannedRightsFlags(rawValue: 1 << 15)
    public static let banPinMessages = ElloAppChatBannedRightsFlags(rawValue: 1 << 17)
}

public struct ElloAppChatBannedRights: PostboxCoding, Equatable {
    public let flags: ElloAppChatBannedRightsFlags
    public let untilDate: Int32
    
    public init(flags: ElloAppChatBannedRightsFlags, untilDate: Int32) {
        self.flags = flags
        self.untilDate = untilDate
    }
    
    public init(decoder: PostboxDecoder) {
        self.flags = ElloAppChatBannedRightsFlags(rawValue: decoder.decodeInt32ForKey("f", orElse: 0))
        self.untilDate = decoder.decodeInt32ForKey("d", orElse: 0)
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.flags.rawValue, forKey: "f")
        encoder.encodeInt32(self.untilDate, forKey: "d")
    }
    
    public static func ==(lhs: ElloAppChatBannedRights, rhs: ElloAppChatBannedRights) -> Bool {
        return lhs.flags == rhs.flags && lhs.untilDate == rhs.untilDate
    }
}
