
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

minimum_os_version = "15.0"

filegroup(
    name = "ELLanguageUI_Assets",
    srcs = glob(["Assets.xcassets/**"]),
    visibility = ["//ELLanguageUI:__pkg__"],
)

filegroup(
    name = "ELLanguageUI_Resources",
    srcs = glob([
        "Resources/Storyboards/**",
        "Resources/Xibs/**",
    ]),
    visibility = ["//ELLanguageUI:__pkg__"],
)

swift_library(
    name = "ELLanguageUI",
    module_name = "ELLanguageUI",
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
        "//submodules/ELCommonUI",
    ],
    data = [
        "ELLanguageUI_Assets",
        "ELLanguageUI_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)
