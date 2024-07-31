load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppPermissionsUI",
    module_name = "ElloAppPermissionsUI",
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
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/AccountContext:AccountContext",
        "//submodules/TextFormat:TextFormat",
        "//submodules/Markdown:Markdown",
        "//submodules/ElloAppPermissions:ElloAppPermissions",
        "//submodules/DeviceAccess:DeviceAccess",
        "//submodules/PeersNearbyIconNode:PeersNearbyIconNode",
        "//submodules/SolidRoundedButtonNode:SolidRoundedButtonNode",
        "//submodules/AppBundle:AppBundle",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/AnimatedStickerNode:AnimatedStickerNode",
        "//submodules/ElloAppAnimatedStickerNode:ElloAppAnimatedStickerNode",
    ],
    visibility = [
        "//visibility:public",
    ],
)
