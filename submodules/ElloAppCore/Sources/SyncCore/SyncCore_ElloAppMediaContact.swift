import Postbox

public final class ElloAppMediaContact: Media {
    public let id: MediaId? = nil
    public let firstName: String
    public let lastName: String
    public let username: String
    public let peerId: PeerId?
    public let vCardData: String?
    public let userid: Int64
    
    public let peerIds: [PeerId]
    
    public init(firstName: String, lastName: String, username: String, peerId: PeerId?, vCardData: String?, userid: Int64) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.peerId = peerId
        self.vCardData = vCardData
        if let peerId = peerId {
            self.peerIds = [peerId]
        } else {
            self.peerIds = []
        }
        
        self.userid = userid
    }
    
    public init(decoder: PostboxDecoder) {
        self.firstName = decoder.decodeStringForKey("n.f", orElse: "")
        self.lastName = decoder.decodeStringForKey("n.l", orElse: "")
        self.username = decoder.decodeStringForKey("un", orElse: "")
        if let peerIdValue = decoder.decodeOptionalInt64ForKey("p") {
            self.peerId = PeerId(peerIdValue)
            self.peerIds = [PeerId(peerIdValue)]
        } else {
            self.peerId = nil
            self.peerIds = []
        }
        self.vCardData = decoder.decodeOptionalStringForKey("vc")
        self.userid = decoder.decodeInt64ForKey("ui", orElse: 0)
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeString(self.firstName, forKey: "n.f")
        encoder.encodeString(self.lastName, forKey: "n.l")
        encoder.encodeString(self.username, forKey: "un")
        if let peerId = self.peerId {
            encoder.encodeInt64(peerId.toInt64(), forKey: "p")
        }
        
        if let vCardData = self.vCardData {
            encoder.encodeString(vCardData, forKey: "vc")
        } else {
            encoder.encodeNil(forKey: "vc")
        }
        
        encoder.encodeInt64(userid, forKey: "ui")
    }
    
    public func isEqual(to other: Media) -> Bool {
        if let other = other as? ElloAppMediaContact {
            if self.id == other.id && self.firstName == other.firstName && self.lastName == other.lastName && self.username == other.username && self.peerId == other.peerId && self.vCardData == other.vCardData && self.peerIds == other.peerIds && self.userid == other.userid {
                return true
            }
        }
        return false
    }
    
    public func isSemanticallyEqual(to other: Media) -> Bool {
        return self.isEqual(to: other)
    }
}
