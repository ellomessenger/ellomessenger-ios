import Foundation
import UIKit
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppUIPreferences

private struct SettingsSearchRecentQueryItemId {
    public let rawValue: MemoryBuffer
    
    var value: Int64 {
        return self.rawValue.makeData().withUnsafeBytes { buffer -> Int64 in
            guard let bytes = buffer.baseAddress?.assumingMemoryBound(to: Int64.self) else {
                return 0
            }
            return bytes.pointee
        }
    }
    
    init(_ rawValue: MemoryBuffer) {
        self.rawValue = rawValue
    }
    
    init(_ value: Int64) {
        var value = value
        self.rawValue = MemoryBuffer(data: Data(bytes: &value, count: MemoryLayout.size(ofValue: value)))
    }
}

public final class RecentSettingsSearchQueryItem: Codable {
    public init() {
    }
    
    public init(from decoder: Decoder) throws {
    }
    
    public func encode(to encoder: Encoder) throws {
    }
}

func addRecentSettingsSearchItem(engine: ElloAppEngine, item: SettingsSearchableItemId) {
    let itemId = SettingsSearchRecentQueryItemId(item.index)
    let _ = engine.orderedLists.addOrMoveToFirstPosition(collectionId: ApplicationSpecificOrderedItemListCollectionId.settingsSearchRecentItems, id: itemId.rawValue, item: RecentSettingsSearchQueryItem(), removeTailIfCountExceeds: 100).start()
}

func removeRecentSettingsSearchItem(engine: ElloAppEngine, item: SettingsSearchableItemId) {
    let itemId = SettingsSearchRecentQueryItemId(item.index)
    let _ = engine.orderedLists.removeItem(collectionId: ApplicationSpecificOrderedItemListCollectionId.settingsSearchRecentItems, id: itemId.rawValue).start()
}

func clearRecentSettingsSearchItems(engine: ElloAppEngine) {
    let _ = engine.orderedLists.clear(collectionId: ApplicationSpecificOrderedItemListCollectionId.settingsSearchRecentItems).start()
}

func settingsSearchRecentItems(engine: ElloAppEngine) -> Signal<[SettingsSearchableItemId], NoError> {
    return engine.data.subscribe(ElloAppEngine.EngineData.Item.OrderedLists.ListItems(collectionId: ApplicationSpecificOrderedItemListCollectionId.settingsSearchRecentItems))
    |> map { items -> [SettingsSearchableItemId] in
        var result: [SettingsSearchableItemId] = []
        for item in items {
            let index = SettingsSearchRecentQueryItemId(item.id).value
            if let itemId = SettingsSearchableItemId(index: index) {
                result.append(itemId)
            }
        }
        return result
    }
}
