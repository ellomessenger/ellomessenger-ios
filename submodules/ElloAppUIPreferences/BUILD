load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppUIPreferences",
    module_name = "ElloAppUIPreferences",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/Postbox:Postbox",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Display:Display",
    ],
    visibility = [
        "//visibility:public",
    ],
)
