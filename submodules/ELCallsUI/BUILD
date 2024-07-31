
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "ELCallsUI_Assets",
    srcs = glob(["ELCallsUIAssets.xcassets/**"]),
    visibility = ["//ELCallsUI:__pkg__"],
)

filegroup(
    name = "ELCallsUI_Resources",
    srcs = glob([
        "Resources/Storyboards/**",
    ]),
    visibility = ["//ELCallsUI:__pkg__"],
)

swift_library(
    name = "ELCallsUI",
    module_name = "ELCallsUI",
     srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit",
        "//submodules/AsyncDisplayKit",
        "//submodules/Display",
        "//submodules/ElloAppCore",
        "//submodules/ElloAppPresentationData",
        "//submodules/ElloAppUIPreferences",
        "//submodules/AccountContext",
                
        "//submodules/ELBase",
        "//submodules/lottie-ios:Lottie",
    ],
    data = [
        "ELCallsUI_Assets",
        "ELCallsUI_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)
