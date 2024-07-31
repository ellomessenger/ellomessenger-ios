load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ItemListPeerItem",
    module_name = "ItemListPeerItem",
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
        "//submodules/AvatarNode:AvatarNode",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/PeerPresenceStatusManager:PeerPresenceStatusManager",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/ContextUI:ContextUI",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ComponentFlow:ComponentFlow",
        "//submodules/ElloAppUI/Components/EmojiStatusComponent:EmojiStatusComponent",
    ],
    visibility = [
        "//visibility:public",
    ],
)
