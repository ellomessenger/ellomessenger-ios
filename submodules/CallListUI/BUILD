load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "CallListUI",
    module_name = "CallListUI",
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
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/AvatarNode:AvatarNode",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/AlertUI:AlertUI",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/ElloAppNotices:ElloAppNotices",
        "//submodules/MergeLists:MergeLists",
        "//submodules/ChatListSearchItemHeader:ChatListSearchItemHeader",
        "//submodules/PeerOnlineMarkerNode:PeerOnlineMarkerNode",
        "//submodules/ContextUI:ContextUI",
        "//submodules/ElloAppBaseController:ElloAppBaseController",
        "//submodules/AnimatedStickerNode:AnimatedStickerNode",
        "//submodules/ElloAppAnimatedStickerNode:ElloAppAnimatedStickerNode",
    ],
    visibility = [
        "//visibility:public",
    ],
)
