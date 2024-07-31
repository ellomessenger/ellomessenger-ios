import Foundation
import UIKit
import AsyncDisplayKit
import Display
import Postbox
import ElloAppCore
import AccountContext

public protocol SettingsController: AnyObject {
    func updateContext(context: AccountContext)
}

public func makePrivacyAndSecurityController(context: AccountContext) -> ViewController {
    return privacyAndSecurityController(context: context, focusOnItemTag: PrivacyAndSecurityEntryTag.autoArchive)
}
