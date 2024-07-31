load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "NotificationServiceExtensionLib_Resources",
    srcs = glob([
        "Resources/**",
    ]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "NotificationServiceExtensionLib",
    module_name = "NotificationServiceExtensionLib",
    srcs = glob([
        "Sources/*.swift",
    ]),
    deps = [
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/BuildConfig:BuildConfig",
        "//submodules/MtProtoKit:MtProtoKit",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/EncryptionProvider:EncryptionProvider",
        "//submodules/AppLockState:AppLockState",
        "//submodules/NotificationsPresentationData:NotificationsPresentationData",
        "//submodules/ElloAppUIPreferences:ElloAppUIPreferences",
        "//submodules/OpenSSLEncryptionProvider:OpenSSLEncryptionProvider",
        "//submodules/WebPBinding:WebPBinding",
        "//submodules/rlottie:RLottieBinding",
        "//submodules/GZip:GZip",
        "//submodules/PersistentStringHash:PersistentStringHash",
    
    ],
    data = [
        "NotificationServiceExtensionLib_Resources",
    ],
    visibility = [
        "//visibility:public",
    ],
)
