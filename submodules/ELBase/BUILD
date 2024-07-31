
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

minimum_os_version = "15.0"

filegroup(
    name = "ELBase_Resources",
    srcs = glob([
        "Resources/Strings/**",
    ]),
    visibility = ["//ELBase:__pkg__"],
)

swift_library(
    name = "ELBase",
    module_name = "ELBase",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/Display:Display",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/AccountContext:AccountContext",
    ],
    data = [
        "ELBase_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)

