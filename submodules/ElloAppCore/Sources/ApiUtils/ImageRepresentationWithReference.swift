import Foundation

public struct ImageRepresentationWithReference: Equatable {
    public let representation: ElloAppMediaImageRepresentation
    public let reference: MediaResourceReference
    
    public init(representation: ElloAppMediaImageRepresentation, reference: MediaResourceReference) {
        self.representation = representation
        self.reference = reference
    }
}


public struct VideoRepresentationWithReference: Equatable {
    public let representation: ElloAppMediaImage.VideoRepresentation
    public let reference: MediaResourceReference
    
    public init(representation: ElloAppMediaImage.VideoRepresentation, reference: MediaResourceReference) {
        self.representation = representation
        self.reference = reference
    }
}
