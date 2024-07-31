//
//  Api36.swift
//  _idx_ElloAppApi_AAD17D6E_ios_min14.0
//
//

import Foundation

// MARK: - Update Profile

public extension Api.updateProfile {
    typealias UpdateProfileValue<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
        
    static func updateProfile(_ firstName: String, lastName: String?, about: String?, birthday: String?, country: String?, gender: String?, username: String?) -> UpdateProfileValue<Api.Response.BaseResponse> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        let data = [
            "first_name": firstName,
            "last_name": lastName,
            "bio": about,
            "gender": gender,
            "birthday": birthday,
            "country_code": country,
            "username": username
        ].compactMapValues { $0 }
        let dict: [String: Any] = [
            "service": 100300,
            "method": 100300,  // Change profile
            "data": data
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "updateProfile.updateProfile",
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
