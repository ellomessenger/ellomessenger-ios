load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ReactionListContextMenuContent",
    module_name = "ReactionListContextMenuContent",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/Display:Display",
        "//submodules/ComponentFlow:ComponentFlow",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/WebPBinding:WebPBinding",
        "//submodules/AnimatedAvatarSetNode:AnimatedAvatarSetNode",
        "//submodules/ContextUI:ContextUI",
        "//submodules/AvatarNode:AvatarNode",
        "//submodules/Components/ReactionImageComponent:ReactionImageComponent",
        "//submodules/ElloAppUI/Components/AnimationCache:AnimationCache",
        "//submodules/ElloAppUI/Components/MultiAnimationRenderer:MultiAnimationRenderer",
        "//submodules/ElloAppUI/Components/EmojiTextAttachmentView:EmojiTextAttachmentView",
        "//submodules/ElloAppUI/Components/EmojiStatusComponent:EmojiStatusComponent",
        "//submodules/TextFormat:TextFormat",
    ],
    visibility = [
        "//visibility:public",
    ],
)
