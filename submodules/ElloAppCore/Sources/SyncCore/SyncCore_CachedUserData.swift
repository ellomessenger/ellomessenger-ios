import Foundation
import Postbox
import ElloAppApi

public enum CachedPeerAutoremoveTimeout: Equatable, PostboxCoding {
    public struct Value: Equatable, PostboxCoding {
        public var peerValue: Int32
        
        public init(peerValue: Int32) {
            self.peerValue = peerValue
        }
        
        public init(decoder: PostboxDecoder) {
            self.peerValue = decoder.decodeInt32ForKey("peerValue", orElse: 0)
        }
        
        public func encode(_ encoder: PostboxEncoder) {
            encoder.encodeInt32(self.peerValue, forKey: "peerValue")
        }
        
        public var effectiveValue: Int32 {
            return self.peerValue
        }
    }
    
    case unknown
    case known(Value?)
    
    public init(decoder: PostboxDecoder) {
        switch decoder.decodeInt32ForKey("_v", orElse: 0) {
        case 1:
            self = .known(decoder.decodeObjectForKey("v", decoder: Value.init(decoder:)) as? Value)
        default:
            self = .unknown
        }
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        switch self {
        case .unknown:
            encoder.encodeInt32(0, forKey: "_v")
        case let .known(value):
            encoder.encodeInt32(1, forKey: "_v")
            if let value = value {
                encoder.encodeObject(value, forKey: "v")
            } else {
                encoder.encodeNil(forKey: "v")
            }
        }
    }
}

public struct CachedPremiumGiftOption: Equatable, PostboxCoding {
    public let months: Int32
    public let currency: String
    public let amount: Int64
    public let botUrl: String
    public let storeProductId: String?
    
    public init(months: Int32, currency: String, amount: Int64, botUrl: String, storeProductId: String?) {
        self.months = months
        self.currency = currency
        self.amount = amount
        self.botUrl = botUrl
        self.storeProductId = storeProductId
    }
    
    public init(decoder: PostboxDecoder) {
        self.months = decoder.decodeInt32ForKey("months", orElse: 0)
        self.currency = decoder.decodeStringForKey("currency", orElse: "")
        self.amount = decoder.decodeInt64ForKey("amount", orElse: 0)
        self.botUrl = decoder.decodeStringForKey("botUrl", orElse: "")
        self.storeProductId = decoder.decodeOptionalStringForKey("storeProductId")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.months, forKey: "months")
        encoder.encodeString(self.currency, forKey: "currency")
        encoder.encodeInt64(self.amount, forKey: "amount")
        encoder.encodeString(self.botUrl, forKey: "botUrl")
        if let storeProductId = self.storeProductId {
            encoder.encodeString(storeProductId, forKey: "storeProductId")
        } else {
            encoder.encodeNil(forKey: "storeProductId")
        }
    }
}

public struct PeerEmojiStatus: Equatable, Codable {
    public var fileId: Int64
    public var expirationDate: Int32?
    
    public init(fileId: Int64, expirationDate: Int32?) {
        self.fileId = fileId
        self.expirationDate = expirationDate
    }
}

extension PeerEmojiStatus {
    init?(apiStatus: Api.EmojiStatus) {
        switch apiStatus {
        case let .emojiStatus(documentId):
            self.init(fileId: documentId, expirationDate: nil)
        case let .emojiStatusUntil(documentId, until):
            self.init(fileId: documentId, expirationDate: until)
        case .emojiStatusEmpty:
            return nil
        }
    }
}

public final class CachedUserData: CachedPeerData {
    public let about: String?
    public let botInfo: BotInfo?
    public let email: String?
    public let country: String?
    public let gender: String?
    public let birthday: Int32?
    public let peerStatusSettings: PeerStatusSettings?
    public let pinnedMessageId: MessageId?
    public let isBlocked: Bool
    public let commonGroupCount: Int32
    public let voiceCallsAvailable: Bool
    public let videoCallsAvailable: Bool
    public let callsPrivate: Bool
    public let canPinMessages: Bool
    public let hasScheduledMessages: Bool
    public let autoremoveTimeout: CachedPeerAutoremoveTimeout
    public let themeEmoticon: String?
    public let photo: ElloAppMediaImage?
    public let premiumGiftOptions: [CachedPremiumGiftOption]
    public let voiceMessagesAvailable: Bool
    public let isPublic: Bool
    public let isBusiness: Bool
    public let botDescription: String?
    
    public let peerIds: Set<PeerId>
    public let messageIds: Set<MessageId>
    public let associatedHistoryMessageId: MessageId? = nil
    
    public init() {
        self.about = nil
        self.botInfo = nil
        self.email = nil
        self.country = nil
        self.gender = nil
        self.birthday = nil
        self.peerStatusSettings = nil
        self.pinnedMessageId = nil
        self.isBlocked = false
        self.commonGroupCount = 0
        self.voiceCallsAvailable = true
        self.videoCallsAvailable = true
        self.callsPrivate = false
        self.canPinMessages = false
        self.hasScheduledMessages = false
        self.autoremoveTimeout = .unknown
        self.themeEmoticon = nil
        self.photo = nil
        self.premiumGiftOptions = []
        self.voiceMessagesAvailable = true
        self.peerIds = Set()
        self.messageIds = Set()
        self.isPublic = true
        self.isBusiness = false
        self.botDescription = nil
    }
    
    public init(about: String?, botInfo: BotInfo?, email: String?, country: String?, gender: String?, birthday: Int32?, peerStatusSettings: PeerStatusSettings?, pinnedMessageId: MessageId?, isBlocked: Bool, commonGroupCount: Int32, voiceCallsAvailable: Bool, videoCallsAvailable: Bool, callsPrivate: Bool, canPinMessages: Bool, hasScheduledMessages: Bool, autoremoveTimeout: CachedPeerAutoremoveTimeout, themeEmoticon: String?, photo: ElloAppMediaImage?, premiumGiftOptions: [CachedPremiumGiftOption], voiceMessagesAvailable: Bool, isPublic: Bool, isBusiness: Bool, botDescription: String?) {
        self.about = about
        self.botInfo = botInfo
        self.email = email
        self.country = country
        self.gender = gender
        self.birthday = birthday
        self.peerStatusSettings = peerStatusSettings
        self.pinnedMessageId = pinnedMessageId
        self.isBlocked = isBlocked
        self.commonGroupCount = commonGroupCount
        self.voiceCallsAvailable = voiceCallsAvailable
        self.videoCallsAvailable = videoCallsAvailable
        self.callsPrivate = callsPrivate
        self.canPinMessages = canPinMessages
        self.hasScheduledMessages = hasScheduledMessages
        self.autoremoveTimeout = autoremoveTimeout
        self.themeEmoticon = themeEmoticon
        self.photo = photo
        self.premiumGiftOptions = premiumGiftOptions
        self.voiceMessagesAvailable = voiceMessagesAvailable
        self.isPublic = isPublic
        self.isBusiness = isBusiness
        self.botDescription = botDescription
        
        self.peerIds = Set<PeerId>()
        
        var messageIds = Set<MessageId>()
        if let pinnedMessageId = self.pinnedMessageId {
            messageIds.insert(pinnedMessageId)
        }
        self.messageIds = messageIds
    }
    
    public init(decoder: PostboxDecoder) {
        self.about = decoder.decodeOptionalStringForKey("a")
        self.botInfo = decoder.decodeObjectForKey("bi") as? BotInfo
        self.email = decoder.decodeOptionalStringForKey("email")
        self.country = decoder.decodeOptionalStringForKey("country")
        self.gender = decoder.decodeOptionalStringForKey("gender")
        self.birthday = decoder.decodeOptionalInt32ForKey("birthday")
        if let legacyValue = decoder.decodeOptionalInt32ForKey("pcs") {
            self.peerStatusSettings = PeerStatusSettings(flags: PeerStatusSettings.Flags(rawValue: legacyValue), geoDistance: nil)
        } else if let peerStatusSettings = decoder.decodeObjectForKey("pss", decoder: { PeerStatusSettings(decoder: $0) }) as? PeerStatusSettings {
            self.peerStatusSettings = peerStatusSettings
        } else {
            self.peerStatusSettings = nil
        }
        if let pinnedMessagePeerId = decoder.decodeOptionalInt64ForKey("pm.p"), let pinnedMessageNamespace = decoder.decodeOptionalInt32ForKey("pm.n"), let pinnedMessageId = decoder.decodeOptionalInt32ForKey("pm.i") {
            self.pinnedMessageId = MessageId(peerId: PeerId(pinnedMessagePeerId), namespace: pinnedMessageNamespace, id: pinnedMessageId)
        } else {
            self.pinnedMessageId = nil
        }
        self.isBlocked = decoder.decodeInt32ForKey("b", orElse: 0) != 0
        self.commonGroupCount = decoder.decodeInt32ForKey("cg", orElse: 0)
        self.voiceCallsAvailable = decoder.decodeInt32ForKey("ca", orElse: 0) != 0
        self.videoCallsAvailable = decoder.decodeInt32ForKey("vca", orElse: 0) != 0
        self.callsPrivate = decoder.decodeInt32ForKey("cp", orElse: 0) != 0
        self.canPinMessages = decoder.decodeInt32ForKey("cpm", orElse: 0) != 0
        self.hasScheduledMessages = decoder.decodeBoolForKey("hsm", orElse: false)
        self.autoremoveTimeout = decoder.decodeObjectForKey("artv", decoder: CachedPeerAutoremoveTimeout.init(decoder:)) as? CachedPeerAutoremoveTimeout ?? .unknown
        self.themeEmoticon = decoder.decodeOptionalStringForKey("te")
        
        if let photo = decoder.decodeObjectForKey("ph", decoder: { ElloAppMediaImage(decoder: $0) }) as? ElloAppMediaImage {
            self.photo = photo
        } else {
            self.photo = nil
        }
                
        self.premiumGiftOptions = decoder.decodeObjectArrayWithDecoderForKey("pgo") as [CachedPremiumGiftOption]
        self.voiceMessagesAvailable = decoder.decodeInt32ForKey("vma", orElse: 0) != 0
        
        self.peerIds = Set<PeerId>()
        
        var messageIds = Set<MessageId>()
        if let pinnedMessageId = self.pinnedMessageId {
            messageIds.insert(pinnedMessageId)
        }
        self.messageIds = messageIds
        self.isPublic = decoder.decodeInt32ForKey("isPublic", orElse: 0) != 0
        self.isBusiness = decoder.decodeInt32ForKey("isBusiness", orElse: 0) != 0
        self.botDescription = decoder.decodeOptionalStringForKey("botDescription")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        if let about = self.about {
            encoder.encodeString(about, forKey: "a")
        } else {
            encoder.encodeNil(forKey: "a")
        }
        if let botInfo = self.botInfo {
            encoder.encodeObject(botInfo, forKey: "bi")
        } else {
            encoder.encodeNil(forKey: "bi")
        }
        if let email = self.email {
            encoder.encodeString(email, forKey: "email")
        } else {
            encoder.encodeNil(forKey: "email")
        }
        if let country = self.country {
            encoder.encodeString(country, forKey: "country")
        } else {
            encoder.encodeNil(forKey: "country")
        }
        if let gender = self.gender {
            encoder.encodeString(gender, forKey: "gender")
        } else {
            encoder.encodeNil(forKey: "gender")
        }
        if let birthday = self.birthday {
            encoder.encodeInt32(birthday, forKey: "birthday")
        } else {
            encoder.encodeNil(forKey: "birthday")
        }
        if let peerStatusSettings = self.peerStatusSettings {
            encoder.encodeObject(peerStatusSettings, forKey: "pss")
        } else {
            encoder.encodeNil(forKey: "pss")
        }
        if let pinnedMessageId = self.pinnedMessageId {
            encoder.encodeInt64(pinnedMessageId.peerId.toInt64(), forKey: "pm.p")
            encoder.encodeInt32(pinnedMessageId.namespace, forKey: "pm.n")
            encoder.encodeInt32(pinnedMessageId.id, forKey: "pm.i")
        } else {
            encoder.encodeNil(forKey: "pm.p")
            encoder.encodeNil(forKey: "pm.n")
            encoder.encodeNil(forKey: "pm.i")
        }
        encoder.encodeInt32(self.isBlocked ? 1 : 0, forKey: "b")
        encoder.encodeInt32(self.commonGroupCount, forKey: "cg")
        encoder.encodeInt32(self.voiceCallsAvailable ? 1 : 0, forKey: "ca")
        encoder.encodeInt32(self.videoCallsAvailable ? 1 : 0, forKey: "vca")
        encoder.encodeInt32(self.callsPrivate ? 1 : 0, forKey: "cp")
        encoder.encodeInt32(self.canPinMessages ? 1 : 0, forKey: "cpm")
        encoder.encodeBool(self.hasScheduledMessages, forKey: "hsm")
        encoder.encodeObject(self.autoremoveTimeout, forKey: "artv")
        if let themeEmoticon = self.themeEmoticon, !themeEmoticon.isEmpty {
            encoder.encodeString(themeEmoticon, forKey: "te")
        } else {
            encoder.encodeNil(forKey: "te")
        }
        
        if let photo = self.photo {
            encoder.encodeObject(photo, forKey: "ph")
        } else {
            encoder.encodeNil(forKey: "ph")
        }
        
        encoder.encodeObjectArray(self.premiumGiftOptions, forKey: "pgo")
        encoder.encodeInt32(self.voiceMessagesAvailable ? 1 : 0, forKey: "vma")
        
        encoder.encodeInt32(self.isPublic ? 1 : 0, forKey: "isPublic")
        encoder.encodeInt32(self.isBusiness ? 1 : 0, forKey: "isBusiness")
        if let botDescription = self.botDescription {
            encoder.encodeString(botDescription, forKey: "botDescription")
        } else {
            encoder.encodeNil(forKey: "botDescription")
        }
    }
    
    public func isEqual(to: CachedPeerData) -> Bool {
        guard let other = to as? CachedUserData else {
            return false
        }
        
        if other.pinnedMessageId != self.pinnedMessageId {
            return false
        }
        if other.canPinMessages != self.canPinMessages {
            return false
        }
        
        return other.about == self.about && other.botInfo == self.botInfo && self.peerStatusSettings == other.peerStatusSettings && self.isBlocked == other.isBlocked && self.commonGroupCount == other.commonGroupCount && self.voiceCallsAvailable == other.voiceCallsAvailable && self.videoCallsAvailable == other.videoCallsAvailable && self.callsPrivate == other.callsPrivate && self.hasScheduledMessages == other.hasScheduledMessages && self.autoremoveTimeout == other.autoremoveTimeout && self.themeEmoticon == other.themeEmoticon && self.photo == other.photo && self.premiumGiftOptions == other.premiumGiftOptions && self.voiceMessagesAvailable == other.voiceMessagesAvailable && self.isPublic == other.isPublic && self.isBusiness == other.isBusiness
    }
    
    public func withUpdatedAbout(_ about: String?) -> CachedUserData {
        return CachedUserData(about: about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedBotInfo(_ botInfo: BotInfo?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedPeerStatusSettings(_ peerStatusSettings: PeerStatusSettings) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedPinnedMessageId(_ pinnedMessageId: MessageId?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedIsBlocked(_ isBlocked: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedCommonGroupCount(_ commonGroupCount: Int32) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedVoiceCallsAvailable(_ voiceCallsAvailable: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedVideoCallsAvailable(_ videoCallsAvailable: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedCallsPrivate(_ callsPrivate: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedCanPinMessages(_ canPinMessages: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedHasScheduledMessages(_ hasScheduledMessages: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedAutoremoveTimeout(_ autoremoveTimeout: CachedPeerAutoremoveTimeout) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedThemeEmoticon(_ themeEmoticon: String?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedPhoto(_ photo: ElloAppMediaImage?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedPremiumGiftOptions(_ premiumGiftOptions: [CachedPremiumGiftOption]) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withUpdatedVoiceMessagesAvailable(_ voiceMessagesAvailable: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withEmail(_ email: String?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withCounty(_ country: String?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withGender(_ gender: String?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
    }
    
    public func withBirthday(_ birthday: Int32?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
        
    }
    
    public func withIsPublic(_ isPublic: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: isPublic, isBusiness: self.isBusiness, botDescription: self.botDescription)
        
    }
    
    public func withIsBusiness(_ isBusiness: Bool) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: isBusiness, botDescription: self.botDescription)
        
    }
    
    public func withBotDescription(_ botDescription: String?) -> CachedUserData {
        return CachedUserData(about: self.about, botInfo: self.botInfo, email: self.email, country: self.country, gender: self.gender, birthday: self.birthday, peerStatusSettings: self.peerStatusSettings, pinnedMessageId: self.pinnedMessageId, isBlocked: self.isBlocked, commonGroupCount: self.commonGroupCount, voiceCallsAvailable: self.voiceCallsAvailable, videoCallsAvailable: self.videoCallsAvailable, callsPrivate: self.callsPrivate, canPinMessages: self.canPinMessages, hasScheduledMessages: self.hasScheduledMessages, autoremoveTimeout: self.autoremoveTimeout, themeEmoticon: self.themeEmoticon, photo: self.photo, premiumGiftOptions: self.premiumGiftOptions, voiceMessagesAvailable: self.voiceMessagesAvailable, isPublic: self.isPublic, isBusiness: self.isBusiness, botDescription: botDescription)
        
    }
}
