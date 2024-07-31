load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "TemporaryCachedPeerDataManager",
    module_name = "TemporaryCachedPeerDataManager",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/Postbox:Postbox",
    ],
    visibility = [
        "//visibility:public",
    ],
)
