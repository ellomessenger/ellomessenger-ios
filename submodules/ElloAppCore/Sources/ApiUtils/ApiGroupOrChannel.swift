import Foundation
import Postbox
import ElloAppApi


public func imageRepresentationsForApiChatPhoto(_ photo: Api.ChatPhoto) -> [ElloAppMediaImageRepresentation] {
    var representations: [ElloAppMediaImageRepresentation] = []
    switch photo {
        case let .chatPhoto(_, photoId, strippedThumb, dcId):
            let smallResource: ElloAppMediaResource
            let fullSizeResource: ElloAppMediaResource

            smallResource = CloudPeerPhotoSizeMediaResource(datacenterId: dcId, photoId: photoId, sizeSpec: .small, volumeId: nil, localId: nil)
            fullSizeResource = CloudPeerPhotoSizeMediaResource(datacenterId: dcId, photoId: photoId, sizeSpec: .fullSize, volumeId: nil, localId: nil)

            representations.append(ElloAppMediaImageRepresentation(dimensions: PixelDimensions(width: 80, height: 80), resource: smallResource, progressiveSizes: [], immediateThumbnailData: strippedThumb?.makeData()))
            representations.append(ElloAppMediaImageRepresentation(dimensions: PixelDimensions(width: 640, height: 640), resource: fullSizeResource, progressiveSizes: [], immediateThumbnailData: strippedThumb?.makeData()))
        case .chatPhotoEmpty:
            break
    }
    return representations
}

public func parseElloAppGroupOrChannel(chat: Api.Chat) -> Peer? {
    switch chat {
    case let .chat(flags, id, title, userName, photo, participantsCount, date, version, migratedTo, adminRights, defaultBannedRights):
        let left = (flags & ((1 << 1) | (1 << 2))) != 0
        var migrationReference: ElloAppGroupToChannelMigrationReference?
        if let migratedTo = migratedTo {
            switch migratedTo {
            case let .inputChannel(channelId, accessHash):
                migrationReference = ElloAppGroupToChannelMigrationReference(peerId: PeerId(namespace: Namespaces.Peer.CloudChannel, id: PeerId.Id._internalFromInt64Value(channelId)), accessHash: accessHash)
            case .inputChannelEmpty:
                break
            case .inputChannelFromMessage:
                break
            }
        }
        var groupFlags = ElloAppGroupFlags()
        var role: ElloAppGroupRole = .member
        if (flags & (1 << 0)) != 0 {
            role = .creator(rank: nil)
        } else if let adminRights = adminRights {
            role = .admin(ElloAppChatAdminRights(apiAdminRights: adminRights) ?? ElloAppChatAdminRights(rights: []), rank: nil)
        }
        if (flags & (1 << 5)) != 0 {
            groupFlags.insert(.deactivated)
        }
        if (flags & Int32(1 << 23)) != 0 {
            groupFlags.insert(.hasVoiceChat)
        }
        if (flags & Int32(1 << 24)) != 0 {
            groupFlags.insert(.hasActiveVoiceChat)
        }
        if (flags & Int32(1 << 25)) != 0 {
            groupFlags.insert(.copyProtectionEnabled)
        }
        // TODO: Check is need description
        return ElloAppGroup(id: PeerId(namespace: Namespaces.Peer.CloudGroup, id: PeerId.Id._internalFromInt64Value(id)), title: title, userName: userName, description: nil, photo: imageRepresentationsForApiChatPhoto(photo), participantCount: Int(participantsCount), role: role, membership: left ? .Left : .Member, flags: groupFlags, defaultBannedRights: defaultBannedRights.flatMap(ElloAppChatBannedRights.init(apiBannedRights:)), migrationReference: migrationReference, creationDate: date, version: Int(version))
    case let .chatEmpty(id):
        return ElloAppGroup(id: PeerId(namespace: Namespaces.Peer.CloudGroup, id: PeerId.Id._internalFromInt64Value(id)), title: "", userName: nil, description: nil, photo: [], participantCount: 0, role: .member, membership: .Removed, flags: [], defaultBannedRights: nil, migrationReference: nil, creationDate: 0, version: 0)
    case let .chatForbidden(id, title):
        return ElloAppGroup(id: PeerId(namespace: Namespaces.Peer.CloudGroup, id: PeerId.Id._internalFromInt64Value(id)), title: title, userName: nil, description: nil, photo: [], participantCount: 0, role: .member, membership: .Removed, flags: [], defaultBannedRights: nil, migrationReference: nil, creationDate: 0, version: 0)
    case let .channel(flags, id, accessHash, title, username, photo, date, restrictionReason, adminRights, bannedRights, defaultBannedRights, _, payType, cost, _, _, isAdult, startDate, endDate):
        let isMin = (flags & (1 << 12)) != 0
        
        let participationStatus: ElloAppChannelParticipationStatus
        if (flags & Int32(1 << 1)) != 0 {
            participationStatus = .kicked
        } else if (flags & Int32(1 << 2)) != 0 {
            participationStatus = .left
        } else {
            participationStatus = .member
        }
        
        let info: ElloAppChannelInfo
        if (flags & Int32(1 << 8)) != 0 {
            var infoFlags = ElloAppChannelGroupFlags()
            if (flags & Int32(1 << 22)) != 0 {
                infoFlags.insert(.slowModeEnabled)
            }
            info = .group(ElloAppChannelGroupInfo(flags: infoFlags))
        } else {
            var infoFlags = ElloAppChannelBroadcastFlags()
            if (flags & Int32(1 << 11)) != 0 {
                infoFlags.insert(.messagesShouldHaveSignatures)
            }
            if (flags & Int32(1 << 20)) != 0 {
                infoFlags.insert(.hasDiscussionGroup)
            }
            info = .broadcast(ElloAppChannelBroadcastInfo(flags: infoFlags))
        }
        
        var channelFlags = ElloAppChannelFlags()
        if (flags & Int32(1 << 0)) != 0 {
            channelFlags.insert(.isCreator)
        }
        if (flags & Int32(1 << 7)) != 0 {
            channelFlags.insert(.isVerified)
        }
        if (flags & Int32(1 << 19)) != 0 {
            channelFlags.insert(.isScam)
        }
        if (flags & Int32(1 << 21)) != 0 {
            channelFlags.insert(.hasGeo)
        }
        if (flags & Int32(1 << 23)) != 0 {
            channelFlags.insert(.hasVoiceChat)
        }
        if (flags & Int32(1 << 24)) != 0 {
            channelFlags.insert(.hasActiveVoiceChat)
        }
        if (flags & Int32(1 << 25)) != 0 {
            channelFlags.insert(.isFake)
        }
        if (flags & Int32(1 << 26)) != 0 {
            channelFlags.insert(.isGigagroup)
        }
        if (flags & Int32(1 << 27)) != 0 {
            channelFlags.insert(.copyProtectionEnabled)
        }
        if (flags & Int32(1 << 28)) != 0 {
            if case .broadcast = info {
                channelFlags.insert(.joinToSend)
            }
        }
        if (flags & Int32(1 << 29)) != 0 {
            channelFlags.insert(.requestToJoin)
        }

        let restrictionInfo: PeerAccessRestrictionInfo?
        if let restrictionReason = restrictionReason {
            restrictionInfo = PeerAccessRestrictionInfo(apiReasons: restrictionReason)
        } else {
            restrictionInfo = nil
        }
        
        let accessHashValue = accessHash.flatMap { value -> ElloAppPeerAccessHash in
            if isMin {
                return .genericPublic(value)
            } else {
                return .personal(value)
            }
        }
        
        // TODO: Check is need description
        return ElloAppChannel(id: PeerId(namespace: Namespaces.Peer.CloudChannel, id: PeerId.Id._internalFromInt64Value(id)), accessHash: accessHashValue, title: title, description: nil, username: username, photo: imageRepresentationsForApiChatPhoto(photo), creationDate: date, version: 0, participationStatus: participationStatus, info: info, flags: channelFlags, restrictionInfo: restrictionInfo, adminRights: adminRights.flatMap(ElloAppChatAdminRights.init), bannedRights: bannedRights.flatMap(ElloAppChatBannedRights.init), defaultBannedRights: defaultBannedRights.flatMap(ElloAppChatBannedRights.init), payType: ElloAppChannelPayType(rawValue: payType), cost: cost, isAdult: isAdult.boolValue, startDate: startDate, endDate: endDate)
    case let .channelForbidden(flags, id, accessHash, title, untilDate):
        let info: ElloAppChannelInfo
        if (flags & Int32(1 << 8)) != 0 {
            info = .group(ElloAppChannelGroupInfo(flags: []))
        } else {
            info = .broadcast(ElloAppChannelBroadcastInfo(flags: []))
        }
        // TODO: Check is need description
        return ElloAppChannel(id: PeerId(namespace: Namespaces.Peer.CloudChannel, id: PeerId.Id._internalFromInt64Value(id)), accessHash: .personal(accessHash), title: title, description: nil, username: nil, photo: [], creationDate: 0, version: 0, participationStatus: .kicked, info: info, flags: ElloAppChannelFlags(), restrictionInfo: nil, adminRights: nil, bannedRights: ElloAppChatBannedRights(flags: [.banReadMessages], untilDate: untilDate ?? Int32.max), defaultBannedRights: nil, payType: .free, cost: nil, isAdult: false, startDate: nil, endDate: nil)
    }
}

func mergeGroupOrChannel(lhs: Peer?, rhs: Api.Chat) -> Peer? {
    switch rhs {
        case .chat, .chatEmpty, .chatForbidden, .channelForbidden:
            return parseElloAppGroupOrChannel(chat: rhs)
        case let .channel(flags, _, accessHash, title, username, photo, _, _, _, _, defaultBannedRights, _, _, _, _, _, _, _, _):
            let isMin = (flags & (1 << 12)) != 0
            if accessHash != nil && !isMin {
                return parseElloAppGroupOrChannel(chat: rhs)
            } else if let lhs = lhs as? ElloAppChannel {
                var channelFlags = lhs.flags
                if (flags & Int32(1 << 7)) != 0 {
                    channelFlags.insert(.isVerified)
                } else {
                    let _ = channelFlags.remove(.isVerified)
                }
                if (flags & Int32(1 << 23)) != 0 {
                    channelFlags.insert(.hasVoiceChat)
                } else {
                    let _ = channelFlags.remove(.hasVoiceChat)
                }
                if (flags & Int32(1 << 24)) != 0 {
                    channelFlags.insert(.hasActiveVoiceChat)
                } else {
                    let _ = channelFlags.remove(.hasActiveVoiceChat)
                }
                var info = lhs.info
                switch info {
                case .broadcast:
                    break
                case .group:
                    var infoFlags = ElloAppChannelGroupFlags()
                    if (flags & Int32(1 << 22)) != 0 {
                        infoFlags.insert(.slowModeEnabled)
                    }
                    info = .group(ElloAppChannelGroupInfo(flags: infoFlags))
                }
                // TODO: Check is need description
                return ElloAppChannel(id: lhs.id, accessHash: lhs.accessHash, title: title, description: nil, username: username, photo: imageRepresentationsForApiChatPhoto(photo), creationDate: lhs.creationDate, version: lhs.version, participationStatus: lhs.participationStatus, info: info, flags: channelFlags, restrictionInfo: lhs.restrictionInfo, adminRights: lhs.adminRights, bannedRights: lhs.bannedRights, defaultBannedRights: defaultBannedRights.flatMap(ElloAppChatBannedRights.init), payType: lhs.payType, cost: lhs.cost, isAdult: lhs.isAdult, startDate: lhs.startDate, endDate: lhs.endDate)
            } else {
                return parseElloAppGroupOrChannel(chat: rhs)
            }
    }
}

func mergeChannel(lhs: ElloAppChannel?, rhs: ElloAppChannel) -> ElloAppChannel {
    guard let lhs = lhs else {
        return rhs
    }
    
    if case .personal? = rhs.accessHash {
        return rhs
    }
    
    var channelFlags = lhs.flags
    if rhs.flags.contains(.isGigagroup) {
        channelFlags.insert(.isGigagroup)
    }
    if rhs.flags.contains(.isVerified) {
        channelFlags.insert(.isVerified)
    } else {
        let _ = channelFlags.remove(.isVerified)
    }
    if rhs.flags.contains(.hasVoiceChat) {
        channelFlags.insert(.hasVoiceChat)
    } else {
        let _ = channelFlags.remove(.hasVoiceChat)
    }
    if rhs.flags.contains(.hasActiveVoiceChat) {
        channelFlags.insert(.hasActiveVoiceChat)
    } else {
        let _ = channelFlags.remove(.hasActiveVoiceChat)
    }
    var info = lhs.info
    switch info {
    case .broadcast:
        break
    case .group:
        let infoFlags = ElloAppChannelGroupFlags()
        info = .group(ElloAppChannelGroupInfo(flags: infoFlags))
    }
    
    let accessHash: ElloAppPeerAccessHash?
    if let rhsAccessHashValue = lhs.accessHash, case .personal = rhsAccessHashValue {
        accessHash = rhsAccessHashValue
    } else {
        accessHash = rhs.accessHash ?? lhs.accessHash
    }
    
    return ElloAppChannel(id: lhs.id, accessHash: accessHash, title: rhs.title, description: rhs.description, username: rhs.username, photo: rhs.photo, creationDate: rhs.creationDate, version: rhs.version, participationStatus: lhs.participationStatus, info: info, flags: channelFlags, restrictionInfo: rhs.restrictionInfo, adminRights: rhs.adminRights, bannedRights: rhs.bannedRights, defaultBannedRights: rhs.defaultBannedRights, payType: rhs.payType, cost: rhs.cost, isAdult: rhs.isAdult, startDate: rhs.startDate, endDate: rhs.endDate)
}

