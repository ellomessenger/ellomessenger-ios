import Foundation
import Postbox
import ElloAppApi


func elloappMediaActionFromApiAction(_ action: Api.MessageAction) -> ElloAppMediaAction? {
    switch action {
        case let .messageActionChannelCreate(title):
            return ElloAppMediaAction(action: .groupCreated(title: title))
        case let .messageActionChannelMigrateFrom(title, chatId):
            return ElloAppMediaAction(action: .channelMigratedFromGroup(title: title, groupId: PeerId(namespace: Namespaces.Peer.CloudGroup, id: PeerId.Id._internalFromInt64Value(chatId))))
        case let .messageActionChatAddUser(users):
            return ElloAppMediaAction(action: .addedMembers(peerIds: users.map({ PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value($0)) })))
        case let .messageActionChatCreate(title, _):
            return ElloAppMediaAction(action: .groupCreated(title: title))
        case .messageActionChatDeletePhoto:
            return ElloAppMediaAction(action: .photoUpdated(image: nil))
        case let .messageActionChatDeleteUser(userId):
            return ElloAppMediaAction(action: .removedMembers(peerIds: [PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(userId))]))
        case let .messageActionChatEditPhoto(photo):
            return ElloAppMediaAction(action: .photoUpdated(image: elloappMediaImageFromApiPhoto(photo)))
        case let .messageActionChatEditTitle(title):
            return ElloAppMediaAction(action: .titleUpdated(title: title))
        case let .messageActionChatJoinedByLink(inviterId):
            return ElloAppMediaAction(action: .joinedByLink(inviter: PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(inviterId))))
        case let .messageActionChatMigrateTo(channelId):
            return ElloAppMediaAction(action: .groupMigratedToChannel(channelId: PeerId(namespace: Namespaces.Peer.CloudChannel, id: PeerId.Id._internalFromInt64Value(channelId))))
        case .messageActionHistoryClear:
            return ElloAppMediaAction(action: .historyCleared)
        case .messageActionPinMessage:
            return ElloAppMediaAction(action: .pinnedMessageUpdated)
        case let .messageActionGameScore(gameId, score):
            return ElloAppMediaAction(action: .gameScore(gameId: gameId, score: score))
        case let .messageActionPhoneCall(flags, callId, reason, duration):
            var discardReason: PhoneCallDiscardReason?
            if let reason = reason {
                discardReason = PhoneCallDiscardReason(apiReason: reason)
            }
            let isVideo = (flags & (1 << 2)) != 0
            return ElloAppMediaAction(action: .phoneCall(callId: callId, discardReason: discardReason, duration: duration, isVideo: isVideo))
        case .messageActionEmpty:
            return nil
        case let .messageActionPaymentSent(flags, currency, totalAmount, invoiceSlug):
            let isRecurringInit = (flags & (1 << 2)) != 0
            let isRecurringUsed = (flags & (1 << 3)) != 0
            return ElloAppMediaAction(action: .paymentSent(currency: currency, totalAmount: totalAmount, invoiceSlug: invoiceSlug, isRecurringInit: isRecurringInit, isRecurringUsed: isRecurringUsed))
        case .messageActionPaymentSentMe:
            return nil
        case .messageActionScreenshotTaken:
            return ElloAppMediaAction(action: .historyScreenshot)
        case let .messageActionCustomAction(message):
            return ElloAppMediaAction(action: .customText(text: message, entities: []))
        case let .messageActionBotAllowed(domain):
            return ElloAppMediaAction(action: .botDomainAccessGranted(domain: domain))
        case .messageActionSecureValuesSentMe:
            return nil
        case let .messageActionSecureValuesSent(types):
            return ElloAppMediaAction(action: .botSentSecureValues(types: types.map(SentSecureValueType.init)))
        case .messageActionContactSignUp:
            return ElloAppMediaAction(action: .peerJoined)
        case let .messageActionGeoProximityReached(fromId, toId, distance):
            return ElloAppMediaAction(action: .geoProximityReached(from: fromId.peerId, to: toId.peerId, distance: distance))
        case let .messageActionGroupCall(_, call, duration):
            switch call {
            case let .inputGroupCall(id, accessHash):
                return ElloAppMediaAction(action: .groupPhoneCall(callId: id, accessHash: accessHash, scheduleDate: nil, duration: duration))
            }
        case let .messageActionInviteToGroupCall(call, userIds):
            switch call {
            case let .inputGroupCall(id, accessHash):
                return ElloAppMediaAction(action: .inviteToGroupPhoneCall(callId: id, accessHash: accessHash, peerIds: userIds.map { userId in
                    PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(userId))
                }))
            }
        case let .messageActionSetMessagesTTL(period):
            return ElloAppMediaAction(action: .messageAutoremoveTimeoutUpdated(period))
        case let .messageActionGroupCallScheduled(call, scheduleDate):
            switch call {
            case let .inputGroupCall(id, accessHash):
                return ElloAppMediaAction(action: .groupPhoneCall(callId: id, accessHash: accessHash, scheduleDate: scheduleDate, duration: nil))
            }
        case let .messageActionSetChatTheme(emoji):
            return ElloAppMediaAction(action: .setChatTheme(emoji: emoji))
        case .messageActionChatJoinedByRequest:
            return ElloAppMediaAction(action: .joinedByRequest)
        case let .messageActionWebViewDataSentMe(text, _), let .messageActionWebViewDataSent(text):
            return ElloAppMediaAction(action: .webViewData(text))
        case let .messageActionGiftPremium(currency, amount, months):
            return ElloAppMediaAction(action: .giftPremium(currency: currency, amount: amount, months: months))
    }
}

extension PhoneCallDiscardReason {
    init(apiReason: Api.PhoneCallDiscardReason) {
        switch apiReason {
            case .phoneCallDiscardReasonBusy:
                self = .busy
            case .phoneCallDiscardReasonDisconnect:
                self = .disconnect
            case .phoneCallDiscardReasonHangup:
                self = .hangup
            case .phoneCallDiscardReasonMissed:
                self = .missed
        }
    }
}

extension SentSecureValueType {
    init(apiType: Api.SecureValueType) {
        switch apiType {
            case .secureValueTypePersonalDetails:
                self = .personalDetails
            case .secureValueTypePassport:
                self = .passport
            case .secureValueTypeDriverLicense:
                self = .driversLicense
            case .secureValueTypeIdentityCard:
                self = .idCard
            case .secureValueTypeAddress:
                self = .address
            case .secureValueTypeBankStatement:
                self = .bankStatement
            case .secureValueTypeUtilityBill:
                self = .utilityBill
            case .secureValueTypeRentalAgreement:
                self = .rentalAgreement
            case .secureValueTypePhone:
                self = .phone
            case .secureValueTypeEmail:
                self = .email
            case .secureValueTypeInternalPassport:
                self = .internalPassport
            case .secureValueTypePassportRegistration:
                self = .passportRegistration
            case .secureValueTypeTemporaryRegistration:
                self = .temporaryRegistration
        }
    }
}
