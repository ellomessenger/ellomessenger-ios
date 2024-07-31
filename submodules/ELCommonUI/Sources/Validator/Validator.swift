//
//  Validator.swift
//  _idx_AccountContext_0DB1E858_ios_min14.0
//
//

import Foundation
import ELBase


public protocol Validator {
    func validate(value: String) throws
    var isSecure: Bool { get }
}

extension Validator {
    public var isSecure: Bool { false }
}

public struct EmailValidator: Validator {
    public enum Error: String, LocalizedError {
        case invalidEmailFormat, emptyEmailError
        
        public var errorDescription: String? {
            self.localized
        }
    }
    
    public init() {
        
    }
    
    public func validate(value: String) throws {
        if value.isEmpty {
            throw Error.emptyEmailError
        }
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        if !emailPredicate.evaluate(with: value) {
            throw Error.invalidEmailFormat
        }
    }
}

public struct PasswordValidator: Validator {
    
    public enum Error: String, LocalizedError {
        case invalidPasswordFormat, emptyPasswordError, passwordsNotMatch
        
        public var errorDescription: String? {
            self.localized
        }
    }
    
    var inputedPassword: String?
    
    public init() {
        
    }
    
    public mutating func updateInputedPassword(_ value: String?) {
        inputedPassword = value
    }
    
    public func validate(value: String) throws {
        if value.isEmpty {
            throw Error.emptyPasswordError
        }
        let lengthValid = value.count >= 8
        let digitValid = !CharacterSet(charactersIn: value).intersection(CharacterSet.decimalDigits).isEmpty
        let letterValid = !CharacterSet(charactersIn: value).intersection(CharacterSet.letters).isEmpty
        let uppercaseValid = !CharacterSet(charactersIn: value).intersection(CharacterSet.uppercaseLetters).isEmpty
        let lowercaseValid = !CharacterSet(charactersIn: value).intersection(CharacterSet.lowercaseLetters).isEmpty
        if !(lengthValid && digitValid && letterValid && uppercaseValid && lowercaseValid) {
            throw Error.invalidPasswordFormat
        }
        if let inputedPassword, inputedPassword != value {
            throw Error.passwordsNotMatch
        }
    }
    
    public var isSecure: Bool {
        true
    }
}

public struct UsernameValidator: Validator {
    public enum Error: String, LocalizedError {
        case usernameTooShort
        case usernameTooLong
        case usernameInvalid
        case usernameInvalidStartNumber
        case empty = "Username.invalidEmpty"
        
        public var errorDescription: String? {
            self.localized
        }
    }
    
    public init() {
        
    }
    
    public func validate(value: String) throws {
        guard !value.isEmpty else {
            throw Error.empty
        }
        if value.hasPrefix("_") || value.hasSuffix("_") || value.contains("__") {
            throw Error.usernameInvalid
        }
        if value.first!.isNumber {
            throw Error.usernameInvalidStartNumber
        }
        if !value.isAllowedForUserName {
            throw Error.usernameInvalid
        }
        if value.count > 32 {
            throw Error.usernameTooLong
        }
        if value.count < 5 {
            throw Error.usernameTooShort
        }
    }
}

public struct EmptyValueValidator: Validator {
    public enum Error: String, LocalizedError {
        case empty = "FieldInvalidEmpty"
        case required = "FieldInvalidRequired"
        
        public var errorDescription: String? {
            self.localized
        }
    }
    
    public var isRequired: Bool = false
    
    public init() {
        
    }
    
    public func validate(value: String) throws {
        guard !value.isEmpty else {
            throw isRequired ? Error.required : .empty
        }
    }
}

public struct NameValidator: Validator {
    public enum Error: String, LocalizedError {
        case usernameTooShort
        case usernameTooLong
        case usernameInvalid
        case usernameInvalidStartNumber
        case empty = "Username.invalidEmpty"
        
        public var errorDescription: String? {
            self.localized
        }
    }
    
    public init() { }
    
    public func validate(value: String) throws {
        guard !value.isEmpty else {
            throw Error.empty
        }
        if value.hasPrefix("_") || value.hasSuffix("_") || value.contains("__") {
            throw Error.usernameInvalid
        }
        if value.first!.isNumber {
            throw Error.usernameInvalidStartNumber
        }
        if !value.isAllowedForUserName {
            throw Error.usernameInvalid
        }
        if value.count > 20 {
            throw Error.usernameTooLong
        }
        if value.count < 2 {
            throw Error.usernameTooShort
        }
    }
}
