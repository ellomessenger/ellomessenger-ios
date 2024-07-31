//
//  MTProtoResponse.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

public protocol MTProtoResponse: Hashable, Codable, ReflectedStringConvertible {
    static func parse(_ reader: BufferReader) -> Self?
}

public extension MTProtoResponse {
    static func parse(_ reader: BufferReader) -> Self? {
        reader.reset()
        _ = reader.readInt32()
        
        let _2 = parseString(reader)
        debugPrint(_2 as AnyObject)
        
        guard let jsonData = _2?.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Self.self, from: jsonData)
        } catch {
            debugPrint("\(#function) Error: \(error)")
            return nil
        }
    }
}
