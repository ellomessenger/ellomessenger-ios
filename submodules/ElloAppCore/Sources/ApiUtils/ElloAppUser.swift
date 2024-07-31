import Foundation
import Postbox
import ElloAppApi


func parsedElloAppProfilePhoto(_ photo: Api.UserProfilePhoto) -> [ElloAppMediaImageRepresentation] {
    var representations: [ElloAppMediaImageRepresentation] = []
    switch photo {
        case let .userProfilePhoto(flags, id, strippedThumb, dcId):
            let _ = (flags & (1 << 0)) != 0
            
            let smallResource: ElloAppMediaResource
            let fullSizeResource: ElloAppMediaResource

            smallResource = CloudPeerPhotoSizeMediaResource(datacenterId: dcId, photoId: id, sizeSpec: .small, volumeId: nil, localId: nil)
            fullSizeResource = CloudPeerPhotoSizeMediaResource(datacenterId: dcId, photoId: id, sizeSpec: .fullSize, volumeId: nil, localId: nil)

            representations.append(ElloAppMediaImageRepresentation(dimensions: PixelDimensions(width: 80, height: 80), resource: smallResource, progressiveSizes: [], immediateThumbnailData: strippedThumb?.makeData()))
            representations.append(ElloAppMediaImageRepresentation(dimensions: PixelDimensions(width: 640, height: 640), resource: fullSizeResource, progressiveSizes: [], immediateThumbnailData: strippedThumb?.makeData()))
        case .userProfilePhotoEmpty:
            break
    }
    return representations
}

extension ElloAppUser {
    convenience init(user: Api.User) {
        switch user {
        case let .user(flags, id, accessHash, firstName, lastName, username, phone, photo, _, _, email, country, gender, birthday, restrictionReason, botInlinePlaceholder, _, emojiStatus, isBusiness, isPublic, botDescription):
            let representations: [ElloAppMediaImageRepresentation] = photo.flatMap(parsedElloAppProfilePhoto) ?? []
            
            let isMin = (flags & (1 << 20)) != 0
            let accessHashValue = accessHash.flatMap { value -> ElloAppPeerAccessHash in
                if isMin {
                    return .genericPublic(value)
                } else {
                    return .personal(value)
                }
            }
            
            var userFlags: UserInfoFlags = []
            if (flags & (1 << 17)) != 0 {
                userFlags.insert(.isVerified)
            }
            if (flags & (1 << 23)) != 0 {
                userFlags.insert(.isSupport)
            }
            if (flags & (1 << 24)) != 0 {
                userFlags.insert(.isScam)
            }
            if (flags & (1 << 26)) != 0 {
                userFlags.insert(.isFake)
            }
            if (flags & (1 << 28)) != 0 {
                userFlags.insert(.isPremium)
            }

            var botInfo: BotUserInfo?
            if (flags & (1 << 14)) != 0 {
                var botFlags = BotUserInfoFlags()
                if (flags & (1 << 15)) != 0 {
                    botFlags.insert(.hasAccessToChatHistory)
                }
                if (flags & (1 << 16)) == 0 {
                    botFlags.insert(.worksWithGroups)
                }
                if (flags & (1 << 21)) != 0 {
                    botFlags.insert(.requiresGeolocationForInlineRequests)
                }
                if (flags & (1 << 27)) != 0 {
                    botFlags.insert(.canBeAddedToAttachMenu)
                }
                botInfo = BotUserInfo(flags: botFlags, inlinePlaceholder: botInlinePlaceholder)
            }
            
            let restrictionInfo: PeerAccessRestrictionInfo? = restrictionReason.flatMap(PeerAccessRestrictionInfo.init(apiReasons:))
            
            self.init(id: PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(id)), accessHash: accessHashValue, firstName: firstName, lastName: lastName, username: username, phone: phone, photo: representations, botInfo: botInfo, email: email, country: country, gender: gender, birthday: birthday, restrictionInfo: restrictionInfo, flags: userFlags, emojiStatus: emojiStatus.flatMap(PeerEmojiStatus.init(apiStatus:)), isBusiness: isBusiness == .boolTrue, isPublic: isPublic == .boolTrue, botDescription: botDescription)
        case let .userEmpty(id):
            self.init(id: PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(id)), accessHash: nil, firstName: nil, lastName: nil, username: nil, phone: nil, photo: [], botInfo: nil, email: nil, country: nil, gender: nil, birthday: nil, restrictionInfo: nil, flags: [], emojiStatus: nil, isBusiness: false, isPublic: false, botDescription: nil)
        }
    }
    
    static func merge(_ lhs: ElloAppUser?, rhs: Api.User) -> ElloAppUser? {
        switch rhs {
            case let .user(flags, _, rhsAccessHash, _, _, username, _, photo, _, _, email, country, gender, birthday, restrictionReason, botInlinePlaceholder, _, emojiStatus, isBusiness, isPublic, botDescription):
                let isMin = (flags & (1 << 20)) != 0
                if !isMin {
                    return ElloAppUser(user: rhs)
                } else {
                    let elloappPhoto: [ElloAppMediaImageRepresentation]
                    if let photo = photo {
                        elloappPhoto = parsedElloAppProfilePhoto(photo)
                    } else if let currentPhoto = lhs?.photo {
                        elloappPhoto = currentPhoto
                    } else {
                        elloappPhoto = []
                    }

                    if let lhs = lhs {
                        var userFlags: UserInfoFlags = []
                        if (flags & (1 << 17)) != 0 {
                            userFlags.insert(.isVerified)
                        }
                        if (flags & (1 << 23)) != 0 {
                            userFlags.insert(.isSupport)
                        }
                        if (flags & (1 << 24)) != 0 {
                            userFlags.insert(.isScam)
                        }
                        if (flags & Int32(1 << 26)) != 0 {
                            userFlags.insert(.isFake)
                        }
                        if (flags & (1 << 28)) != 0 {
                            userFlags.insert(.isPremium)
                        }
                        
                        var botInfo: BotUserInfo?
                        if (flags & (1 << 14)) != 0 {
                            var botFlags = BotUserInfoFlags()
                            if (flags & (1 << 15)) != 0 {
                                botFlags.insert(.hasAccessToChatHistory)
                            }
                            if (flags & (1 << 16)) == 0 {
                                botFlags.insert(.worksWithGroups)
                            }
                            if (flags & (1 << 21)) != 0 {
                                botFlags.insert(.requiresGeolocationForInlineRequests)
                            }
                            if (flags & (1 << 27)) != 0 {
                                botFlags.insert(.canBeAddedToAttachMenu)
                            }
                            botInfo = BotUserInfo(flags: botFlags, inlinePlaceholder: botInlinePlaceholder)
                        }
                        
                        let restrictionInfo: PeerAccessRestrictionInfo? = restrictionReason.flatMap(PeerAccessRestrictionInfo.init)
                        
                        let rhsAccessHashValue = rhsAccessHash.flatMap { value -> ElloAppPeerAccessHash in
                            if isMin {
                                return .genericPublic(value)
                            } else {
                                return .personal(value)
                            }
                        }
                        
                        let accessHash: ElloAppPeerAccessHash?
                        if let rhsAccessHashValue = rhsAccessHashValue, case .personal = rhsAccessHashValue {
                            accessHash = rhsAccessHashValue
                        } else {
                            accessHash = lhs.accessHash ?? rhsAccessHashValue
                        }
                        
                        return ElloAppUser(id: lhs.id, accessHash: accessHash, firstName: lhs.firstName, lastName: lhs.lastName, username: username, phone: lhs.phone, photo: elloappPhoto, botInfo: botInfo, email: email, country: country, gender: gender, birthday: birthday, restrictionInfo: restrictionInfo, flags: userFlags, emojiStatus: emojiStatus.flatMap(PeerEmojiStatus.init(apiStatus:)), isBusiness: isBusiness == .boolTrue, isPublic: isPublic == .boolTrue, botDescription: botDescription)
                    } else {
                        return ElloAppUser(user: rhs)
                    }
                }
            case .userEmpty:
                return ElloAppUser(user: rhs)
        }
    }
    
    static func merge(lhs: ElloAppUser?, rhs: ElloAppUser) -> ElloAppUser {
        guard let lhs = lhs else {
            return rhs
        }
        if let rhsAccessHash = rhs.accessHash, case .personal = rhsAccessHash {
            return rhs
        } else {
            var userFlags: UserInfoFlags = []
            if rhs.flags.contains(.isVerified) {
                userFlags.insert(.isVerified)
            }
            if rhs.flags.contains(.isSupport) {
                userFlags.insert(.isSupport)
            }
            if rhs.flags.contains(.isScam) {
                userFlags.insert(.isScam)
            }
            if rhs.flags.contains(.isFake) {
                userFlags.insert(.isFake)
            }
            if rhs.flags.contains(.isPremium) {
                userFlags.insert(.isPremium)
            }

            let botInfo: BotUserInfo? = rhs.botInfo
            
            let emojiStatus = rhs.emojiStatus
            
            let restrictionInfo: PeerAccessRestrictionInfo? = rhs.restrictionInfo
            
            let accessHash: ElloAppPeerAccessHash?
            if let rhsAccessHashValue = lhs.accessHash, case .personal = rhsAccessHashValue {
                accessHash = rhsAccessHashValue
            } else {
                accessHash = lhs.accessHash ?? rhs.accessHash
            }
            
            return ElloAppUser(id: lhs.id, accessHash: accessHash, firstName: lhs.firstName, lastName: lhs.lastName, username: rhs.username, phone: lhs.phone, photo: rhs.photo.isEmpty ? lhs.photo : rhs.photo, botInfo: botInfo, email: lhs.email, country: lhs.country, gender: lhs.gender, birthday: lhs.birthday, restrictionInfo: restrictionInfo, flags: userFlags, emojiStatus: emojiStatus, isBusiness: lhs.isBusiness, isPublic: lhs.isPublic, botDescription: lhs.botDescription)
        }
    }
}
