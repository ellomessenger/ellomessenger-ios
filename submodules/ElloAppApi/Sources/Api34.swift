//
//  Api33.swift
//  _idx_ElloAppApi_50E079A9_ios_min11.0
//
//

import Foundation

// MARK: - Change Password

public extension Api.changePassword {
    typealias ChangePasswordValue<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    static func changePassword(_ password: String, newPassword: String, code: String) -> ChangePasswordValue<Api.Response.BaseResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100200,  // verification code
            "data": [
                "prev_pass": password,
                "new_pass": newPassword,
                "code": code
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "changePassword.changePassword",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Response.BaseResponse? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Api.Response.BaseResponse.parse(reader)
        })
    }
}

// MARK: - Verify Code

public extension Api.sendVerifyCode {
    typealias VerifyCodeValue<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    static func sendVerifyCode(_ email: String) -> VerifyCodeValue<Api.Response.SendVerificationCode> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100500,  // verification code
            "data": [
                "email": email
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "verifyCode.verifyCode",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Response.SendVerificationCode? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Api.Response.SendVerificationCode.parse(reader)
        })
    }
}

public extension Api.deleteAccount {
    typealias DeleteAccountValue<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    static func confirmDeleteAccount(_ code: String) -> DeleteAccountValue<Api.Response.BaseResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100400,  // verification code
            "data": [
                "code": code
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "deleteAccount.deleteAccountConfirm",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Response.BaseResponse? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Api.Response.BaseResponse.parse(reader)
        })
    }
    
    static func deleteAccount(_ email: String, password: String) -> DeleteAccountValue<Api.Response.SendVerificationCode> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100800,  // verification code
            "data": [
                "email": email,
                "password": password
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "deleteAccount.deleteAccountRequest",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Response.SendVerificationCode? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Api.Response.SendVerificationCode.parse(reader)
        })
    }
    
    static func getDeleteAccountInfo() -> DeleteAccountValue<Api.Response.DeleteAccountResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 101000,
            "data": [:]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "deleteAccount.deleteAccountRequest",
            parameters: [("data", String(describing: dict))]
        )
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Response.DeleteAccountResponse? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Api.Response.DeleteAccountResponse.parse(reader)
        })
    }
}
