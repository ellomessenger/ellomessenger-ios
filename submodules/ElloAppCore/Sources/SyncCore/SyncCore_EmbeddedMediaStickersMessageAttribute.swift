import Foundation
import Postbox

public class EmbeddedMediaStickersMessageAttribute: MessageAttribute {
    public let files: [ElloAppMediaFile]
    
    public init(files: [ElloAppMediaFile]) {
        self.files = files
    }
    
    required public init(decoder: PostboxDecoder) {
        self.files = decoder.decodeObjectArrayWithDecoderForKey("files")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeObjectArray(self.files, forKey: "files")
    }
}
