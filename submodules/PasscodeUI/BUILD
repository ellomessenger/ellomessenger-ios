load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "PasscodeUI",
    module_name = "PasscodeUI",
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
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/AccountContext:AccountContext",
        "//submodules/LocalAuth:LocalAuth",
        "//submodules/LegacyComponents:LegacyComponents",
        "//submodules/ElloAppStringFormatting:ElloAppStringFormatting",
        "//submodules/ImageBlur:ImageBlur",
        "//submodules/AppBundle:AppBundle",
        "//submodules/PasscodeInputFieldNode:PasscodeInputFieldNode",
        "//submodules/MonotonicTime:MonotonicTime",
        "//submodules/GradientBackground:GradientBackground",
    ],
    visibility = [
        "//visibility:public",
    ],
)
