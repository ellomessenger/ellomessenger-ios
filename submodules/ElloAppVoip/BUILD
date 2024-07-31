load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppVoip",
    module_name = "ElloAppVoip",
    srcs = glob([
        "Sources/**/*.swift",
    ], exclude = [
        "Sources/macOS/**/*",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/TgVoip:TgVoip",
        "//submodules/TgVoipWebrtc:TgVoipWebrtc",
    ],
    visibility = [
        "//visibility:public",
    ],
)
