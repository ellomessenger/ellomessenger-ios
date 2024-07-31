//
//  UIImage+size.swift
//  OGMOrthotics
//
//

import Foundation
import UIKit

public extension UITextField {
    func shouldPriceChangeCharactersIn(_ range: NSRange, replacementString string: String) -> Bool {
        guard let text else { return true }
        if string == "," && text.contains(".") { return false }
        if string == "," && !text.isEmpty {
            self.text?.append(".")
            return false
        }
        
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        guard !newString.isEmpty else { return true }
        guard "0." != newString else { return true }
        guard "0" != newString else { return true }
        guard newString.appending(".").trimmingCharacters(in: CharacterSet(charactersIn: "0")) == newString.appending(".") else { return false }

        let parts = newString.split(separator: ".")
        if  1 < parts.count {
            guard (parts.last?.count ?? 0 <= 2) else { return false }
        }
        
        guard (0 < Int(String(newString.first ?? " ")) ?? 0) || ( 1 < parts.count ) else { return false }
        guard let doubleString = Double(newString) else { return false }
        
        return doubleString <= 99999.99
    }
}
