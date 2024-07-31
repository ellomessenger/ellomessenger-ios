//
//  Api33.swift
//  _idx_ElloAppApi_50E079A9_ios_min11.0
//
//

import Foundation

// MARK: - Change Email

public extension Api.Response {
    struct SendVerificationCode: MTProtoResponse {
        public var status: Bool
        @DecodableDefault.EmptyString
        public var message: String
        @DecodableDefault.EmptyString
        public var email: String
        public var confirmation_expire: Int
        
        public static func parse(_ reader: BufferReader) -> SendVerificationCode? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            guard let jsonData = _2?.data(using: .utf8),
                  let object = try? JSONDecoder().decode(SendVerificationCode.self, from: jsonData) else {
                return nil
            }
            
            print(object)
            
            return object
        }
    }
    
    struct BaseResponse: Codable {
        public var status: Bool
        public var message: String
        
        static func parse(_ reader: BufferReader) -> BaseResponse? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            guard let jsonData = _2?.data(using: .utf8),
                  let object = try? JSONDecoder().decode(BaseResponse.self, from: jsonData) else {
                return nil
            }
            
            print(object)
            
            return object
        }
    }
    
    struct DeleteAccountResponse: MTProtoResponse {

        public struct PaidSubscriptionItems: MTProtoResponse {
            public struct Chat: MTProtoResponse {
                public var id: Int
                @DecodableDefault.EmptyString
                public var title: String
                @DecodableDefault.EmptyString
                public var username: String
                public var description: String?
            }
            
            @DecodableDefault.EmptyList
            public var chats: [Chat]
        }
        
        public struct AISubscriptionInfoItem: MTProtoResponse {
            @DecodableDefault.False
            public var easyMode: Bool
            @DecodableDefault.ZeroInt
            public var textTotal: Int
            @DecodableDefault.ZeroInt
            public var imgTotal: Int
        }
        
        @DecodableDefault.False
        public var status: Bool
        @DecodableDefault.EmptyString
        public var message: String
        public var wallets: WalletsItem
        public var paidChannelsOwner: DeleteAccountResponse.PaidSubscriptionItems
        public var paidChannelsSubscribe: DeleteAccountResponse.PaidSubscriptionItems
        public var aiSubInfo: DeleteAccountResponse.AISubscriptionInfoItem
        
        public static func parse(_ reader: BufferReader) -> Self? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            guard let jsonData = _2?.data(using: .utf8)else {
                return nil
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let object = try decoder.decode(DeleteAccountResponse.self, from: jsonData)
                print(object)
                
                return object
            } catch {
                print(error)
                return nil
            }
            
        }
    }
}

public extension Api.changeEmail {
    typealias ChangeEmailValue<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    static func changeEmailCode(_ email: String) -> ChangeEmailValue<Api.Response.SendVerificationCode> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100500,  // verification code
            "data": [
                "email": email, // or "azeezmakhmudov@gmail.com"
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "changeEmail.changeEmailCode",
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

// MARK: - Save new email
public extension Api.changeEmail {
    static func saveNewEmail(_ email: String, code: String) -> ChangeEmailValue<Api.Response.BaseResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100100,
            "data": [
                "new_email": email, // New email
                "code": code
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "changeEmail.changeEmail",
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
