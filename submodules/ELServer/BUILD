load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ELServer",
    module_name = "ELServer",
    srcs = glob([
		"Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
