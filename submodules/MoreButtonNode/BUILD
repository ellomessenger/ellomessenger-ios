load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "MoreButtonNode",
    module_name = "MoreButtonNode",
    srcs = glob([
		"Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/Display:Display",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ManagedAnimationNode:ManagedAnimationNode",
        "//submodules/ContextUI:ContextUI",
    ],
    visibility = [
        "//visibility:public",
    ],
)
