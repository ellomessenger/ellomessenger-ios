load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ContactListUI",
    module_name = "ContactListUI",
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
        "//submodules/MergeLists:MergeLists",
        "//submodules/SearchUI:SearchUI",
        "//submodules/ChatListSearchItemHeader:ChatListSearchItemHeader",
        "//submodules/ItemListPeerItem:ItemListPeerItem",
        "//submodules/ContactsPeerItem:ContactsPeerItem",
        "//submodules/ChatListSearchItemNode:ChatListSearchItemNode",
        "//submodules/ElloAppPermissionsUI:ElloAppPermissionsUI",
        "//submodules/ElloAppNotices:ElloAppNotices",
        "//submodules/AlertUI:AlertUI",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/ShareController:ShareController",
        "//submodules/AppBundle:AppBundle",
        "//submodules/OverlayStatusController:OverlayStatusController",
        "//submodules/PhoneNumberFormat:PhoneNumberFormat",
        "//submodules/SolidRoundedButtonNode:SolidRoundedButtonNode",
        "//submodules/StickerResources:StickerResources",
        "//submodules/AnimatedStickerNode:AnimatedStickerNode",
        "//submodules/ElloAppAnimatedStickerNode:ElloAppAnimatedStickerNode",
        "//submodules/QrCodeUI:QrCodeUI",
    ],
    visibility = [
        "//visibility:public",
    ],
)
