load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "TextNodeWithEntities",
    module_name = "TextNodeWithEntities",
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
        "//submodules/TextFormat:TextFormat",
        "//submodules/ElloAppUI/Components/EmojiTextAttachmentView:EmojiTextAttachmentView",
        "//submodules/ElloAppUI/Components/AnimationCache:AnimationCache",
        "//submodules/ElloAppUI/Components/MultiAnimationRenderer:MultiAnimationRenderer",
    ],
    visibility = [
        "//visibility:public",
    ],
)
