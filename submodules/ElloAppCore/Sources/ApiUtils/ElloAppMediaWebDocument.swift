import Foundation
import Postbox
import ElloAppApi


extension ElloAppMediaWebFile {
    convenience init(_ document: Api.WebDocument) {
        switch document {
            case let .webDocument(url, accessHash, size, mimeType, attributes):
                self.init(resource: WebFileReferenceMediaResource(url: url, size: Int64(size), accessHash: accessHash), mimeType: mimeType, size: size, attributes: elloappMediaFileAttributesFromApiAttributes(attributes))
            case let .webDocumentNoProxy(url, size, mimeType, attributes):
                self.init(resource: HttpReferenceMediaResource(url: url, size: Int64(size)), mimeType: mimeType, size: size, attributes: elloappMediaFileAttributesFromApiAttributes(attributes))
        }
    }
}
