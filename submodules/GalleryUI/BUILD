load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "GalleryUI",
    module_name = "GalleryUI",
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
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/TextFormat:TextFormat",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ElloAppUniversalVideoContent:ElloAppUniversalVideoContent",
        "//submodules/WebsiteType:WebsiteType",
        "//submodules/ScreenCaptureDetection:ScreenCaptureDetection",
        "//submodules/OpenInExternalAppUI:OpenInExternalAppUI",
        "//submodules/ShareController:ShareController",
        "//submodules/SwipeToDismissGesture:SwipeToDismissGesture",
        "//submodules/CheckNode:CheckNode",
        "//submodules/AppBundle:AppBundle",
        "//submodules/StickerPackPreviewUI:StickerPackPreviewUI",
        "//submodules/OverlayStatusController:OverlayStatusController",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/UrlEscaping:UrlEscaping",
        "//submodules/ManagedAnimationNode:ManagedAnimationNode",
        "//submodules/ContextUI:ContextUI",
        "//submodules/SaveToCameraRoll:SaveToCameraRoll",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/ImageContentAnalysis:ImageContentAnalysis",
        "//submodules/TextSelectionNode:TextSelectionNode",
        "//submodules/Speak:Speak",
        "//submodules/UndoUI:UndoUI",
        "//submodules/InvisibleInkDustNode:InvisibleInkDustNode",
        "//submodules/TranslateUI:TranslateUI",
        "//submodules/Utils/RangeSet:RangeSet",
        "//submodules/ElloAppUI/Components/TextNodeWithEntities:TextNodeWithEntities",
        "//submodules/ElloAppUI/Components/AnimationCache:AnimationCache",
        "//submodules/ElloAppUI/Components/MultiAnimationRenderer:MultiAnimationRenderer",
    ],
    visibility = [
        "//visibility:public",
    ],
)
