load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load(
    "@build_bazel_rules_apple//apple:resources.bzl",
    "apple_resource_bundle",
    "apple_resource_group",
)
load("//build-system/bazel-utils:plist_fragment.bzl",
    "plist_fragment",
)

filegroup(
    name = "ElloAppCallsUIMetalResources",
    srcs = glob([
        "Resources/**/*.metal",
    ]),
    visibility = ["//visibility:public"],
)

plist_fragment(
    name = "ElloAppCallsUIBundleInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>org.elloapp.ElloAppCallsUI</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>ElloAppCallsUI</string>
    """
)

apple_resource_bundle(
    name = "ElloAppCallsUIBundle",
    infoplists = [
        ":ElloAppCallsUIBundleInfoPlist",
    ],
    resources = [
        ":ElloAppCallsUIMetalResources",
    ],
)

swift_library(
    name = "ElloAppCallsUI",
    module_name = "ElloAppCallsUI",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
#        "-warnings-as-errors",
    ],
    data = [
        ":ElloAppCallsUIBundle",
    ],
    deps = [
    	"//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Display:Display",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/PhotoResources:PhotoResources",
        "//submodules/ElloAppNotices:ElloAppNotices",
        "//submodules/MediaPlayer:UniversalMediaPlayer",
        "//submodules/DeviceAccess:DeviceAccess",
        "//submodules/ElloAppAudio:ElloAppAudio",
        "//submodules/ElloAppVoip:ElloAppVoip",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/OverlayStatusController:OverlayStatusController",
        "//submodules/AppBundle:AppBundle",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/ElloAppCallsUI/CallsEmoji:CallsEmoji",
        "//submodules/SemanticStatusNode:SemanticStatusNode",
        "//submodules/TooltipUI:TooltipUI",
        "//submodules/ItemListPeerItem:ItemListPeerItem",
        "//submodules/MergeLists:MergeLists",
        "//submodules/RadialStatusNode:RadialStatusNode",
        "//submodules/ContextUI:ContextUI",
        "//submodules/ShareController:ShareController",
        "//submodules/LegacyComponents:LegacyComponents",
        "//submodules/DeleteChatPeerActionSheetItem:DeleteChatPeerActionSheetItem",
        "//submodules/AnimationUI:AnimationUI",
        "//submodules/UndoUI:UndoUI",
        "//submodules/AudioBlob:AudioBlob",
        "//submodules/AnimatedAvatarSetNode:AnimatedAvatarSetNode",
        "//submodules/AlertUI:AlertUI",
        "//submodules/DirectionalPanGesture:DirectionalPanGesture",
        "//submodules/PeerInfoUI:PeerInfoUI",
        "//submodules/AnimatedCountLabelNode:AnimatedCountLabelNode",
        "//submodules/DeviceProximity:DeviceProximity",
        "//submodules/ManagedAnimationNode:ManagedAnimationNode",
        "//submodules/TemporaryCachedPeerDataManager:TemporaryCachedPeerDataManager",
        "//submodules/PeerInfoAvatarListNode:PeerInfoAvatarListNode",
        "//submodules/WebSearchUI:WebSearchUI",
        "//submodules/MapResourceToAvatarSizes:MapResourceToAvatarSizes",
        "//submodules/TextFormat:TextFormat",
        "//submodules/Markdown:Markdown",
        "//submodules/ChatTitleActivityNode:ChatTitleActivityNode",
        "//third-party/libyuv:LibYuvBinding",
        "//submodules/ComponentFlow:ComponentFlow",
        "//submodules/Components/LottieAnimationComponent:LottieAnimationComponent",
        "//submodules/Components/ActivityIndicatorComponent:ActivityIndicatorComponent",
        "//submodules/Components/ViewControllerComponent:ViewControllerComponent",
        "//submodules/Components/BundleIconComponent:BundleIconComponent",
        "//submodules/Components/MultilineTextComponent:MultilineTextComponent",
        "//submodules/Components/UndoPanelComponent:UndoPanelComponent",
        "//submodules/Components/HierarchyTrackingLayer:HierarchyTrackingLayer",
        "//submodules/PeerInfoUI/CreateExternalMediaStreamScreen:CreateExternalMediaStreamScreen",
        "//submodules/PhoneNumberFormat:PhoneNumberFormat",
    ],
    visibility = [
        "//visibility:public",
    ],
)
