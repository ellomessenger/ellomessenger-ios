//
//  MTProtoClient.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

protocol MTProtoClient {
    func sendRequest<T: MTProtoResponse>(endpoint: Endpoint) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
}

extension MTProtoClient {
    func sendRequest<T: MTProtoResponse>(endpoint: Endpoint) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<T>) {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": endpoint.service.rawValue,
            "method": endpoint.method.rawValue,
            "data": endpoint.data
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "\(endpoint.service): \(endpoint.method)",
            parameters: [("data", dict)]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> T? in
            let reader = BufferReader(buffer)
            
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return T.parse(reader)
        })
    }
}
