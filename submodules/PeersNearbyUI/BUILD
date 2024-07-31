load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "PeersNearbyUI",
    module_name = "PeersNearbyUI",
    srcs = glob([
		"Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/Display:Display",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/OverlayStatusController:OverlayStatusController",
        "//submodules/DeviceLocationManager:DeviceLocationManager",
        "//submodules/AlertUI:AlertUI",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/ItemListPeerItem:ItemListPeerItem",
        "//submodules/ElloAppPermissionsUI:ElloAppPermissionsUI",
        "//submodules/ItemListPeerActionItem:ItemListPeerActionItem",
        "//submodules/PeersNearbyIconNode:PeersNearbyIconNode",
        "//submodules/Geocoding:Geocoding",
        "//submodules/AppBundle:AppBundle",
        "//submodules/AnimatedStickerNode:AnimatedStickerNode",
        "//submodules/ElloAppAnimatedStickerNode:ElloAppAnimatedStickerNode",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/ElloAppNotices:ElloAppNotices",
    ],
    visibility = [
        "//visibility:public",
    ],
)
