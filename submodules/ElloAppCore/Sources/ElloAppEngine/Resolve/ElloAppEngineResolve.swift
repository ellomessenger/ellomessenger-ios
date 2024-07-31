import SwiftSignalKit
import Postbox

public extension ElloAppEngine {
    final class Resolve {
        private let account: Account

        init(account: Account) {
            self.account = account
        }

        public func getDeepLinkInfo(path: String) -> Signal<DeepLinkInfo?, NoError> {
            return _internal_getDeepLinkInfo(network: self.account.network, path: path)
        }
    }
}
