import Foundation
import Postbox
import SwiftSignalKit

public struct WallpapersState: Codable, Equatable {
    public var wallpapers: [ElloAppWallpaper]

    public static var `default`: WallpapersState {
        return WallpapersState(wallpapers: [])
    }

    public init(wallpapers: [ElloAppWallpaper]) {
        self.wallpapers = wallpapers
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        let wallpapersData = try container.decode([Data].self, forKey: "wallpapers")
        self.wallpapers = wallpapersData.map { data in
            return (try! AdaptedPostboxDecoder().decode(ElloAppWallpaperNativeCodable.self, from: data)).value
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        let wallpapersData: [Data] = self.wallpapers.map { wallpaper in
            return try! AdaptedPostboxEncoder().encode(ElloAppWallpaperNativeCodable(wallpaper))
        }

        try container.encode(wallpapersData, forKey: "wallpapers")
    }
}

public extension WallpapersState {
    static func update(transaction: AccountManagerModifier<ElloAppAccountManagerTypes>, _ f: (WallpapersState) -> WallpapersState) {
        transaction.updateSharedData(SharedDataKeys.wallapersState, { current in
            let item = (transaction.getSharedData(SharedDataKeys.wallapersState)?.get(WallpapersState.self)) ?? WallpapersState(wallpapers: [])
            return PreferencesEntry(f(item))
        })
    }
}
