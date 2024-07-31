
import UIKit
import AppBundle

extension UILabel {
    @IBInspectable public var localizedText: String? {
        get { nil }
        set {
            text = newValue?.localized
            if text == newValue {
                text = newValue?.localized(getAppBundle())
            }
            if text == newValue {
                text = newValue?.localized(getLocalizationAppBundle())
            }
        }
    }
}

extension UIButton {
    @IBInspectable var localizedTitle: String? {
        get { return "" }
        set {
            var text = newValue?.localized
            if text == newValue {
                text = newValue?.localized(getAppBundle())
            }
            if text == newValue {
                text = newValue?.localized(getLocalizationAppBundle())
            }
            setTitle(text, for: .normal)
        }
    }
}
