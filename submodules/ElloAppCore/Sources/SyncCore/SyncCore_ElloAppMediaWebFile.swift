import Foundation
import Postbox

public enum ElloAppMediaWebFileDecodingError: Error {
    case generic
}

public class ElloAppMediaWebFile: Media, Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    public let resource: ElloAppMediaResource
    public let mimeType: String
    public let size: Int32
    public let attributes: [ElloAppMediaFileAttribute]
    public let peerIds: [PeerId] = []
    
    public var id: MediaId? {
        return nil
    }
    
    public init(resource: ElloAppMediaResource, mimeType: String, size: Int32, attributes: [ElloAppMediaFileAttribute]) {
        self.resource = resource
        self.mimeType = mimeType
        self.size = size
        self.attributes = attributes
    }
    
    public required init(decoder: PostboxDecoder) {
        self.resource = decoder.decodeObjectForKey("r") as! ElloAppMediaResource
        self.mimeType = decoder.decodeStringForKey("mt", orElse: "")
        self.size = decoder.decodeInt32ForKey("s", orElse: 0)
        self.attributes = decoder.decodeObjectArrayForKey("at")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeObject(self.resource, forKey: "r")
        encoder.encodeString(self.mimeType, forKey: "mt")
        encoder.encodeInt32(self.size, forKey: "s")
        encoder.encodeObjectArray(self.attributes, forKey: "at")
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .data)
        let postboxDecoder = PostboxDecoder(buffer: MemoryBuffer(data: data))
        guard let object = postboxDecoder.decodeRootObject() as? ElloAppMediaWebFile else {
            throw ElloAppMediaWebFileDecodingError.generic
        }
        self.resource = object.resource
        self.mimeType = object.mimeType
        self.size = object.size
        self.attributes = object.attributes
    }
    
    public func encode(to encoder: Encoder) throws {
        let postboxEncoder = PostboxEncoder()
        postboxEncoder.encodeRootObject(self)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(postboxEncoder.makeData(), forKey: .data)
    }
    
    public func isEqual(to other: Media) -> Bool {
        guard let other = other as? ElloAppMediaWebFile else {
            return false
        }
        
        return self == other
    }
    
    public static func ==(lhs: ElloAppMediaWebFile, rhs: ElloAppMediaWebFile) -> Bool {
        if !lhs.resource.isEqual(to: rhs.resource) {
            return false
        }
        if lhs.size != rhs.size {
            return false
        }
        if lhs.mimeType != rhs.mimeType {
            return false
        }
        return true
    }
    
    public func isSemanticallyEqual(to other: Media) -> Bool {
        return self.isEqual(to: other)
    }
}
