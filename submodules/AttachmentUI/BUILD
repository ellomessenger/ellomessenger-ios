load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "AttachmentUI",
    module_name = "AttachmentUI",
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
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/AccountContext:AccountContext",
        "//submodules/LegacyComponents:LegacyComponents",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/AppBundle:AppBundle",
        "//submodules/ComponentFlow:ComponentFlow",
        "//submodules/UIKitRuntimeUtils:UIKitRuntimeUtils",
        "//submodules/DirectionalPanGesture:DirectionalPanGesture",
        "//submodules/AttachmentTextInputPanelNode:AttachmentTextInputPanelNode",
        "//submodules/ChatSendMessageActionUI:ChatSendMessageActionUI",
        "//submodules/ChatTextLinkEditUI:ChatTextLinkEditUI",
        "//submodules/ContextUI:ContextUI",
        "//submodules/ManagedAnimationNode:ManagedAnimationNode",
        "//submodules/PhotoResources:PhotoResources",
        "//submodules/MediaResources:MediaResources",
        "//submodules/SemanticStatusNode:SemanticStatusNode",
        "//submodules/MoreButtonNode:MoreButtonNode",
        "//submodules/Components/AnimatedStickerComponent:AnimatedStickerComponent",
        "//submodules/Components/MultilineTextComponent:MultilineTextComponent",
    ],
    visibility = [
        "//visibility:public",
    ],
)
