//
//  Api30.swift
//  _idx_ElloAppApi_4F7BAED4_ios_min11.0
//
//

import Foundation

// MARK: - Sign In

public extension Api.authNew {
    
    static func signIn(username: String, password: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<RegValidation>) {
        
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] =
        [
            "service": 100200,
            "method": 100200, //Confirm method number
            "data": [
                "username": username,
                "password": password
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        return (FunctionDescription(name: "authNew.signIn", parameters: [("data", String(describing: dict))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> RegValidation? in
            let reader = BufferReader(buffer)
            var result: RegValidation?

            if let _ = reader.readInt32() {
                result = RegValidation.parse(reader)
            }
            return result
        })
    }
    
    static func signInConfirmationRequest(username: String, verificationCode: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AuthResponse>) {
        
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] =
        [
            "service": 100200,
            "method": 100700, //Confirm method number
            "data": [
                "username_or_email": username,
                "code": verificationCode
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        return (FunctionDescription(name: "authNew.signInConfirmation", parameters: [("data", String(describing: dict))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> AuthResponse? in
            let reader = BufferReader(buffer)
            var result: AuthResponse?
            
            if let _ = reader.readInt32() {
                result = AuthResponse.parse(reader)
            }
            return result
        })
    }
    
    struct AuthResponse: Codable {
        var predicate_name: String
        public var user: AuthResponseUser
        
        public static func parse(_ reader: BufferReader) -> AuthResponse? {
            reader.reset()
            _ = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            
            guard let jsonData = _2?.data(using: .utf8) else {
                return nil
            }
            
            do {
                let responseObject = try JSONDecoder().decode(AuthResponse.self, from: jsonData)
                return responseObject
            } catch {
                debugPrint(error)
                return nil
            }
        }
    }
    
    struct AuthResponseUser: Codable {
        var predicate_name: String
        public var id: Int
        var isSelf: Bool
        var contact: Bool
        var mutual_contact: Bool
        var access_hash: ValueInt
        var username: ValueStr?
        var status: Status
        
        enum CodingKeys: String, CodingKey {
            case predicate_name, id, isSelf = "self", contact, mutual_contact, access_hash, username, status
        }
        
        struct ValueInt: Codable {
            var value: Int
        }
        
        struct ValueStr: Codable {
            var value: String
        }
        
        struct Status: Codable {
            var predicate_name: String
            @DecodableDefault.ZeroInt var was_online: Int
            @DecodableDefault.ZeroInt var expires: Int
        }
    }
}
    
    // MARK: - Sign Up
    
public extension Api.authNew {
    
    static func signUp(username: String, 
                       password: String,
                       email: String,
                       countryCode: String,
                       gender: String ,
                       date_of_birth: String,
                       kind: String,
                       type: String,
                       referalCode: String? = nil) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<Api.authNew.RegValidation>) {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] =
        [
            "service": 100200, // AuthorizationCustomize Service numbber
            "method": 100100, // SignUp method number
            "data": [
                "username": username,
                "password": password,
                "gender": gender,
                "date_of_birth": date_of_birth, // "1998-06-10T00:00:00+0000"
                "email": email,
                "phone": "",
                "country_code": countryCode,
                "kind": kind, // "public" / "private"
                "type": type, // "business" / "personal"
                "code": referalCode
            ]
        ].compactMapValues{$0}
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        return (FunctionDescription(name: "authNew.signUp", parameters: [("data", String(describing: dict))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> RegValidation? in
            let reader = BufferReader(buffer)
            var result: RegValidation?
            
            if let _ = reader.readInt32() {
                result = RegValidation.parse(reader)
            }
            return result
        })
    }
    
    struct RegValidation: Codable {
        public var email: String
        public var confirmation_expire: Int
        
        public static func parse(_ reader: BufferReader) -> RegValidation? {
            reader.reset()
            _ = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            
            if let jsonData = _2?.data(using: .utf8),
               let object = try? JSONDecoder().decode(RegValidation.self, from: jsonData) {
                return object
            }
            return nil
        }
    }
}

// MARK: - Confirm Sign Up

public extension Api.authNew {
    static func signUpConfirmationRequest(username: String, verificationCode: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<AuthResponse>) {
        
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] =
        [
            "service": 100200,
            "method": 100800, //Confirm method number
            "data": [
                "username_or_email": username,
                "code": verificationCode
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        return (FunctionDescription(name: "authNew.signInConfirmation", parameters: [("data", String(describing: dict))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> AuthResponse? in
            let reader = BufferReader(buffer)
            var result: AuthResponse?
            
            if let _ = reader.readInt32() {
                result = AuthResponse.parse(reader)
            }
            return result
        })
    }
    
    static func resendSignUpConfirmationRequest(username: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<RegValidation>) {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] =
        [
            "service": 100200,
            "method": 100600, //Confirm method number
            "data": [
                "username_or_email": username
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        return (FunctionDescription(name: "authNew.resendSignUpConfirmationRequest", parameters: [("data", String(describing: dict))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> RegValidation? in
            let reader = BufferReader(buffer)
            var result: RegValidation?
            
            if let _ = reader.readInt32() {
                result = RegValidation.parse(reader)
            }
            return result
        })
    }
    
    static func confirmEmail(_ email: String, code: String) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<Api.authNew.ConfirmEmailResponse>) {
        
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100200,
            "method": 100300, //Confirm method number
            "data": [
                "username_or_email": email, // or "azeezmakhmudov@gmail.com"
                "code": code
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        return (FunctionDescription(name: "authNew.confirmEmail", parameters: [("data", String(describing: dict))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.authNew.ConfirmEmailResponse? in
            let reader = BufferReader(buffer)
            var result: Api.authNew.ConfirmEmailResponse?
            
            if let _ = reader.readInt32() {
                result = Api.authNew.ConfirmEmailResponse.parse(reader)
            }
            return result
        })
    }
    
    struct ConfirmEmailResponse: Codable {
        var message: String
        
        public static func parse(_ reader: BufferReader) -> ConfirmEmailResponse? {
            reader.reset()
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            
            if (_1 != nil) && (_2 != nil) {
                return Api.authNew.ConfirmEmailResponse(message: _2 ?? "")
            }
            else {
                return nil
            }
        }
    }
}

public extension Api.authNew {
    static func checkEmailAvailability(email: String)  -> (FunctionDescription, Buffer, DeserializeFunctionResponse<Api.Bool>) {
        let buffer = Buffer()
        buffer.appendInt32(-1701759380)
        serializeString(email, buffer: buffer, boxed: false)
        return (FunctionDescription(name: "authNew.checkEmailAvailability", parameters: [("email", String(describing: email))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Bool? in
            let reader = BufferReader(buffer)
            var result: Api.Bool?
            if let signature = reader.readInt32() {
                result = Api.parse(reader, signature: signature) as? Api.Bool
            }
            return result
        })
    }
}
