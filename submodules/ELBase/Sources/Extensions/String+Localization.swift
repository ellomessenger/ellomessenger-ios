//
//  String+Localization.swift
//  ElloMessenger
//
//

import Foundation
import AppBundle

public extension String {
    
    var localized: String {
        localized()
    }
    
    func localized(_ bundle: Bundle? = Bundle(for: BaseViewController.self)) -> String {
        guard let bundle else {
            return "Unknown bundle"
        }
        
        return NSLocalizedString(self, bundle: bundle, value:localizedBase(), comment: "")
    }
    
    func localizedBase() -> String {
        return NSLocalizedString(self, bundle: getLocalizationAppBundle(), comment: "")
    }
}

public extension RawRepresentable where RawValue == String {
    var localized: String {
        return self.localized()
    }
    
    func localized(_ bundle: Bundle? = Bundle(for: BaseViewController.self)) -> String {
        guard let bundle else {
            return "Unknown bundle"
        }
        return self.rawValue.localized(bundle)
    }
}
