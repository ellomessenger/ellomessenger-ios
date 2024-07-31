import Foundation
import Postbox


// Incuding at least one Objective-C class in a swift file ensures that it doesn't get stripped by the linker
private final class LinkHelperClass: NSObject {
}

public func canSendMessagesToPeer(_ peer: Peer) -> Bool {
    if let peer = peer as? ElloAppUser, peer.username == "replies" {
        return false
    } else if peer is ElloAppUser || peer is ElloAppGroup {
        return !peer.isDeleted
    } else if let peer = peer as? ElloAppSecretChat {
        return peer.embeddedState == .active
    } else if let peer = peer as? ElloAppChannel {
        return peer.hasPermission(.sendMessages)
    } else {
        return false
    }
}
