load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ListMessageItem",
    module_name = "ListMessageItem",
    srcs = glob([
		"Sources/**/*.swift",
    ]),
    copts = [
#        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/Display:Display",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/AccountContext:AccountContext",
        "//submodules/TextFormat:TextFormat",
        "//submodules/AppBundle:AppBundle",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/ListSectionHeaderNode:ListSectionHeaderNode",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/UrlHandling:UrlHandling",
        "//submodules/UrlWhitelist:UrlWhitelist",
        "//submodules/WebsiteType:WebsiteType",
        "//submodules/PhotoResources:PhotoResources",
        "//submodules/RadialStatusNode:RadialStatusNode",
        "//submodules/SemanticStatusNode:SemanticStatusNode",
        "//submodules/MusicAlbumArtResources:MusicAlbumArtResources",
        "//submodules/MediaPlayer:UniversalMediaPlayer",
        "//submodules/ContextUI:ContextUI",
        "//submodules/FileMediaResourceStatus:FileMediaResourceStatus",
        "//submodules/ManagedAnimationNode:ManagedAnimationNode",
        "//submodules/WallpaperResources:WallpaperResources",
        "//submodules/Postbox:Postbox",
        "//submodules/ShimmerEffect:ShimmerEffect",
    ],
    visibility = [
        "//visibility:public",
    ],
)
