load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "EmojiSuggestionsComponent",
    module_name = "EmojiSuggestionsComponent",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Display:Display",
        "//submodules/ComponentFlow:ComponentFlow",
        "//submodules/ElloAppUI/Components/AnimationCache:AnimationCache",
        "//submodules/ElloAppUI/Components/MultiAnimationRenderer:MultiAnimationRenderer",
        "//submodules/ElloAppUI/Components/EmojiTextAttachmentView:EmojiTextAttachmentView",
        "//submodules/AccountContext:AccountContext",
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/TextFormat:TextFormat",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
    ],
    visibility = [
        "//visibility:public",
    ],
)
