import Foundation
import UIKit
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppUIPreferences

private struct WebSearchRecentQueryItemId {
    public let rawValue: MemoryBuffer
    
    var value: String {
        return String(data: self.rawValue.makeData(), encoding: .utf8) ?? ""
    }
    
    init(_ rawValue: MemoryBuffer) {
        self.rawValue = rawValue
    }
    
    init?(_ value: String) {
        if let data = value.data(using: .utf8) {
            self.rawValue = MemoryBuffer(data: data)
        } else {
            return nil
        }
    }
}

public final class RecentWebSearchQueryItem: Codable {
    init() {
    }
    
    public init(from decoder: Decoder) throws {
    }
    
    public func encode(to encoder: Encoder) throws {
    }
}

func addRecentWebSearchQuery(engine: ElloAppEngine, string: String) -> Signal<Never, NoError> {
    if let itemId = WebSearchRecentQueryItemId(string) {
        return engine.orderedLists.addOrMoveToFirstPosition(collectionId: ApplicationSpecificOrderedItemListCollectionId.webSearchRecentQueries, id: itemId.rawValue, item: RecentWebSearchQueryItem(), removeTailIfCountExceeds: 100)
    } else {
        return .complete()
    }
}

func removeRecentWebSearchQuery(engine: ElloAppEngine, string: String) -> Signal<Never, NoError> {
    if let itemId = WebSearchRecentQueryItemId(string) {
        return engine.orderedLists.removeItem(collectionId: ApplicationSpecificOrderedItemListCollectionId.webSearchRecentQueries, id: itemId.rawValue)
    } else {
        return .complete()
    }
}

func clearRecentWebSearchQueries(engine: ElloAppEngine) -> Signal<Never, NoError> {
    return engine.orderedLists.clear(collectionId: ApplicationSpecificOrderedItemListCollectionId.webSearchRecentQueries)
}

func webSearchRecentQueries(engine: ElloAppEngine) -> Signal<[String], NoError> {
    return engine.data.subscribe(ElloAppEngine.EngineData.Item.OrderedLists.ListItems(collectionId: ApplicationSpecificOrderedItemListCollectionId.webSearchRecentQueries))
    |> map { items -> [String] in
        var result: [String] = []
        for item in items {
            let value = WebSearchRecentQueryItemId(item.id).value
            result.append(value)
        }
        return result
    }
}
