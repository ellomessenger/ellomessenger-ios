load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "ELContactsUI_Assets",
    srcs = glob(["ELContactsUIAssets.xcassets/**"]),
    visibility = ["//ELContactsUI:__pkg__"],
)

filegroup(
    name = "ELContactsUI_Resources",
    srcs = glob([
        "Resources/Storyboards/**",
    ]),
    visibility = ["//ELContactsUI:__pkg__"],
)

swift_library(
    name = "ELContactsUI",
    module_name = "ELContactsUI",
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
        "//submodules/ElloAppIntents",
    ],
    data = [
        "ELContactsUI_Assets",
        "ELContactsUI_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)

