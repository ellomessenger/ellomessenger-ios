load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppUpdateUI",
    module_name = "ElloAppUpdateUI",
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
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
    ],
    visibility = [
        "//visibility:public",
    ],
)
