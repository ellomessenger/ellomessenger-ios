load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "AuthorizationUI",
    module_name = "AuthorizationUI",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
#        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/Postbox:Postbox",
        "//submodules/Display:Display",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/TextFormat:TextFormat",
        "//submodules/Markdown:Markdown",
        "//submodules/ElloAppPresentationData:ElloAppPresentationData",
        "//submodules/AccountContext:AccountContext",
        "//submodules/CountrySelectionUI:CountrySelectionUI",
        "//submodules/PhoneNumberFormat:PhoneNumberFormat",
        "//submodules/LegacyComponents:LegacyComponents",
        "//submodules/LegacyMediaPickerUI:LegacyMediaPickerUI",
        "//submodules/PasswordSetupUI:PasswordSetupUI",
        "//submodules/ElloAppNotices:ElloAppNotices",
        "//submodules/ProgressNavigationButtonNode:ProgressNavigationButtonNode",
        "//submodules/AnimatedStickerNode:AnimatedStickerNode",
        "//submodules/ElloAppAnimatedStickerNode:ElloAppAnimatedStickerNode",
        "//submodules/SolidRoundedButtonNode:SolidRoundedButtonNode",
        "//submodules/ImageCompression:ImageCompression",
        "//submodules/RMIntro:RMIntro",
        "//submodules/QrCode:QrCode",
        "//submodules/PhoneInputNode:PhoneInputNode",
        "//submodules/CodeInputView:CodeInputView",
        "//submodules/DebugSettingsUI:DebugSettingsUI",
        "//submodules/InvisibleInkDustNode:InvisibleInkDustNode",
        "//submodules/AuthorizationUtils:AuthorizationUtils",
        "//submodules/ManagedAnimationNode:ManagedAnimationNode",
        
        "//submodules/ELWelcomeUI",
    ],
    visibility = [
        "//visibility:public",
    ],
)
