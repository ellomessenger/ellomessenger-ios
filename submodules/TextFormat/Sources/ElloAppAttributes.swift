import Foundation
import Postbox

public final class ElloAppHashtag {
    public let peerName: String?
    public let hashtag: String
    
    public init(peerName: String?, hashtag: String) {
        self.peerName = peerName
        self.hashtag = hashtag
    }
}

public final class ElloAppPeerMention {
    public let peerId: PeerId
    public let mention: String
    
    public init(peerId: PeerId, mention: String) {
        self.peerId = peerId
        self.mention = mention
    }
}

public final class ElloAppTimecode {
    public let time: Double
    public let text: String
    
    public init(time: Double, text: String) {
        self.time = time
        self.text = text
    }
}

public struct ElloAppTextAttributes {
    public static let URL = "UrlAttributeT"
    public static let PeerMention = "ElloAppPeerMention"
    public static let PeerTextMention = "ElloAppPeerTextMention"
    public static let BotCommand = "ElloAppBotCommand"
    public static let Hashtag = "ElloAppHashtag"
    public static let BankCard = "ElloAppBankCard"
    public static let Timecode = "ElloAppTimecode"
    public static let BlockQuote = "ElloAppBlockQuote"
    public static let Pre = "ElloAppPre"
    public static let Spoiler = "ElloAppSpoiler"
}
