import Postbox
import Foundation

public enum ElloAppChannelParticipationStatus {
    case member
    case left
    case kicked
    
    fileprivate var rawValue: Int32 {
        switch self {
            case .member:
                return 0
            case .left:
                return 1
            case .kicked:
                return 2
        }
    }
    
    fileprivate init(rawValue: Int32) {
        switch rawValue {
            case 0:
                self = .member
            case 1:
                self = .left
            case 2:
                self = .kicked
            default:
                self = .left
        }
    }
}

public struct ElloAppChannelBroadcastFlags: OptionSet {
    public var rawValue: Int32
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let messagesShouldHaveSignatures = ElloAppChannelBroadcastFlags(rawValue: 1 << 0)
    public static let hasDiscussionGroup = ElloAppChannelBroadcastFlags(rawValue: 1 << 1)
}

public struct ElloAppChannelBroadcastInfo: Equatable {
    public let flags: ElloAppChannelBroadcastFlags
    public init(flags: ElloAppChannelBroadcastFlags) {
        self.flags = flags
    }
    
    public static func ==(lhs: ElloAppChannelBroadcastInfo, rhs: ElloAppChannelBroadcastInfo) -> Bool {
        return lhs.flags == rhs.flags
    }
}

public struct ElloAppChannelGroupFlags: OptionSet {
    public var rawValue: Int32
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    public static let slowModeEnabled = ElloAppChannelGroupFlags(rawValue: 1 << 0)
}

public struct ElloAppChannelGroupInfo: Equatable {
    public let flags: ElloAppChannelGroupFlags
    
    public init(flags: ElloAppChannelGroupFlags) {
        self.flags = flags
    }

    public static func ==(lhs: ElloAppChannelGroupInfo, rhs: ElloAppChannelGroupInfo) -> Bool {
        return lhs.flags == rhs.flags
    }
}

public enum ElloAppChannelInfo: Equatable {
    case broadcast(ElloAppChannelBroadcastInfo)
    case group(ElloAppChannelGroupInfo)
    
    public static func ==(lhs: ElloAppChannelInfo, rhs: ElloAppChannelInfo) -> Bool {
        switch lhs {
            case let .broadcast(lhsInfo):
                switch rhs {
                    case .broadcast(lhsInfo):
                        return true
                    default:
                        return false
                }
            case let .group(lhsInfo):
                switch rhs {
                    case .group(lhsInfo):
                        return true
                    default:
                        return false
                }
        }
    }
    
    fileprivate func encode(encoder: PostboxEncoder) {
        switch self {
            case let .broadcast(info):
                encoder.encodeInt32(0, forKey: "i.t")
                encoder.encodeInt32(info.flags.rawValue, forKey: "i.f")
            case let .group(info):
                encoder.encodeInt32(1, forKey: "i.t")
                encoder.encodeInt32(info.flags.rawValue, forKey: "i.f")
        }
    }
    
    fileprivate static func decode(decoder: PostboxDecoder) -> ElloAppChannelInfo {
        let type: Int32 = decoder.decodeInt32ForKey("i.t", orElse: 0)
        if type == 0 {
            return .broadcast(ElloAppChannelBroadcastInfo(flags: ElloAppChannelBroadcastFlags(rawValue: decoder.decodeInt32ForKey("i.f", orElse: 0))))
        } else {
            return .group(ElloAppChannelGroupInfo(flags: ElloAppChannelGroupFlags(rawValue: decoder.decodeInt32ForKey("i.f", orElse: 0))))
        }
    }
}

public struct ElloAppChannelFlags: OptionSet {
    public var rawValue: Int32
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let isVerified = ElloAppChannelFlags(rawValue: 1 << 0)
    public static let isCreator = ElloAppChannelFlags(rawValue: 1 << 1)
    public static let isScam = ElloAppChannelFlags(rawValue: 1 << 2)
    public static let hasGeo = ElloAppChannelFlags(rawValue: 1 << 3)
    public static let hasVoiceChat = ElloAppChannelFlags(rawValue: 1 << 4)
    public static let hasActiveVoiceChat = ElloAppChannelFlags(rawValue: 1 << 5)
    public static let isFake = ElloAppChannelFlags(rawValue: 1 << 6)
    public static let isGigagroup = ElloAppChannelFlags(rawValue: 1 << 7)
    public static let copyProtectionEnabled = ElloAppChannelFlags(rawValue: 1 << 8)
    public static let joinToSend = ElloAppChannelFlags(rawValue: 1 << 9)
    public static let requestToJoin = ElloAppChannelFlags(rawValue: 1 << 10)
}

public final class ElloAppChannel: Peer, Equatable {
    public let id: PeerId
    public let accessHash: ElloAppPeerAccessHash?
    public let title: String
    public let description: String?
    public let username: String?
    public let photo: [ElloAppMediaImageRepresentation]
    public let creationDate: Int32
    public let version: Int32
    public let participationStatus: ElloAppChannelParticipationStatus
    public let info: ElloAppChannelInfo
    public let flags: ElloAppChannelFlags
    public let restrictionInfo: PeerAccessRestrictionInfo?
    public let adminRights: ElloAppChatAdminRights?
    public let bannedRights: ElloAppChatBannedRights?
    public let defaultBannedRights: ElloAppChatBannedRights?
    public let payType: ElloAppChannelPayType
    public let cost: Double?
    public let isAdult: Bool
    public let startDate: Int64?
    public let endDate: Int64?
    
    public var indexName: PeerIndexNameRepresentation {
        return .title(title: self.title, description: self.description ?? "", addressName: self.username)
    }
    
    public var associatedMediaIds: [MediaId]? { return nil }
    
    public let associatedPeerId: PeerId? = nil
    public let notificationSettingsPeerId: PeerId? = nil
    
    public var timeoutAttribute: UInt32? { return nil }
    
    
    public init(id: PeerId, accessHash: ElloAppPeerAccessHash?, title: String, description: String? = nil, username: String?, photo: [ElloAppMediaImageRepresentation], creationDate: Int32, version: Int32, participationStatus: ElloAppChannelParticipationStatus, info: ElloAppChannelInfo, flags: ElloAppChannelFlags, restrictionInfo: PeerAccessRestrictionInfo?, adminRights: ElloAppChatAdminRights?, bannedRights: ElloAppChatBannedRights?, defaultBannedRights: ElloAppChatBannedRights?, payType: ElloAppChannelPayType, cost: Double?, isAdult: Bool, startDate: Int64?, endDate: Int64?) {
        self.id = id
        self.accessHash = accessHash
        self.title = title
        self.description = description
        self.username = username
        self.photo = photo
        self.creationDate = creationDate
        self.version = version
        self.participationStatus = participationStatus
        self.info = info
        self.flags = flags
        self.restrictionInfo = restrictionInfo
        self.adminRights = adminRights
        self.bannedRights = bannedRights
        self.defaultBannedRights = defaultBannedRights
        self.payType = payType
        self.cost = cost
        self.isAdult = isAdult
        // Convert milisecond to seconds
        self.startDate = startDate.map { $0 / 1000 }
        self.endDate = endDate.map { $0 / 1000 }
    }
    
    public init(decoder: PostboxDecoder) {
        id = PeerId(decoder.decodeInt64ForKey("i", orElse: 0))
        let accessHash = decoder.decodeOptionalInt64ForKey("ah")
        let accessHashType = decoder.decodeInt32ForKey("aht", orElse: 0)
        if let accessHash {
            if accessHashType == 0 {
                self.accessHash = .personal(accessHash)
            } else {
                self.accessHash = .genericPublic(accessHash)
            }
        } else {
            self.accessHash = nil
        }
        title = decoder.decodeStringForKey("t", orElse: "")
        description = decoder.decodeOptionalStringForKey("a")
        username = decoder.decodeOptionalStringForKey("un")
        photo = decoder.decodeObjectArrayForKey("ph")
        creationDate = decoder.decodeInt32ForKey("d", orElse: 0)
        version = decoder.decodeInt32ForKey("v", orElse: 0)
        participationStatus = ElloAppChannelParticipationStatus(rawValue: decoder.decodeInt32ForKey("ps", orElse: 0))
        info = ElloAppChannelInfo.decode(decoder: decoder)
        flags = ElloAppChannelFlags(rawValue: decoder.decodeInt32ForKey("fl", orElse: 0))
        restrictionInfo = decoder.decodeObjectForKey("ri") as? PeerAccessRestrictionInfo
        adminRights = decoder.decodeObjectForKey("ar", decoder: { ElloAppChatAdminRights(decoder: $0) }) as? ElloAppChatAdminRights
        bannedRights = decoder.decodeObjectForKey("br", decoder: { ElloAppChatBannedRights(decoder: $0) }) as? ElloAppChatBannedRights
        defaultBannedRights = decoder.decodeObjectForKey("dbr", decoder: { ElloAppChatBannedRights(decoder: $0) }) as? ElloAppChatBannedRights
        payType = ElloAppChannelPayType(rawValue: decoder.decodeInt32ForKey("pt", orElse: 0))
        cost = decoder.decodeOptionalDoubleForKey("c")
        isAdult = decoder.decodeBoolForKey("ia", orElse: false)
        startDate = decoder.decodeOptionalInt64ForKey("sd")
        endDate = decoder.decodeOptionalInt64ForKey("ed")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt64(self.id.toInt64(), forKey: "i")
        if let accessHash = self.accessHash {
            switch accessHash {
            case let .personal(value):
                encoder.encodeInt64(value, forKey: "ah")
                encoder.encodeInt32(0, forKey: "aht")
            case let .genericPublic(value):
                encoder.encodeInt64(value, forKey: "ah")
                encoder.encodeInt32(1, forKey: "aht")
            }
        } else {
            encoder.encodeNil(forKey: "ah")
        }
        encoder.encodeString(self.title, forKey: "t")
        if let username = self.username {
            encoder.encodeString(username, forKey: "un")
        } else {
            encoder.encodeNil(forKey: "un")
        }
        encoder.encodeObjectArray(self.photo, forKey: "ph")
        encoder.encodeInt32(self.creationDate, forKey: "d")
        encoder.encodeInt32(self.version, forKey: "v")
        encoder.encodeInt32(self.participationStatus.rawValue, forKey: "ps")
        self.info.encode(encoder: encoder)
        encoder.encodeInt32(self.flags.rawValue, forKey: "fl")
        if let restrictionInfo = self.restrictionInfo {
            encoder.encodeObject(restrictionInfo, forKey: "ri")
        } else {
            encoder.encodeNil(forKey: "ri")
        }
        if let adminRights = self.adminRights {
            encoder.encodeObject(adminRights, forKey: "ar")
        } else {
            encoder.encodeNil(forKey: "ar")
        }
        if let bannedRights = self.bannedRights {
            encoder.encodeObject(bannedRights, forKey: "br")
        } else {
            encoder.encodeNil(forKey: "br")
        }
        if let defaultBannedRights = self.defaultBannedRights {
            encoder.encodeObject(defaultBannedRights, forKey: "dbr")
        } else {
            encoder.encodeNil(forKey: "dbr")
        }
        encoder.encodeInt32(payType.rawValue, forKey: "pt")
        if let cost {
            encoder.encodeDouble(cost, forKey: "c")
        } else {
            encoder.encodeNil(forKey: "c")
        }
        encoder.encodeBool(isAdult, forKey: "ia")
        if let startDate {
            encoder.encodeInt64(startDate, forKey: "sd")
        } else {
            encoder.encodeNil(forKey: "sd")
        }
        if let endDate {
            encoder.encodeInt64(endDate, forKey: "ed")
        } else {
            encoder.encodeNil(forKey: "ed")
        }
    }
    
    public func isEqual(_ other: Peer) -> Bool {
        guard let other = other as? ElloAppChannel else {
            return false
        }
        
        return self == other
    }

    public static func ==(lhs: ElloAppChannel, rhs: ElloAppChannel) -> Bool {
        if lhs.id != rhs.id || lhs.accessHash != rhs.accessHash || lhs.title != rhs.title || lhs.username != rhs.username || lhs.photo != rhs.photo {
            return false
        }

        if lhs.creationDate != rhs.creationDate || lhs.version != rhs.version || lhs.participationStatus != rhs.participationStatus {
            return false
        }

        if lhs.info != rhs.info || lhs.flags != rhs.flags || lhs.restrictionInfo != rhs.restrictionInfo {
            return false
        }

        if lhs.adminRights != rhs.adminRights {
            return false
        }

        if lhs.bannedRights != rhs.bannedRights {
            return false
        }

        if lhs.defaultBannedRights != rhs.defaultBannedRights {
            return false
        }
        
        if lhs.payType != rhs.payType {
            return false
        }
        
        if lhs.cost != rhs.cost {
            return false
        }
        
        if lhs.isAdult != rhs.isAdult {
            return false
        }
        
        if lhs.startDate != rhs.startDate {
            return false
        }
        
        if lhs.endDate != rhs.endDate {
            return false
        }

        return true
    }
    
    public func withDescription(_ description: String?) -> ElloAppChannel {
        ElloAppChannel(id: id, accessHash: accessHash, title: title, description: description, username: addressName, photo: photo, creationDate: creationDate, version: version, participationStatus: participationStatus, info: info, flags: flags, restrictionInfo: restrictionInfo, adminRights: adminRights, bannedRights: bannedRights, defaultBannedRights: defaultBannedRights, payType: payType, cost: cost, isAdult: isAdult, startDate: startDate, endDate: endDate)
    }
    
    public func withUpdatedAddressName(_ addressName: String?) -> ElloAppChannel {
        ElloAppChannel(id: id, accessHash: accessHash, title: title, description: description, username: addressName, photo: photo, creationDate: creationDate, version: version, participationStatus: participationStatus, info: info, flags: flags, restrictionInfo: restrictionInfo, adminRights: adminRights, bannedRights: bannedRights, defaultBannedRights: defaultBannedRights, payType: payType, cost: cost, isAdult: isAdult, startDate: startDate, endDate: endDate)
    }
    
    public func withUpdatedDefaultBannedRights(_ defaultBannedRights: ElloAppChatBannedRights?) -> ElloAppChannel {
        ElloAppChannel(id: id, accessHash: accessHash, title: title, description: description, username: username, photo: photo, creationDate: creationDate, version: version, participationStatus: participationStatus, info: info, flags: flags, restrictionInfo: restrictionInfo, adminRights: adminRights, bannedRights: bannedRights, defaultBannedRights: defaultBannedRights, payType: payType, cost: cost, isAdult: isAdult, startDate: startDate, endDate: endDate)
    }
    
    public func withUpdatedFlags(_ flags: ElloAppChannelFlags) -> ElloAppChannel {
        ElloAppChannel(id: id, accessHash: accessHash, title: title, description: description, username: username, photo: photo, creationDate: creationDate, version: version, participationStatus: participationStatus, info: info, flags: flags, restrictionInfo: restrictionInfo, adminRights: adminRights, bannedRights: bannedRights, defaultBannedRights: defaultBannedRights, payType: payType, cost: cost, isAdult: isAdult, startDate: startDate, endDate: endDate)
    }
}
