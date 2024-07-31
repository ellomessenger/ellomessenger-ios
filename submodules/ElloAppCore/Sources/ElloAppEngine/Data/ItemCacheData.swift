import SwiftSignalKit
import Postbox

public extension ElloAppEngine.EngineData.Item {
    enum ItemCache {
        public struct Item: ElloAppEngineDataItem, PostboxViewDataItem {
            public typealias Result = CodableEntry?

            private let collectionId: Int8
            private let id: ValueBoxKey

            public init(collectionId: Int8, id: ValueBoxKey) {
                self.collectionId = collectionId
                self.id = id
            }

            var key: PostboxViewKey {
                return .cachedItem(ItemCacheEntryId(collectionId: collectionId, key: self.id))
            }

            func extract(view: PostboxView) -> Result {
                guard let view = view as? CachedItemView else {
                    preconditionFailure()
                }
                return view.value
            }
        }
    }
}
