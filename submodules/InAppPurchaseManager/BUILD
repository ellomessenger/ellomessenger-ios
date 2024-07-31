load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "InAppPurchaseManager",
    module_name = "InAppPurchaseManager",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
#        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/PersistentStringHash:PersistentStringHash",
    ],
    visibility = [
        "//visibility:public",
    ],
)
