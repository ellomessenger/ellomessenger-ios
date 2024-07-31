load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

minimum_os_version = "15.0"

filegroup(
    name = "ELWelcomeUIAssets",
    srcs = glob(["ELWelcomeUIAssets.xcassets/**"]),
    visibility = ["//ELWelcomeUI:__pkg__"],
)

filegroup(
    name = "Storyboards",
    srcs = glob([
        "Storyboards/**",
    ]),
    visibility = ["//ELWelcomeUI:__pkg__"],
)

filegroup(
    name = "ELRegisterController",
    srcs = glob([
        "Sources/ViewControllers/ELRegisterController.swift",
    ]),
    visibility = ["//ELWelcomeUI:__pkg__"],
)

swift_library(
    name = "ELWelcomeUI",
    module_name = "ELWelcomeUI",
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
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/AccountContext:AccountContext",
        
        "//submodules/ELBase",
        "//submodules/ELLanguageUI",
        "//submodules/ELCommonUI",
        "//submodules/ELProfileUI",
    ],
    data = [
        "ELWelcomeUIAssets",
        "Storyboards",
    ],
    visibility = [
        "//visibility:public",
    ],
)
