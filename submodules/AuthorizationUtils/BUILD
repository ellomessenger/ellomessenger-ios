load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "AuthorizationUtils",
    module_name = "AuthorizationUtils",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/Display:Display",
        "//submodules/TextFormat:TextFormat",
        "//submodules/Markdown:Markdown",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
    ],
    visibility = [
        "//visibility:public",
    ],
)
