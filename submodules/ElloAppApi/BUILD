load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppApi",
    module_name = "ElloAppApi",
    copts = [
        "-warnings-as-errors",
    ],
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    visibility = [
        "//visibility:public",
    ],
)
