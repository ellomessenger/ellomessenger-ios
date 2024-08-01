import Foundation
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppNotices

final class InteractiveChatLinkPreviewsResult {
    let f: (Bool) -> Void
    
    init(_ f: @escaping (Bool) -> Void) {
        self.f = f
    }
}

func interactiveChatLinkPreviewsEnabled(accountManager: AccountManager<ElloAppAccountManagerTypes>, displayAlert: @escaping (InteractiveChatLinkPreviewsResult) -> Void) -> Signal<Bool, NoError> {
    return ApplicationSpecificNotice.getSecretChatLinkPreviews(accountManager: accountManager)
    |> mapToSignal { value -> Signal<Bool, NoError> in
        if let value = value {
            return .single(value)
        } else {
            return Signal { subscriber in
                Queue.mainQueue().async {
                    displayAlert(InteractiveChatLinkPreviewsResult({ result in
                        let _ = ApplicationSpecificNotice.setSecretChatLinkPreviews(accountManager: accountManager, value: result).start()
                        subscriber.putNext(result)
                        subscriber.putCompletion()
                    }))
                }
                return EmptyDisposable
            }
        }
    }
}
