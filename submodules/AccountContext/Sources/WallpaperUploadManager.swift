import Foundation
import SwiftSignalKit
import ElloAppCore
import ElloAppPresentationData

public enum WallpaperUploadManagerStatus {
    case none
    case uploading(ElloAppWallpaper, Float)
    case uploaded(ElloAppWallpaper, ElloAppWallpaper)
    
    public var wallpaper: ElloAppWallpaper? {
        switch self {
        case let .uploading(wallpaper, _), let .uploaded(wallpaper, _):
            return wallpaper
        default:
            return nil
        }
    }
}

public protocol WallpaperUploadManager: AnyObject {
    func stateSignal() -> Signal<WallpaperUploadManagerStatus, NoError>
    func presentationDataUpdated(_ presentationData: PresentationData)
}
