load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ElloAppCore",
    module_name = "ElloAppCore",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
#        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppApi:ElloAppApi",
        "//submodules/MtProtoKit:MtProtoKit",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Postbox:Postbox",
        "//submodules/CloudData:CloudData",
        "//submodules/EncryptionProvider:EncryptionProvider",
        "//submodules/CryptoUtils:CryptoUtils",
        "//submodules/NetworkLogging:NetworkLogging",
        "//submodules/Reachability:Reachability",
        "//submodules/ManagedFile:ManagedFile",
        "//submodules/Utils/RangeSet:RangeSet",
        "//submodules/ELServer:ELServer",
    ],
    visibility = [
        "//visibility:public",
    ],
)
