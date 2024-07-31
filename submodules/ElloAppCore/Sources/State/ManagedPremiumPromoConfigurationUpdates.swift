import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit

public func updatePremiumPromoConfigurationOnce(account: Account) -> Signal<Void, NoError> {
    return updatePremiumPromoConfigurationOnce(postbox: account.postbox, network: account.network)
}

func updatePremiumPromoConfigurationOnce(postbox: Postbox, network: Network) -> Signal<Void, NoError> {
    return network.request(Api.functions.help.getPremiumPromo())
    |> map(Optional.init)
    |> `catch` { _ -> Signal<Api.help.PremiumPromo?, NoError> in
        return .single(nil)
    }
    |> mapToSignal { result -> Signal<Void, NoError> in
        guard let result = result else {
            return .complete()
        }
        return postbox.transaction { transaction -> Void in
            if case let .premiumPromo(_, _, _, _, _, apiUsers) = result {
                let users = apiUsers.map { ElloAppUser(user: $0) }
                updatePeers(transaction: transaction, peers: users, update: { current, updated -> Peer in
                    if let updated = updated as? ElloAppUser {
                        return ElloAppUser.merge(lhs: current as? ElloAppUser, rhs: updated)
                    } else {
                        return updated
                    }
                })
            }
            
            updatePremiumPromoConfiguration(transaction: transaction, { configuration -> PremiumPromoConfiguration in
                return PremiumPromoConfiguration(apiPremiumPromo: result)
            })
        }
    }
}

func managedPremiumPromoConfigurationUpdates(postbox: Postbox, network: Network) -> Signal<Void, NoError> {
    let poll = Signal<Void, NoError> { subscriber in
        return updatePremiumPromoConfigurationOnce(postbox: postbox, network: network).start(completed: {
            subscriber.putCompletion()
        })
    }
    return (poll |> then(.complete() |> suspendAwareDelay(10.0 * 60.0 * 60.0, queue: Queue.concurrentDefaultQueue()))) |> restart
}

private func currentPremiumPromoConfiguration(transaction: Transaction) -> PremiumPromoConfiguration {
    if let entry = transaction.getPreferencesEntry(key: PreferencesKeys.premiumPromo)?.get(PremiumPromoConfiguration.self) {
        return entry
    } else {
        return PremiumPromoConfiguration.defaultValue
    }
}

private func updatePremiumPromoConfiguration(transaction: Transaction, _ f: (PremiumPromoConfiguration) -> PremiumPromoConfiguration) {
    let current = currentPremiumPromoConfiguration(transaction: transaction)
    let updated = f(current)
    if updated != current {
        transaction.setPreferencesEntry(key: PreferencesKeys.premiumPromo, value: PreferencesEntry(updated))
    }
}

private extension PremiumPromoConfiguration {
    init(apiPremiumPromo: Api.help.PremiumPromo) {
        switch apiPremiumPromo {
            case let .premiumPromo(statusText, statusEntities, videoSections, videoFiles, options, _):
                self.status = statusText
                self.statusEntities = messageTextEntitiesFromApiEntities(statusEntities)

                var videos: [String: ElloAppMediaFile] = [:]
                for (key, document) in zip(videoSections, videoFiles) {
                    if let file = elloappMediaFileFromApiDocument(document) {
                        videos[key] = file
                    }
                }
                self.videos = videos
            
                var productOptions: [PremiumProductOption] = []
                for option in options {
                    if case let .premiumSubscriptionOption(_, months, currency, amount, botUrl, storeProduct) = option {
                        productOptions.append(PremiumProductOption(months: months, currency: currency, amount: amount, botUrl: botUrl, storeProductId: storeProduct))
                    }
                }
                self.premiumProductOptions = productOptions
        }
    }
}
