import Foundation
import Postbox
import ElloAppApi


protocol ElloAppCloudMediaResource: ElloAppMediaResource {
    func apiInputLocation(fileReference: Data?) -> Api.InputFileLocation?
}

public func extractMediaResourceDebugInfo(resource: MediaResource) -> String? {
    if let resource = resource as? ElloAppCloudMediaResource {
        guard let inputLocation = resource.apiInputLocation(fileReference: nil) else {
            return nil
        }
        return String(describing: inputLocation)
    } else {
        return nil
    }
}

public protocol ElloAppMultipartFetchableResource: ElloAppMediaResource {
    var datacenterId: Int { get }
}

public protocol ElloAppCloudMediaResourceWithFileReference {
    var fileReference: Data? { get }
}

extension CloudFileMediaResource: ElloAppCloudMediaResource, ElloAppMultipartFetchableResource, ElloAppCloudMediaResourceWithFileReference {
    func apiInputLocation(fileReference: Data?) -> Api.InputFileLocation? {
        return Api.InputFileLocation.inputFileLocation(volumeId: self.volumeId, localId: self.localId, secret: self.secret, fileReference: Buffer(data: fileReference ?? Data()))
    }
}

extension CloudPhotoSizeMediaResource: ElloAppCloudMediaResource, ElloAppMultipartFetchableResource, ElloAppCloudMediaResourceWithFileReference {
    func apiInputLocation(fileReference: Data?) -> Api.InputFileLocation? {
        return Api.InputFileLocation.inputPhotoFileLocation(id: self.photoId, accessHash: self.accessHash, fileReference: Buffer(data: fileReference ?? Data()), thumbSize: self.sizeSpec)
    }
}

extension CloudDocumentSizeMediaResource: ElloAppCloudMediaResource, ElloAppMultipartFetchableResource, ElloAppCloudMediaResourceWithFileReference {
    func apiInputLocation(fileReference: Data?) -> Api.InputFileLocation? {
        return Api.InputFileLocation.inputDocumentFileLocation(id: self.documentId, accessHash: self.accessHash, fileReference: Buffer(data: fileReference ?? Data()), thumbSize: self.sizeSpec)
    }
}

extension CloudPeerPhotoSizeMediaResource: ElloAppMultipartFetchableResource {
    func apiInputLocation(peerReference: PeerReference) -> Api.InputFileLocation? {
        let flags: Int32
        switch self.sizeSpec {
            case .small:
                flags = 0
            case .fullSize:
                flags = 1 << 0
        }
        if let photoId = self.photoId {
            return Api.InputFileLocation.inputPeerPhotoFileLocation(flags: flags, peer: peerReference.inputPeer, photoId: photoId)
        } else {
            return nil
        }
    }
}

extension CloudStickerPackThumbnailMediaResource: ElloAppMultipartFetchableResource {
    func apiInputLocation(packReference: StickerPackReference) -> Api.InputFileLocation? {
        if let thumbVersion = self.thumbVersion {
            return Api.InputFileLocation.inputStickerSetThumb(stickerset: packReference.apiInputStickerSet, thumbVersion: thumbVersion)
        } else {
            return nil
        }
    }
}

extension CloudDocumentMediaResource: ElloAppCloudMediaResource, ElloAppMultipartFetchableResource, ElloAppCloudMediaResourceWithFileReference {
    func apiInputLocation(fileReference: Data?) -> Api.InputFileLocation? {
        return Api.InputFileLocation.inputDocumentFileLocation(id: self.fileId, accessHash: self.accessHash, fileReference: Buffer(data: fileReference ?? Data()), thumbSize: "")
    }
}

extension SecretFileMediaResource: ElloAppCloudMediaResource, ElloAppMultipartFetchableResource {
    func apiInputLocation(fileReference: Data?) -> Api.InputFileLocation? {
        return .inputEncryptedFileLocation(id: self.fileId, accessHash: self.accessHash)
    }
}
