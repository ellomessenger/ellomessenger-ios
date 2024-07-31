//
//  Extension+String.swift
//  ElloMessenger
//
//

import Foundation
import UIKit

public extension String {
    private func capitalizedFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func capitalizeFirst() -> String {
        return self.lowercased().capitalizedFirst()
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
      
    func isValidPassword() -> Bool {
        let lengthValid = count >= 6
        let digitValid = !CharacterSet(charactersIn: self).intersection(CharacterSet.decimalDigits).isEmpty
        let letterValid = !CharacterSet(charactersIn: self).intersection(CharacterSet.letters).isEmpty
        let uppercaseValid = !CharacterSet(charactersIn: self).intersection(CharacterSet.uppercaseLetters).isEmpty
        let lowercaseValid = !CharacterSet(charactersIn: self).intersection(CharacterSet.lowercaseLetters).isEmpty
        
        return lengthValid && digitValid && letterValid && uppercaseValid && lowercaseValid
    }
    
    func isValidUserName() -> Bool {
        let lengthValid = count >= 5 && count <= 32
        return isAlphanumeric && lengthValid
    }
    
    func appendQueryItems(items: [String: Any]) -> String {
        var newString = self
        for (key, value) in items {
            if newString.contains("?" + key + "=\(value)") {
                
            } else {
                newString.append("&" + key + "=\(value)")
            }
        }
        return newString
    }
    
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
        
    var isLatinCharactersOnly: Bool {
        range(of: "\\P{Latin}", options: .regularExpression) == nil
    }
   
    var isAlphanumeric: Bool {
        allSatisfy { $0.isLatin || $0.isNumber }
    }
    
    var isAllowedForUserName: Bool {
        allSatisfy { $0.isLatin || $0.isNumber || $0 == "_" }
    }
    
    var acronym: String {
        self.components(separatedBy: " ")
            .reduce("") { $0 + ($1.first.map(String.init) ?? "") }
    }
    
    var double: Double? {
        Double(self.replacingOccurrences(of: ",", with: "."))
    }
    
    var removedUNKNOWN: String {
        return self
            .replacingOccurrences(of: "UNKNOWN, ", with: "")
            .replacingOccurrences(of: "UNKNOWN ", with: "")
            .replacingOccurrences(of: "UNKNOWN", with: "")
    }
}

public extension String {
    var currencySymbol: String { return Currency.shared.findSymbol(currencyCode: self) }
}

public final class Currency {
    static let shared: Currency = Currency()
    
    private var cache: [String: String] = [:]
    
    func findSymbol(currencyCode:String) -> String {
        if let hit = cache[currencyCode] { return hit }
        guard currencyCode.count < 4 else { return "" }
        
        let symbol = findSymbolBy(currencyCode)
        cache[currencyCode] = symbol
        
        return symbol
    }
    
    private func findSymbolBy(_ currencyCode: String) -> String {
        var candidates: [String] = []
        let locales = NSLocale.availableLocaleIdentifiers
        
        for localeId in locales {
            guard let symbol = findSymbolBy(localeId, currencyCode) else { continue }
            if symbol.count == 1 { return symbol }
            candidates.append(symbol)
        }
        
        return candidates.sorted(by: { $0.count < $1.count }).first ?? ""
    }
    
    private func findSymbolBy(_ localeId: String, _ currencyCode: String) -> String? {
        let locale = Locale(identifier: localeId)
        return currencyCode.caseInsensitiveCompare(locale.currency?.identifier ?? "") == .orderedSame
        ? locale.currencySymbol : nil
    }
}

extension Character {
    var isLatin: Bool {
        String(self).isLatinCharactersOnly
    }
}

public extension NSAttributedString {
    func bulletPointAttributedString(strings: [String], textFont: UIFont?, headIndent: CGFloat = 0.0, firstLineHeadIndent: CGFloat = 0.0, lineHeightMultiple: CGFloat = 1.26) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = headIndent
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
//        paragraphStyle.minimumLineHeight = 26.0
        paragraphStyle.maximumLineHeight = 28.0
        
        let bulletFont = UIFont.systemFont(ofSize: 16.0, weight: .black)
        let attributedString = NSMutableAttributedString()
        
        for (index, string) in strings.enumerated() {
            let bulletPoint = NSAttributedString(
                string: "\u{2022}\t",
                attributes: [
                    .font: bulletFont,
                    .paragraphStyle: paragraphStyle])
            let text = NSAttributedString(
                string: string,
                attributes: [.font: textFont as Any, .paragraphStyle: paragraphStyle])
            attributedString.append(bulletPoint)
            attributedString.append(text)
            
            if index < strings.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        
        return attributedString
    }
}

public func defineMessageApp() -> String {
    let gmail = "googlegmail:"
    let outlook = "ms-outlook:"
    let yahoo = "ymail:"
    let spark = "readdle-spark:"
    let defaultApp = "message:"
    
    if let gmailUrl = URL(string: gmail + "//"), UIApplication.shared.canOpenURL(gmailUrl) {
        return gmail
    } else if let outlookUrl = URL(string: outlook + "//"), UIApplication.shared.canOpenURL(outlookUrl) {
        return outlook
    } else if let yahooMail = URL(string: yahoo + "//"), UIApplication.shared.canOpenURL(yahooMail) {
        return yahoo
    } else if let sparkUrl = URL(string: spark + "//"), UIApplication.shared.canOpenURL(sparkUrl) {
        return spark
    }
    
    return defaultApp
}
