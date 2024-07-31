load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppPresentationData",
    module_name = "ElloAppPresentationData",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/Postbox:Postbox",
        "//submodules/Display:Display",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/MediaResources:MediaResources",
        "//submodules/AppBundle:AppBundle",
        "//submodules/StringPluralization:StringPluralization",
        "//submodules/Sunrise:Sunrise",
        "//submodules/TinyThumbnail:TinyThumbnail",
        "//ElloApp:PresentationStrings",
    ],
    visibility = [
        "//visibility:public",
    ],
)
