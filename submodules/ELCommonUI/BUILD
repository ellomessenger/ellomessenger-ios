
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

minimum_os_version = "15.0"

filegroup(
    name = "ELCommonUI_Assets",
    srcs = glob(["Assets.xcassets/**"]),
    visibility = [
    		"//visibility:public"
    ],
)

filegroup(
    name = "ELCommonUI_Resources",
    srcs = glob([
        "Resources/Storyboards/**",
        "Resources/Xibs/**",
    ]),
   visibility = [
    		"//visibility:public"
    ],
)

swift_library(
    name = "ELCommonUI",
    module_name = "ELCommonUI",
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
        "//submodules/lottie-ios:Lottie"
    ],
    data = [
        "ELCommonUI_Assets",
        "ELCommonUI_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)
