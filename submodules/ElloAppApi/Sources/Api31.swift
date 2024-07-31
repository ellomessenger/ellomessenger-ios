//
//  Api31.swift
//  _idx_ElloAppApi_4F23D8A3_ios_min11.0
//
//

import Foundation

// MARK: - Forgot password
public extension Api.forgotPassword {
    typealias ForgotPasswordValue<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    static func forgotPassword(_ email: String) -> ForgotPasswordValue<Api.Response.SendVerificationCode> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100200,
            "method": 100400, // Forgot password number
            "data": [
                "email": email, // or "azeezmakhmudov@gmail.com"
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "forgotPassword.forgotPassword",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Response.SendVerificationCode? in
            let reader = BufferReader(buffer)
            var result: Api.Response.SendVerificationCode?
            
            if let _ = reader.readInt32() {
                result = Api.Response.SendVerificationCode.parse(reader)
            }
            return result
        })
    }
}

// MARK: - Create new password
public extension Api.forgotPassword {
    static func createNewPassword(_ email: String, code: String, password: String) -> ForgotPasswordValue<Api.forgotPassword.CreateNewPasswordResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100200,
            "method": 100500, // New password number
            "data": [
                "email": email, // or "azeezmakhmudov@gmail.com"
                "code": code,
                "new_pass": password
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "forgotPassword.forgotPassword",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.forgotPassword.CreateNewPasswordResponse? in
            let reader = BufferReader(buffer)
            var result: Api.forgotPassword.CreateNewPasswordResponse?
            
            if let _ = reader.readInt32() {
                result = Api.forgotPassword.CreateNewPasswordResponse.parse(reader)
            }
            return result
        })
    }
    
    struct CreateNewPasswordResponse: Codable {
        public var status: Bool
        public var message: String
        
        static func parse(_ reader: BufferReader) -> CreateNewPasswordResponse? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            guard let jsonData = _2?.data(using: .utf8),
                  let object = try? JSONDecoder().decode(CreateNewPasswordResponse.self, from: jsonData) else {
                return nil
            }
            
            print(object)
            
            return object
        }
    }
}
