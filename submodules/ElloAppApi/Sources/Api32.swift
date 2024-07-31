//
//  Api31.swift
//  _idx_ElloAppApi_4F23D8A3_ios_min11.0
//
//

import Foundation

// MARK: - Feeds
public extension Api {
    indirect enum Feeds: TypeConstructorDescription {
        case feedMessages(messages: [Api.Message], chats: [Api.Chat])
        
        public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
            switch self {
            case .feedMessages(let messages, let chats):
                if boxed {
                    buffer.appendInt32(1001001002)
                }
                buffer.appendInt32(481674261)
                buffer.appendInt32(Int32(messages.count))
                for item in messages {
                    item.serialize(buffer, true)
                }
                buffer.appendInt32(481674261)
                buffer.appendInt32(Int32(chats.count))
                for item in chats {
                    item.serialize(buffer, true)
                }
                break
                
            }
        }
        
        public func descriptionFields() -> (String, [(String, Any)]) {
            switch self {
            case .feedMessages(let messages, let chats):
                return ("feedMessages", [("messages", String(describing: messages)), ("chats", String(describing: chats))])
                
            }
        }
        
        public static func parse_historyMessages(_ reader: BufferReader) -> Feeds? {
            var _5: [Api.Message]?
            if let _ = reader.readInt32() {
                _5 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Message.self)
            }
            var _6: [Api.Chat]?
            if let _ = reader.readInt32() {
                _6 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            
            guard let _5, let _6 else {
                return nil
            }
            
            return Api.Feeds.feedMessages( messages: _5, chats: _6)
        }
        
        
    }
}

/// Feed list
public extension Api.functions.feeds {
    static func readHistory(page: Int32, limit: Int32, isFeedExplore: Bool = false) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<Api.Feeds>) {
        let buffer = Buffer()
        buffer.appendInt32(1001001001)
        serializeInt32(page, buffer: buffer, boxed: false)
        serializeInt32(limit, buffer: buffer, boxed: false)
        
        var flags: Int32 = 0
        if isFeedExplore {
            flags |= 1 << 2
        }
        serializeInt32(flags, buffer: buffer, boxed: false)
        
        return (FunctionDescription(name: "feeds.readHistory", parameters: [("page", String(describing: page)), ("limit", String(describing: limit)), ("isFeedExplore", String(describing: isFeedExplore))]), buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Feeds? in
            let reader = BufferReader(buffer)
            var result: Api.Feeds?
            if let signature = reader.readInt32() {
                result = Api.parse(reader, signature: signature) as? Api.Feeds
            }
            return result
        })
    }
}

/// Feed settings get filters
public extension Api.functions.feeds {
    static func getFeedFilter() -> (FunctionDescription, Buffer, DeserializeFunctionResponse<FeedFilterResponse>) {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": 100100,
            "method": 100100,
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "feeds.getFeedFilter",
            parameters: [("data", String(describing: dict))]
        )
        
        let deserializeFunctionResponse = DeserializeFunctionResponse { (buffer: Buffer) -> FeedFilterResponse? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return FeedFilterResponse.parse(reader)
        }
        
        return (functionDescription, buffer, deserializeFunctionResponse)
    }
    
    struct FeedFilterResponse: Codable {
        @DecodableDefault.EmptyList public var all: [Int]
        @DecodableDefault.EmptyList public var hidden: [Int]
        @DecodableDefault.EmptyList public var pinned: [Int]
        @DecodableDefault.False public var showRecommended: Bool
        @DecodableDefault.False public var showOnlySubscriptions: Bool
        @DecodableDefault.False public var showAdult: Bool
        
        enum CodingKeys: String, CodingKey {
            case all, hidden, pinned, showRecommended, showOnlySubscriptions = "showOnlySubs", showAdult
        }
        
        public static func parse(_ reader: BufferReader) -> FeedFilterResponse? {
            reader.reset()
            _ = reader.readInt32()
            
            let readerString = parseString(reader)
            debugPrint(readerString ?? "Empty string")
            guard let jsonData = readerString?.data(using: .utf8) else {
                return nil
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let responseObject = try decoder.decode(FeedFilterResponse.self, from: jsonData)
                return responseObject
            } catch {
                debugPrint(error)
                return nil
            }
        }
    }
}

/// Feed settings get filters
public extension Api.functions.feeds {
    static func updateFeedFilter(with filterItem: [String: Any]) -> (FunctionDescription, Buffer, DeserializeFunctionResponse<UpdateFeedFilterResponse>) {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
//        [
//            "hidden": filterItem.hidden,
//            "pinned": filterItem.pinned,
//            "show_only_subs": filterItem.showOnlySubscriptions,
//            "show_recommended": filterItem.showRecommended,
//            "show_adult": filterItem.showAdult
//        ]
        let dict: [String: Any] = [
            "service": 100100,
            "method": 100200,
            "data": filterItem
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "feeds.updateFeedFilter",
            parameters: [("data", String(describing: dict))]
        )
        
        let deserializeFunctionResponse = DeserializeFunctionResponse { (buffer: Buffer) -> UpdateFeedFilterResponse? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return UpdateFeedFilterResponse.parse(reader)
        }
        
        return (functionDescription, buffer, deserializeFunctionResponse)
    }
    
    struct UpdateFeedFilterItem: Encodable {
        public var hidden: [Int]
        public var pinned: [Int]
        public var showRecommended: Bool
        public var showOnlySubscriptions: Bool
        public var showAdult: Bool
        
        enum CodingKeys: String, CodingKey {
            case hidden, pinned, showRecommended, showOnlySubscriptions = "showOnlySubs", showAdult
        }
        
        public init(hidden: [Int], pinned: [Int], showRecommended: Bool, showOnlySubscriptions: Bool, showAdult: Bool) {
            self.hidden = hidden
            self.pinned = pinned
            self.showRecommended = showRecommended
            self.showOnlySubscriptions = showOnlySubscriptions
            self.showAdult = showAdult
        }
    }
    
    struct UpdateFeedFilterResponse: Codable {
        @DecodableDefault.False public var status: Bool
        
        public static func parse(_ reader: BufferReader) -> UpdateFeedFilterResponse? {
            reader.reset()
            _ = reader.readInt32()
            
            let readerString = parseString(reader)
            debugPrint(readerString ?? "Empty string")
            guard let jsonData = readerString?.data(using: .utf8) else {
                return nil
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let responseObject = try decoder.decode(UpdateFeedFilterResponse.self, from: jsonData)
                return responseObject
            } catch {
                debugPrint(error)
                return nil
            }
        }
    }
}
