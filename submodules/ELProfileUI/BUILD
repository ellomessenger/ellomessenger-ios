load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

minimum_os_version = "15.0"

filegroup(
    name = "ELProfileUI_Assets",
    srcs = glob([
        "Assets.xcassets/**",
        "Colors.xcassets/**"
    ]),
    visibility = ["//ELProfileUI:__pkg__"],
)

filegroup(
    name = "ELProfileUI_Resources",
    srcs = glob([
        "Resources/Storyboards/**",
        "Resources/Xibs/**",
    ]),
    visibility = ["//ELProfileUI:__pkg__"],
)

swift_library(
    name = "ELProfileUI",
    module_name = "ELProfileUI",
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
        "//submodules/ElloAppApi",
        "//submodules/ElloAppPresentationData",
        "//submodules/ElloAppUIPreferences",
        "//submodules/AccountContext",
        "//submodules/AvatarNode:AvatarNode",
        "//submodules/UndoUI",
        "//submodules/ElloAppCallsUI",
        "//submodules/ELBase",
        "//submodules/ElloAppUIPeerInfoItem",
        "//submodules/ELLanguageUI",
        "//submodules/ELCommonUI",
    ],
    data = [
        "ELProfileUI_Assets",
        "ELProfileUI_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)

