import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit


func _internal_updateAccountPeerName(account: Account, firstName: String, lastName: String, about: String? = nil, birthday: Date?, country: String?, gender: String?) -> Signal<Void, NoError> {
    var flags: Int32 = (1 << 0) | (1 << 1)
    if birthday != nil {
        flags = flags | (1 << 26)
    }
    if gender != nil {
        flags = flags | (1 << 25)
    }
    if country != nil {
        flags = flags | (1 << 24)
    }
    return account.network.request(Api.functions.account.updateProfile(flags: flags, firstName: firstName, lastName: lastName, about: about, birthday: birthday, country: country, gender: gender))
        |> map { result -> Api.User? in
            return result
        }
        |> `catch` { _ in
            return .single(nil)
        }
        |> mapToSignal { result -> Signal<Void, NoError> in
            return account.postbox.transaction { transaction -> Void in
                if let result = result {
                    if let peer = ElloAppUser.merge(transaction.getPeer(result.peerId) as? ElloAppUser, rhs: result) {
                        updatePeers(transaction: transaction, peers: [peer], update: { $1 })
                    }
                }
            }
        }
}

public enum UpdateAboutError {
    case generic
}


func _internal_updateAbout(account: Account, about: String?) -> Signal<Void, UpdateAboutError> {
    return account.network.request(Api.functions.account.updateProfile(flags: about == nil ? 0 : (1 << 2), firstName: nil, lastName: nil, about: about, birthday: nil, country: nil, gender: nil))
        |> mapError { _ -> UpdateAboutError in
            return .generic
        }
        |> mapToSignal { apiUser -> Signal<Void, UpdateAboutError> in
            return account.postbox.transaction { transaction -> Void in
                transaction.updatePeerCachedData(peerIds: Set([account.peerId]), update: { _, current in
                    if let current = current as? CachedUserData {
                        return current.withUpdatedAbout(about)
                    } else {
                        return current
                    }
                })
            }
            |> castError(UpdateAboutError.self)
    }
}
