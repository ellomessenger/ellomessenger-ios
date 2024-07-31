import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit

public enum CreateChannelError {
    case generic
    case restricted
    case tooMuchJoined
    case tooMuchLocationBasedGroups
    case serverProvided(String)
}

private func createChannel(account: Account, 
                           title: String,
                           description: String?,
                           isSupergroup: Bool,
                           location: (latitude: Double, longitude: Double, address: String)? = nil,
                           isForHistoryImport: Bool = false,
                           payType: ElloAppChannelPayType, 
                           cost: Double?,
                           category: String?,
                           country: String,
                           adult: Bool,
                           startDate: Int64? = nil,
                           endDate: Int64? = nil,
                           genre: String? = nil,
                           subGenre: String? = nil,
                           name: String?) -> Signal<PeerId, CreateChannelError> {
    return account.postbox.transaction { transaction -> Signal<PeerId, CreateChannelError> in
        
        let payType: Int32? = Int32(payType.rawValue)//(cost == nil) ? 0 : 2
        let cost = cost
        let category = category
        let country = country
        let adult = adult
        // Convert to miliseconds
        let startDate = startDate.map { $0 * 1000 }
        let endDate = endDate.map { $0 * 1000 }
        
        var flags: Int32 = 0
        if isSupergroup {
            flags |= (1 << 1)
        } else {
            flags |= (1 << 0)
        }
        if isForHistoryImport {
            flags |= (1 << 3)
        }
        
        if payType != nil && cost != nil {
            flags |= 1<<4
        }
        if let startDate, startDate != 0 {
            flags |= 1<<5
        }
        if !(category?.isEmpty ?? true) {
            flags |= 1<<6
        }
        if !country.isEmpty {
            flags |= 1<<8
        }
        if adult {
            flags |= 1<<10
        }
        if let genre, !genre.isEmpty {
            flags |= 1 << 11
        }
        if let subGenre, !subGenre.isEmpty {
            flags |= 1 << 12
        }
        if let name, !name.isEmpty {
            flags |= 1 << 13
        }
        
        var geoPoint: Api.InputGeoPoint?
        var address: String?
        if let location = location {
            flags |= (1 << 2)
            geoPoint = .inputGeoPoint(flags: 0, lat: location.latitude, long: location.longitude, accuracyRadius: nil)
            address = location.address
        }
        
        transaction.clearItemCacheCollection(collectionId: Namespaces.CachedItemCollection.cachedGroupCallDisplayAsPeers)
        
        return account.network.request(Api.functions.channels.createChannel(flags: flags, 
                                                                            title: title,
                                                                            about: description ?? "",
                                                                            geoPoint: geoPoint,
                                                                            address: address,
                                                                            payType: payType,
                                                                            cost: cost,
                                                                            category: category,
                                                                            country: country,
                                                                            startDate: startDate,
                                                                            endDate: endDate,
                                                                            genre: genre,
                                                                            subGenre: subGenre,
                                                                            name: name),
                                       automaticFloodWait: false)
        |> mapError { error -> CreateChannelError in
            if error.errorCode == 406 {
                return .generic
            } else if error.errorDescription == "CHANNELS_TOO_MUCH" {
                return .tooMuchJoined
            } else if error.errorDescription == "CHANNELS_ADMIN_LOCATED_TOO_MUCH" {
                return .tooMuchLocationBasedGroups
            } else if error.errorDescription == "USER_RESTRICTED" {
                return .restricted
            } else if !error.errorDescription.isEmpty {
                return .serverProvided(error.errorDescription)
            } else {
                return .generic
            }
        }
        |> mapToSignal { updates -> Signal<PeerId, CreateChannelError> in
            account.stateManager.addUpdates(updates)
            if let message = updates.messages.first, let peerId = apiMessagePeerId(message) {
                return account.postbox.multiplePeersView([peerId])
                |> filter { view in
                    return view.peers[peerId] != nil
                }
                |> take(1)
                |> map { _ in
                    return peerId
                }
                |> castError(CreateChannelError.self)
                |> timeout(5.0, queue: Queue.concurrentDefaultQueue(), alternate: .fail(.generic))
            } else {
                return .fail(.generic)
            }
        }
    }
    |> castError(CreateChannelError.self)
    |> switchToLatest
}

func _internal_createChannel(account: Account, title: String, description: String?, payType: ElloAppChannelPayType, cost: Double?, category: String?, country: String, adult: Bool, startDate: Int64? = nil, endDate: Int64? = nil, genre: String? = nil, subGenre: String? = nil, name: String?) -> Signal<PeerId, CreateChannelError> {
    return createChannel(account: account, title: title, description: description, isSupergroup: false, payType: payType, cost: cost, category: category, country: country, adult: adult, startDate: startDate, endDate: endDate, genre: genre, subGenre: subGenre, name: name)
}

func _internal_createSupergroup(account: Account, title: String, description: String?, location: (latitude: Double, longitude: Double, address: String)? = nil, isForHistoryImport: Bool = false) -> Signal<PeerId, CreateChannelError> {
    return createChannel(account: account, title: title, description: description, isSupergroup: true, location: location, isForHistoryImport: isForHistoryImport, payType: .free, cost: nil, category: nil, country: "", adult: false, name: nil)
}

public enum DeleteChannelError {
    case generic
}

func _internal_deleteChannel(account: Account, peerId: PeerId) -> Signal<Void, DeleteChannelError> {
    return account.postbox.transaction { transaction -> Api.InputChannel? in
        return transaction.getPeer(peerId).flatMap(apiInputChannel)
    }
    |> mapError { _ -> DeleteChannelError in }
    |> mapToSignal { inputChannel -> Signal<Void, DeleteChannelError> in
        if let inputChannel = inputChannel {
            return account.network.request(Api.functions.channels.deleteChannel(channel: inputChannel))
            |> map(Optional.init)
            |> `catch` { _ -> Signal<Api.Updates?, DeleteChannelError> in
                return .fail(.generic)
            }
            |> mapToSignal { updates -> Signal<Void, DeleteChannelError> in
                if let updates = updates {
                    account.stateManager.addUpdates(updates)
                }
                return .complete()
            }
        } else {
            return .fail(.generic)
        }
    }
}
