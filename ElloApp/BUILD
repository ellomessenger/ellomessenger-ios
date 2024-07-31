load("@bazel_skylib//rules:common_settings.bzl",
    "bool_flag",
)

load("@bazel_skylib//lib:selects.bzl", "selects")

load("@build_bazel_rules_apple//apple:ios.bzl",
    "ios_application",
    "ios_extension",
    "ios_framework",
    "ios_unit_test",
    "ios_ui_test",
)

load("@build_bazel_rules_apple//apple:resources.bzl",
    "swift_intent_library",
)

load("@build_bazel_rules_apple//apple:watchos.bzl",
    "watchos_application",
    "watchos_extension",
)

load("@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)

load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "top_level_targets",
    "xcodeproj",
    "xcode_provisioning_profile",
)

load("//build-system/bazel-utils:plist_fragment.bzl",
    "plist_fragment",
)

load(
    "@build_configuration//:variables.bzl",
    "elloapp_bazel_path",
    "elloapp_bundle_id",
    "elloapp_aps_environment",
    "elloapp_team_id",
    "elloapp_enable_icloud",
    "elloapp_enable_siri",
    "elloapp_enable_watch",
)

load("@build_bazel_rules_apple//apple:resources.bzl",
    "swift_intent_library",
)

config_setting(
    name = "debug",
    values = {
        "compilation_mode": "dbg",
    },
)

bool_flag(
    name = "disableExtensions",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)

bool_flag(
    name = "disableProvisioningProfiles",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)

config_setting(
    name = "disableExtensionsSetting",
    flag_values = {
        ":disableExtensions": "True",
    },
)

config_setting(
    name = "disableProvisioningProfilesSetting",
    flag_values = {
        ":disableProvisioningProfiles": "False",
    },
)

bool_flag(
    name = "disableStripping",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)

config_setting(
    name = "disableStrippingSetting",
    flag_values = {
        ":disableStripping": "True",
    },
)

genrule(
    name = "empty",
    outs = ["empty.swift"],
    cmd = "touch $(OUTS)",
)

genrule(
    name = "GeneratedPresentationStrings",
    srcs = [
        "//build-system:GenerateStrings/GenerateStrings.py",
        "ElloApp-iOS/en.lproj/Localizable.strings",
    ],
    cmd = '''
        python3 $(location //build-system:GenerateStrings/GenerateStrings.py) \\
            --source=$(location ElloApp-iOS/en.lproj/Localizable.strings) \\
            --outImplementation=$(location GeneratedPresentationStrings/Sources/PresentationStrings.m) \\
            --outHeader=$(location GeneratedPresentationStrings/PublicHeaders/PresentationStrings/PresentationStrings.h) \\
            --outData=$(location GeneratedPresentationStrings/Resources/PresentationStrings.data) \\
    ''',
    outs = [
        "GeneratedPresentationStrings/PublicHeaders/PresentationStrings/PresentationStrings.h",
        "GeneratedPresentationStrings/Sources/PresentationStrings.m",
        "GeneratedPresentationStrings/Resources/PresentationStrings.data",
    ],
)

MtProtoKitFramework_minimum_os_ver = "16.0"
SwiftSignalKitFramework_minimum_os_ver = "16.0"
PostboxFramework_minimum_os_ver = "16.0"
ElloAppApiFramework_minimum_os_ver = "16.0"
ElloAppCoreFramework_minimum_os_ver = "16.0"
AsyncDisplayKitFramework_minimum_os_ver = "16.0"
DisplayFramework_minimum_os_ver = "16.0"
ElloAppUIFramework_minimum_os_ver = "16.0"
ShareExtension_minimum_os_ver = "16.0"
NotificationContentExtension_minimum_os_ver = "16.0"
WidgetExtension_minimum_os_ver = "16.0"
WidgetInfoPlist_minimum_os_ver = "16.0"
IntentsExtension_minimum_os_ver = "16.0"
BroadcastUploadExtension_minimum_os_ver = "16.0"
NotificationServiceExtension_minimum_os_ver = "16.0"
ElloApp_minimum_os_ver = "16.0"
libvpx_build_test_minimum_os_ver = "16.0"
webrtc_build_test_minimum_os_ver = "16.0"

ElloAppWatchExtension_minimum_watchos_ver = "9.0"
ElloAppWatchApp_minimum_watchos_ver = "9.0"

empty_languages = [
    "ar",
    "be",
    "ca",
    "de",
    "es",
    "fa",
    "fr",
    "id",
    "it",
    "ko",
    "ms",
    "nl",
    "pl",
    "pt",
    "ru",
    "tr",
    "uk",
    "uz",
]

[
    genrule(
        name = "Localizable_{}.strings".format(language),
        outs = ["{}.lproj/Localizable.strings".format(language)],
        cmd = "touch $(OUTS)",
    ) for language in empty_languages
]

objc_library(
    name = "PresentationStrings",
    enable_modules = True,
    module_name = "PresentationStrings",
    srcs = [
        "GeneratedPresentationStrings/Sources/PresentationStrings.m",
    ],
    hdrs = [
        "GeneratedPresentationStrings/PublicHeaders/PresentationStrings/PresentationStrings.h",
    ],
    includes = [
        "GeneratedPresentationStrings/PublicHeaders",
    ],
    sdk_frameworks = [
        "Foundation",
    ],
    deps = [
        "//submodules/NumberPluralizationForm:NumberPluralizationForm",
        "//submodules/AppBundle:AppBundle",
    ],
    visibility = [
        "//visibility:public",
    ],
)

swift_library(
    name = "_LocalDebugOptions",
    srcs = [":empty"],
    copts = [
        "-Xfrontend",
        "-serialize-debugging-options",
    ],
    deps = [
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/AppBundle:AppBundle",
        "//submodules/ObjCRuntimeUtils:ObjCRuntimeUtils",
        "//submodules/UIKitRuntimeUtils:UIKitRuntimeUtils",
        "//submodules/Crc32:Crc32",
        "//submodules/MurMurHash32:MurMurHash32",
        "//submodules/StringTransliteration:StringTransliteration",
        "//submodules/sqlcipher:sqlcipher",
        "//submodules/NumberPluralizationForm:NumberPluralizationForm",
        "//submodules/EncryptionProvider:EncryptionProvider",
        "//submodules/MtProtoKit:MtProtoKit",
    ],
    module_name = "_LocalDebugOptions",
    tags = ["no-remote"],
    visibility = ["//visibility:public"],
)

debug_deps = select({
    ":debug": [":_LocalDebugOptions"],
    "//conditions:default": [],
})

selects.config_setting_group(
    name = "resolvedDisableStrippingSetting",
    match_any = [":debug", ":disableStrippingSetting"],
)

strip_framework = select({
    ":resolvedDisableStrippingSetting": None,
    "//conditions:default": ":StripFramework",
})

filegroup(
    name = "AppResources",
    srcs = glob([
        "ElloApp-iOS/Resources/**/*",
    ], exclude = ["ElloApp-iOS/Resources/**/.*"]),
)


filegroup(
    name = "AppStringResources",
    srcs = [
        "ElloApp-iOS/en.lproj/Localizable.strings",
    ] + [
        "{}.lproj/Localizable.strings".format(language) for language in empty_languages
    ],
)

filegroup(
    name = "WatchAppStringResources",
    srcs = glob([
        "ElloApp-iOS/*.lproj/Localizable.strings",
    ], exclude = ["ElloApp-iOS/*.lproj/**/.*"]),
)

filegroup(
    name = "AppIntentVocabularyResources",
    srcs = glob([
        "ElloApp-iOS/*.lproj/AppIntentVocabulary.plist",
    ], exclude = ["ElloApp-iOS/*.lproj/**/.*"]),
)

filegroup(
    name = "InfoPlistStringResources",
    srcs = glob([
        "ElloApp-iOS/*.lproj/InfoPlist.strings",
    ], exclude = ["ElloApp-iOS/*.lproj/**/.*"]),
)

filegroup(
    name = "Icons",
    srcs = glob([
        "ElloApp-iOS/Icons.xcassets/**/*",
    ], exclude = ["ElloApp-iOS/Icons.xcassets/**/.*"]),
)

#filegroup(
#    name = "AppIcons",
#    srcs = glob([
#        "ElloApp-iOS/AppIcons.xcassets/**/*",
#    ], exclude = ["ElloApp-iOS/AppIcons.xcassets/**/.*"]),
#)

filegroup(
    name = "DefaultAppIcon",
    srcs = glob([
        "ElloApp-iOS/DefaultAppIcon.xcassets/**/*",
    ], exclude = ["ElloApp-iOS/DefaultAppIcon.xcassets/**/.*"]),
)

#filegroup(
#    name = "PrivacyInfo",
#    srcs = glob([
#        "ElloApp-iOS/PrivacyInfo.xcprivacy",
#    ]),
#)

#filegroup(
#    name = "BlackAppIcon",
#    srcs = glob([
#        "ElloApp-iOS/BlackIcon.xcassets/**/*",
#    ], exclude = ["ElloApp-iOS/BlackIcon.xcassets/**/.*"]),
#)

#filegroup(
#    name = "DefaultIcon",
#    srcs = glob([
#        "ElloApp-iOS/AppIcons.xcassets/BlueIcon.appiconset/*.png",
#    ]),
#)

#filegroup(
#    name = "AdditionalIcons",
#    srcs = glob([
#        "ElloApp-iOS/*.png",
#    ]),
#)

alternate_icon_folders = [
#    "BlackIcon",
#    "BlackClassicIcon",
#    "BlackFilledIcon",
#    "BlueIcon",
#    "BlueClassicIcon",
#    "BlueFilledIcon",
#    "WhiteFilledIcon",
#    "New1",
#    "New2",
#    "Premium",
#    "PremiumBlack",
#    "PremiumTurbo",
]

#[
#    filegroup(
#        name = "{}".format(name),
#        srcs = glob([
#            "ElloApp-iOS/{}.alticon/*.png".format(name),
#        ]),
#    ) for name in alternate_icon_folders
#]

filegroup(
    name = "LaunchScreen",
    srcs = glob([
        "ElloApp-iOS/Base.lproj/LaunchScreen.xib",
    ]),
)

objc_library(
    name = "Main",
    srcs = [
        "ElloApp-iOS/main.m"
    ],
)

swift_library(
    name = "Lib",
    srcs = glob([
        "ElloApp-iOS/Application.swift",
    ]),
    data = [
        ":Icons",
        ":AppResources",
        ":AppIntentVocabularyResources",
        ":InfoPlistStringResources",
        "//submodules/LegacyComponents:LegacyComponentsResources",
        "//submodules/LegacyComponents:LegacyComponentsAssets",
        "//submodules/OverlayStatusController:OverlayStatusControllerResources",
        "//submodules/PasswordSetupUI:PasswordSetupUIResources",
        "//submodules/PasswordSetupUI:PasswordSetupUIAssets",
        "//submodules/PremiumUI:PremiumUIResources",
        "//submodules/ElloAppUI:ElloAppUIResources",
        "//submodules/ElloAppUI:ElloAppUIAssets",
        ":GeneratedPresentationStrings/Resources/PresentationStrings.data",
    ],
    deps = [
        "//submodules/ElloAppUI:ElloAppUI",
        "//third-party/boringssl:crypto",
    ],
)

plist_fragment(
    name = "BuildNumberInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleVersion</key>
    <string>{buildNumber}</string>
    """
)

plist_fragment(
    name = "UrlTypesInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>CFBundleURLName</key>
            <string>{elloapp_bundle_id}</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>elloapp</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>CFBundleURLName</key>
            <string>{elloapp_bundle_id}.compatibility</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>tg</string>
            </array>
        </dict>
    </array>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

# official_apple_pay_merchants = [
#     "merchant.com.elloapp.messenger",
#     "merchant.privatbank.test.telergramios",
#     "merchant.privatbank.prod.telergram",
#     "merchant.paymaster.test.elloappios",
#     "merchant.paymaster.prod.elloappios",
#     "merchant.smartglocal.prod.elloappios",
#     "merchant.smartglocal.test.elloappios",
#     "merchant.yoomoney.test.elloappios",
#     "merchant.yoomoney.prod.elloappios",
#     "merchant.org.elloapp.Best2pay.test",
# ]

official_bundle_ids = [
    "com.ello.messenger",
    "org.ello.ElloApp-iOS",
]

store_bundle_ids = [
    "com.ello.messenger",
]

# apple_pay_merchants = official_apple_pay_merchants if elloapp_bundle_id == "com.elloapp.messenger" else []

# apple_pay_merchants_fragment = "" if apple_pay_merchants == [] else """
# <key>com.apple.developer.in-app-payments</key>
# <array>
# """ + "\n".join([
# "    <string>{merchant_id}</string>".format(merchant_id=merchant_id) for merchant_id in apple_pay_merchants
# ]) + "\n" + """
# </array>
# """

# official_unrestricted_voip_fragment = """
# <key>com.apple.developer.pushkit.unrestricted-voip</key>
# <true/>
# """
# unrestricted_voip_fragment = official_unrestricted_voip_fragment if elloapp_bundle_id in official_bundle_ids else ""

# official_carplay_fragment = """
# <key>com.apple.developer.carplay-messaging</key>
# <true/>
# """
# carplay_fragment = official_carplay_fragment if elloapp_bundle_id in official_bundle_ids else ""

# icloud_fragment = "" if not elloapp_enable_icloud else """
# <key>com.apple.developer.icloud-services</key>
# <array>
#     <string>CloudKit</string>
#     <string>CloudDocuments</string>
# </array>
# <key>com.apple.developer.icloud-container-identifiers</key>
# <array>
#     <string>iCloud.{elloapp_bundle_id}</string>
# </array>
# <key>com.apple.developer.icloud-container-environment</key>
# <string>{elloapp_icloud_environment}</string>
# """.format(
#     elloapp_bundle_id=elloapp_bundle_id,
#     elloapp_icloud_environment="Development"#="Production" if elloapp_aps_environment == "production" else "Development"
# )

associated_domains_fragment = "" if elloapp_bundle_id not in official_bundle_ids else """
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:ello.team</string>
    <string>applinks:*.ello.team</string>
</array>
"""

# siri_fragment = "" if not elloapp_enable_siri else """
# <key>com.apple.developer.siri</key>
# <true/>
# """

aps_fragment = "" if elloapp_aps_environment == "" else """
<key>aps-environment</key>
<string>{elloapp_aps_environment}</string>
""".format(elloapp_aps_environment=elloapp_aps_environment)

app_groups_fragment = """
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.{elloapp_bundle_id}</string>
   </array>
   <key>application-identifier</key>
   <string>{elloapp_team_id}.{elloapp_bundle_id}</string>
""".format(
   elloapp_team_id=elloapp_team_id,
   elloapp_bundle_id=elloapp_bundle_id
)

communication_notifications_fragment = """
 <key>com.apple.developer.usernotifications.communication</key>
 <true/>
 """

# store_signin_fragment = """
# <key>com.apple.developer.applesignin</key>
# <array>
#     <string>Default</string>
# </array>
# """
# signin_fragment = store_signin_fragment if elloapp_bundle_id in store_bundle_ids else ""

plist_fragment(
    name = "ElloAppEntitlements",
    extension = "entitlements",
    template = "".join([
        aps_fragment,
        app_groups_fragment,
        # siri_fragment,
        associated_domains_fragment,
        # icloud_fragment,
        # apple_pay_merchants_fragment,
        # unrestricted_voip_fragment,
        # carplay_fragment,
         communication_notifications_fragment,
        # signin_fragment,
    ])
)

filegroup(
    name = "ElloAppWatchExtensionResources",
    srcs = glob([
        "Watch/Extension/Resources/**/*",
    ], exclude = ["Watch/Extension/Resources/**/.*"]),
)

filegroup(
    name = "ElloAppWatchAppResources",
    srcs = glob([
        "Watch/Extension/Resources/**/*.png",
    ], exclude = ["Watch/Extension/Resources/**/.*"]),
)

filegroup(
    name = "ElloAppWatchAppAssets",
    srcs = glob([
        "Watch/App/Assets.xcassets/**/*",
    ], exclude = ["Watch/App/Assets.xcassets/**/.*"]),
)

filegroup(
    name = "ElloAppWatchAppInterface",
    srcs = glob([
        "Watch/App/Base.lproj/Interface.storyboard",
    ]),
)

objc_library(
    name = "ElloAppWatchLib",
    srcs = glob([
        "Watch/Extension/**/*.m",
        "Watch/SSignalKit/**/*.m",
        "Watch/Bridge/**/*.m",
        "Watch/WatchCommonWatch/**/*.m",
        "Watch/Extension/**/*.h",
        "Watch/SSignalKit/**/*.h",
        "Watch/Bridge/**/*.h",
        "Watch/WatchCommonWatch/**/*.h",
    ]),
    copts = [
        "-DTARGET_OS_WATCH=1",
        "-IElloApp/Watch",
        "-IElloApp/Watch/Extension",
        "-IElloApp/Watch/Bridge",
    ],
    sdk_frameworks = [
        "WatchKit",
        "WatchConnectivity",
        "ClockKit",
        "UserNotifications",
        "CoreLocation",
        "CoreGraphics",
    ],
)

plist_fragment(
    name = "VersionInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleShortVersionString</key>
    <string>{elloappVersion}</string>
    """
)

plist_fragment(
    name = "RequiredDeviceCapabilitiesPlist",
    extension = "plist",
    template =
    """
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    """
)

plist_fragment(
    name = "AppNameInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleDisplayName</key>
    <string>ElloApp</string>
    """
)

plist_fragment(
    name = "WatchExtensionNSExtensionInfoPlist",
    extension = "plist",
    template =
    """
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict>
            <key>WKAppBundleIdentifier</key>
            <string>{elloapp_bundle_id}.watchkitapp</string>
        </dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.watchkit</string>
    </dict>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

plist_fragment(
    name = "WatchAppCompanionInfoPlist",
    extension = "plist",
    template =
    """
    <key>WKCompanionAppBundleIdentifier</key>
    <string>{elloapp_bundle_id}</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

plist_fragment(
    name = "WatchExtensionInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.watchkitapp.watchkitextension</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>WKExtensionDelegateClassName</key>
    <string>TGExtensionDelegate</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

plist_fragment(
    name = "WatchAppInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.watchkitapp</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
    </array>
    <key>WKWatchKitApp</key>
    <true/>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

watchos_extension(
    name = "ElloAppWatchExtension",
    bundle_id = "{elloapp_bundle_id}.watchkitapp.watchkitextension".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    bundle_name = "ElloAppWatchExtension",
    infoplists = [
        ":WatchExtensionInfoPlist",
        ":VersionInfoPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
        ":WatchExtensionNSExtensionInfoPlist",
    ],
    minimum_os_version = ElloAppWatchExtension_minimum_watchos_ver,
    provisioning_profile = select({
        ":disableProvisioningProfilesSetting": None,
        "//conditions:default": "@build_configuration//provisioning:WatchExtension.mobileprovision",
    }),
    resources = [
        ":ElloAppWatchExtensionResources",
    ],
    strings = [
        ":WatchAppStringResources",
    ],
    deps = [
        ":ElloAppWatchLib",
    ],
)


genrule(
    name = "StripWatchosStubBinary",
    cmd_bash =
"""
    echo 'lipo -remove armv7k -remove arm64 -remove arm64e $$1/ElloAppWatch.app/_WatchKitStub/WK -output $$1/ElloAppWatch.app/_WatchKitStub/WK' > $(location StripWatchosStubBinary.sh)
    echo '' >> $(location StripWatchosStubBinary.sh)
""",
    outs = [
        "StripWatchosStubBinary.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)

watchos_application(
    name = "ElloAppWatchApp",
    bundle_id = "{elloapp_bundle_id}.watchkitapp".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    bundle_name = "ElloAppWatch",
    extension = ":ElloAppWatchExtension",
    infoplists = [
        ":WatchAppInfoPlist",
        ":VersionInfoPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
        ":WatchAppCompanionInfoPlist",
    ],
    minimum_os_version = ElloAppWatchApp_minimum_watchos_ver,
    provisioning_profile = select({
        ":disableProvisioningProfilesSetting": None,
        "//conditions:default": "@build_configuration//provisioning:WatchApp.mobileprovision",
    }),
    ipa_post_processor = ":StripWatchosStubBinary",
    resources = [
        ":ElloAppWatchAppResources",
        ":ElloAppWatchAppAssets",
    ],
    storyboards = [
        ":ElloAppWatchAppInterface",
    ],
    strings = [
    ],
)

plist_fragment(
    name = "MtProtoKitInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.MtProtoKit</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>MtProtoKit</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

ios_framework(
    name = "MtProtoKitFramework",
    bundle_id = "{elloapp_bundle_id}.MtProtoKit".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":MtProtoKitInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
    ],
    minimum_os_version = MtProtoKitFramework_minimum_os_ver,
    extension_safe = True,
    ipa_post_processor = strip_framework,
    deps = [
        "//submodules/MtProtoKit:MtProtoKit",
    ],
)

plist_fragment(
    name = "SwiftSignalKitInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.SwiftSignalKit</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>SwiftSignalKit</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

ios_framework(
    name = "SwiftSignalKitFramework",
    bundle_id = "{elloapp_bundle_id}.SwiftSignalKit".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":SwiftSignalKitInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
    ],
    minimum_os_version = SwiftSignalKitFramework_minimum_os_ver,
    extension_safe = True,
    ipa_post_processor = strip_framework,
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
    ],
)

plist_fragment(
    name = "PostboxInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.Postbox</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>Postbox</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

ios_framework(
    name = "PostboxFramework",
    bundle_id = "{elloapp_bundle_id}.Postbox".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":PostboxInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
    ],
    frameworks = [
        ":SwiftSignalKitFramework",
    ],
    minimum_os_version = PostboxFramework_minimum_os_ver,
    extension_safe = True,
    ipa_post_processor = strip_framework,
    deps = [
        "//submodules/Postbox:Postbox",
    ],
)

plist_fragment(
    name = "ElloAppApiInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.ElloAppApi</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>ElloAppApi</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

ios_framework(
    name = "ElloAppApiFramework",
    bundle_id = "{elloapp_bundle_id}.ElloAppApi".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":ElloAppApiInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
    ],
    minimum_os_version = ElloAppApiFramework_minimum_os_ver,
    extension_safe = True,
    ipa_post_processor = strip_framework,
    deps = [
        "//submodules/ElloAppApi:ElloAppApi",
    ],
)

plist_fragment(
    name = "ElloAppCoreInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.ElloAppCore</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>ElloAppCore</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

ios_framework(
    name = "ElloAppCoreFramework",
    bundle_id = "{elloapp_bundle_id}.ElloAppCore".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":ElloAppCoreInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
    ],
    frameworks = [
        ":MtProtoKitFramework",
        ":SwiftSignalKitFramework",
        ":PostboxFramework",
    ],
    minimum_os_version = ElloAppCoreFramework_minimum_os_ver,
    extension_safe = True,
    ipa_post_processor = strip_framework,
    deps = [
        "//submodules/ElloAppCore:ElloAppCore",
    ],
)

plist_fragment(
    name = "AsyncDisplayKitInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.AsyncDisplayKit</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>AsyncDisplayKit</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

plist_fragment(
    name = "DisplayInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.Display</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>Display</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

genrule(
    name = "StripFramework",
    cmd_bash =
"""
    echo 'for f in $$1/*.framework; do binary_name=`echo $$(basename $$f) | sed -e "s/\\\\.framework//"`; strip -ST $$f/$$binary_name; done;' > $(location StripFramework.sh)
    echo '' >> $(location StripFramework.sh)
""",
    outs = [
        "StripFramework.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)

genrule(
    name = "GenerateAddAlternateIcons",
    srcs = [
        "ElloApp-iOS/AddAlternateIcons.sh",
    ],
    cmd_bash =
"""
    cat $(location ElloApp-iOS/AddAlternateIcons.sh) >> $(location AddAlternateIcons.sh)
""",
    outs = [
        "AddAlternateIcons.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)

sh_binary(
    name = "AddAlternateIcons",
    data = [
        "ElloApp-iOS/AlternateIcons.plist",
        "ElloApp-iOS/AlternateIcons-iPad.plist",
    ],
    srcs = [":GenerateAddAlternateIcons"],
)

plist_fragment(
    name = "ElloAppUIInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.ElloAppUI</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>ElloAppUI</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

ios_framework(
    name = "ElloAppUIFramework",
    bundle_id = "{elloapp_bundle_id}.ElloAppUI".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":ElloAppUIInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
    ],
    frameworks = [
        ":MtProtoKitFramework",
        ":SwiftSignalKitFramework",
        ":PostboxFramework",
        ":ElloAppCoreFramework",
    ],
    minimum_os_version = ElloAppUIFramework_minimum_os_ver,
    extension_safe = True,
    ipa_post_processor = strip_framework,
    deps = [
        "//submodules/ElloAppUI:ElloAppUI",
    ] + debug_deps,
)

plist_fragment(
    name = "ShareInfoPlist",
    extension = "plist",
    template = 
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.Share</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict>
            <key>IntentsSupported</key>
            <array>
                <string>INSendMessageIntent</string>
            </array>
            <key>NSExtensionActivationRule</key>
            <string>SUBQUERY (
    extensionItems,
    $extensionItem,
    SUBQUERY (
        $extensionItem.attachments,
        $attachment,
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.file-url" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.movie" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.image" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.text" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.audio" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.data" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.vcard" ||
        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "com.apple.pkpass"
    ).@count == $extensionItem.attachments.@count
).@count &gt; 0</string>
        </dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.share-services</string>
        <key>NSExtensionPrincipalClass</key>
        <string>ShareRootController</string>
    </dict>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

swift_library(
    name = "ShareExtensionLib",
    module_name = "ShareExtensionLib",
    srcs = glob([
        "Share/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppUI:ElloAppUI"
    ],
)

ios_extension(
    name = "ShareExtension",
    bundle_id = "{elloapp_bundle_id}.Share".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":ShareInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
    ],
    minimum_os_version = ShareExtension_minimum_os_ver,
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:Share.mobileprovision",
#    }),
    provisioning_profile = "ElloAppShare.mobileprovision",
    deps = [":ShareExtensionLib"],
    frameworks = [
        ":ElloAppUIFramework"
    ],
)

plist_fragment(
    name = "NotificationContentInfoPlist",
    extension = "plist",
    template = 
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.NotificationContent</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict>
            <key>UNNotificationExtensionCategory</key>
            <array>
                <string>withReplyMedia</string>
                <string>withMuteMedia</string>
            </array>
            <key>UNNotificationExtensionInitialContentSizeRatio</key>
            <real>0.0001</real>
        </dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.usernotifications.content-extension</string>
        <key>NSExtensionPrincipalClass</key>
        <string>NotificationViewController</string>
    </dict>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

objc_library(
    name = "NotificationContentExtensionLink",
    srcs = [
        "NotificationContent/main.m",
    ],
    sdk_frameworks = [
        "UserNotificationsUI",
    ],
)

swift_library(
    name = "NotificationContentExtensionLib",
    module_name = "NotificationContentExtensionLib",
    srcs = glob([
        "NotificationContent/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppUI:ElloAppUI",
        ":NotificationContentExtensionLink",
    ],
)

'''genrule(
    name = "SetMinOsVersionNotificationContentExtension",
    cmd_bash =
"""
    name=NotificationContentExtension.appex
    cat $(location PatchMinOSVersion.source.sh) | sed -e "s/<<<MIN_OS_VERSION>>>/10\\.0/g" | sed -e "s/<<<NAME>>>/$$name/g" > $(location SetMinOsVersionNotificationContentExtension.sh)
""",
    srcs = [
        "PatchMinOSVersion.source.sh",
    ],
    outs = [
        "SetMinOsVersionNotificationContentExtension.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)'''

ios_extension(
    name = "NotificationContentExtension",
    bundle_id = "{elloapp_bundle_id}.NotificationContent".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":NotificationContentInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
    ],
    minimum_os_version = NotificationContentExtension_minimum_os_ver, # maintain the same minimum OS version across extensions
    #ipa_post_processor = ":SetMinOsVersionNotificationContentExtension",
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:ElloApp.mobileprovision",
#    }),
    provisioning_profile = "ElloAppNotificationContent.mobileprovision",
    deps = [":NotificationContentExtensionLib"],
    frameworks = [
        ":ElloAppUIFramework"
    ],
)

plist_fragment(
    name = "WidgetInfoPlist",
    extension = "plist",
    template = 
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.Widget</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

filegroup(
    name = "WidgetAssets",
    srcs = glob(["WidgetKitWidget/WidgetImages.xcassets/**"]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "WidgetExtensionLib",
    module_name = "WidgetExtensionLib",
    srcs = glob([
        "WidgetKitWidget/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    data = [
        ":WidgetAssets",
    ],
    deps = [
        "//submodules/BuildConfig:BuildConfig",
        "//submodules/WidgetItems:WidgetItems_iOS14",
        "//submodules/WidgetItemsUtils:WidgetItemsUtils",
        "//submodules/AppLockState:AppLockState",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/OpenSSLEncryptionProvider:OpenSSLEncryptionProvider",
        "//ElloApp:GeneratedSources",
    ],
)

genrule(
    name = "SetMinOsVersionWidgetExtension",
    cmd_bash =
"""
    name=WidgetExtension.appex
    cat $(location PatchMinOSVersion.source.sh) | sed -e "s/<<<MIN_OS_VERSION>>>/14\\.0/g" | sed -e "s/<<<NAME>>>/$$name/g" > $(location SetMinOsVersionWidgetExtension.sh)
""",
    srcs = [
        "PatchMinOSVersion.source.sh",
    ],
    outs = [
        "SetMinOsVersionWidgetExtension.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)

ios_extension(
    name = "WidgetExtension",
    bundle_id = "{elloapp_bundle_id}.Widget".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":WidgetInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
    ],
    minimum_os_version = WidgetExtension_minimum_os_ver, # maintain the same minimum OS version across extensions
    ipa_post_processor = ":SetMinOsVersionWidgetExtension",
    #provides_main = True,
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:Widget.mobileprovision",
#    }),
    provisioning_profile = "ElloApp.mobileprovision",
    deps = [
        ":WidgetExtensionLib",
    ],
    frameworks = [
        ":SwiftSignalKitFramework",
        ":PostboxFramework",
        ":ElloAppCoreFramework",
    ],
)

plist_fragment(
    name = "IntentsInfoPlist",
    extension = "plist",
    template = 
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.SiriIntents</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict>
            <key>IntentsRestrictedWhileLocked</key>
            <array/>
            <key>IntentsRestrictedWhileProtectedDataUnavailable</key>
            <array/>
            <key>IntentsSupported</key>
            <array>
                <string>INSendMessageIntent</string>
                <string>INStartAudioCallIntent</string>
                <string>INSearchForMessagesIntent</string>
                <string>INSetMessageAttributeIntent</string>
                <string>INSearchCallHistoryIntent</string>
                <string>SelectFriendsIntent</string>
                <string>SelectAvatarFriendsIntent</string>
            </array>
        </dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.intents-service</string>
        <key>NSExtensionPrincipalClass</key>
        <string>IntentHandler</string>
    </dict>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

swift_intent_library(
    name = "GeneratedSources",
    src = "SiriIntents/en.lproj/Intents.intentdefinition",
    module_name = "GeneratedSources",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "IntentsAssets",
    srcs = glob(["SiriIntents/IntentsImages.xcassets/**"]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "IntentsExtensionLib",
    module_name = "IntentsExtensionLib",
    srcs = glob([
        "SiriIntents/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    data = glob([
        "SiriIntents/*.lproj/Intents.intentdefinition"
    ]) + [
        ":IntentsAssets"
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Postbox:Postbox",
        "//submodules/ElloAppApi:ElloAppApi",
        "//submodules/ElloAppCore:ElloAppCore",
        "//submodules/BuildConfig:BuildConfig",
        "//submodules/OpenSSLEncryptionProvider:OpenSSLEncryptionProvider",
        "//submodules/AppLockState:AppLockState",
        "//ElloApp:GeneratedSources",
        "//submodules/WidgetItems:WidgetItems",
    ],
)

'''genrule(
    name = "SetMinOsVersionIntentsExtension",
    cmd_bash =
"""
    name=IntentsExtension.appex
    cat $(location PatchMinOSVersion.source.sh) | sed -e "s/<<<MIN_OS_VERSION>>>/10\\.0/g" | sed -e "s/<<<NAME>>>/$$name/g" > $(location SetMinOsVersionIntentsExtension.sh)
""",
    srcs = [
        "PatchMinOSVersion.source.sh",
    ],
    outs = [
        "SetMinOsVersionIntentsExtension.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)'''

ios_extension(
    name = "IntentsExtension",
    bundle_id = "{elloapp_bundle_id}.SiriIntents".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":IntentsInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
    ],
    minimum_os_version = IntentsExtension_minimum_os_ver, # maintain the same minimum OS version across extensions
    #ipa_post_processor = ":SetMinOsVersionIntentsExtension",
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:ElloApp.mobileprovision",
#    }),
    provisioning_profile = "ElloApp.mobileprovision",
    deps = [":IntentsExtensionLib"],
    frameworks = [
        ":SwiftSignalKitFramework",
        ":PostboxFramework",
        ":ElloAppCoreFramework",
    ],
)

plist_fragment(
    name = "BroadcastUploadInfoPlist",
    extension = "plist",
    template = 
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.BroadcastUpload</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.broadcast-services-upload</string>
        <key>NSExtensionPrincipalClass</key>
        <string>BroadcastUploadSampleHandler</string>
        <key>RPBroadcastProcessMode</key>
        <string>RPBroadcastProcessModeSampleBuffer</string>
    </dict>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

swift_library(
    name = "BroadcastUploadExtensionLib",
    module_name = "BroadcastUploadExtensionLib",
    srcs = glob([
        "BroadcastUpload/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/ElloAppUI:ElloAppUI",
        "//submodules/ElloAppVoip:ElloAppVoip",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/BuildConfig:BuildConfig",
        "//submodules/WidgetItems:WidgetItems",
        "//submodules/BroadcastUploadHelpers:BroadcastUploadHelpers",
    ],
)

'''genrule(
    name = "SetMinOsVersionBroadcastUploadExtension",
    cmd_bash =
"""
    name=BroadcastUploadExtension.appex
    cat $(location PatchMinOSVersion.source.sh) | sed -e "s/<<<MIN_OS_VERSION>>>/11\\.0/g" | sed -e "s/<<<NAME>>>/$$name/g" > $(location SetMinOsVersionBroadcastUploadExtension.sh)
""",
    srcs = [
        "PatchMinOSVersion.source.sh",
    ],
    outs = [
        "SetMinOsVersionBroadcastUploadExtension.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)'''

ios_extension(
    name = "BroadcastUploadExtension",
    bundle_id = "{elloapp_bundle_id}.BroadcastUpload".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":BroadcastUploadInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
    ],
    minimum_os_version = BroadcastUploadExtension_minimum_os_ver, # maintain the same minimum OS version across extensions
    #ipa_post_processor = ":SetMinOsVersionBroadcastUploadExtension",
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:ElloApp.mobileprovision",
#    }),
    provisioning_profile = "ElloApp.mobileprovision",
    deps = [":BroadcastUploadExtensionLib"],
    frameworks = [
        ":ElloAppUIFramework",
        ":SwiftSignalKitFramework",
    ],
)

plist_fragment(
    name = "NotificationServiceInfoPlist",
    extension = "plist",
    template = 
    """
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}.NotificationService</string>
    <key>CFBundleName</key>
    <string>ElloApp</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.usernotifications.service</string>
        <key>NSExtensionPrincipalClass</key>
        <string>NotificationService</string>
        <key>NSExtensionAttributes</key>
        <dict>
            <key>IntentsSupported</key>
            <array>
                <string>INSendMessageIntent</string>
            </array>
        </dict>
    </dict>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

'''genrule(
    name = "SetMinOsVersionNotificationServiceExtension",
    cmd_bash =
"""
    name=NotificationServiceExtension.appex
    cat $(location PatchMinOSVersion.source.sh) | sed -e "s/<<<MIN_OS_VERSION>>>/10\\.0/g" | sed -e "s/<<<NAME>>>/$$name/g" > $(location SetMinOsVersionNotificationServiceExtension.sh)
""",
    srcs = [
        "PatchMinOSVersion.source.sh",
    ],
    outs = [
        "SetMinOsVersionNotificationServiceExtension.sh",
    ],
    executable = True,
    visibility = [
        "//visibility:public",
    ]
)'''

ios_extension(
    name = "NotificationServiceExtension",
    bundle_id = "{elloapp_bundle_id}.NotificationService".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        ":NotificationServiceInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":BuildNumberInfoPlist",
        ":AppNameInfoPlist",
    ],
    minimum_os_version = NotificationServiceExtension_minimum_os_ver, # maintain the same minimum OS version across extensions
    #ipa_post_processor = ":SetMinOsVersionNotificationServiceExtension",
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:ElloAppNotificationService.mobileprovision",
#    }),
    provisioning_profile = "ElloAppNotificationService.mobileprovision",
    deps = ["//ElloApp/NotificationService:NotificationServiceExtensionLib"],
    frameworks = [
        ":MtProtoKitFramework",
        ":SwiftSignalKitFramework",
        ":PostboxFramework",
        ":ElloAppCoreFramework",
    ],
#    resources = [
#        ":PrivacyInfo",
#    ],
)

plist_fragment(
    name = "ElloAppInfoPlist",
    extension = "plist",
    template = 
    """
    <key>UIUserInterfaceStyle</key>
	<string>Light</string>
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>{elloapp_bundle_id}.refresh</string>
    </array>
    <key>CFBundleAllowMixedLocalizations</key>
    <true/>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Ello</string>
    <key>CFBundleIdentifier</key>
    <string>{elloapp_bundle_id}</string>
    <key>CFBundleName</key>
    <string>Elloapp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>instagram</string>
        <string>comgooglemaps-x-callback</string>
        <string>foursquare</string>
        <string>here-location</string>
        <string>yandexmaps</string>
        <string>yandexnavi</string>
        <string>comgooglemaps</string>
        <string>youtube</string>
        <string>twitter</string>
        <string>vk</string>
        <string>waze</string>
        <string>googlechrome</string>
        <string>firefox</string>
        <string>touch-http</string>
        <string>yandexbrowser-open-url</string>
        <string>vimeo</string>
        <string>vine</string>
        <string>coub</string>
        <string>uber</string>
        <string>citymapper</string>
        <string>lyft</string>
        <string>opera-http</string>
        <string>firefox-focus</string>
        <string>ddgQuickLink</string>
        <string>moovit</string>
        <string>alook</string>
        <string>dgis</string>
        <string>microsoft-edge-http</string>
        <string>brave</string>
        <string>onionhttp</string>
        <string>ucbrowser</string>
        <string>dolphin</string>
        <string>instagram-stories</string>
<string>googlegmail</string>
    <string>ms-outlook</string>
    <string>readdle-spark</string>
    <string>ymail</string>
    </array>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>NSCameraUsageDescription</key>
    <string>We need this so that you can take and share photos and videos.</string>
    <key>NSContactsUsageDescription</key>
    <string>Elloapp stores your contacts heavily encrypted in the cloud to let you connect with your friends across all your devices.</string>
    <key>NSFaceIDUsageDescription</key>
    <string>You can use Face ID to unlock the app.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>When you send your location to your friends, ElloApp needs access to show them a map.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>When you choose to share your Live Location with friends in a chat, ElloApp needs background access to your location to keep them updated for the duration of the live sharing.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>When you choose to share your live location with friends in a chat, ElloApp needs background access to your location to keep them updated for the duration of the live sharing. You also need this to send locations from an Apple Watch.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need this so that you can record and share voice messages and videos with sound.</string>
    <key>NSMotionUsageDescription</key>
    <string>When you send your location to your friends, Elloapp needs access to show them a map.</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>We need this so that you can share photos and videos from your photo library.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need this so that you can share photos and videos from your photo library.</string>
    <key>NSSiriUsageDescription</key>
    <string>You can use Siri to send messages.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>We need this to transcribe audio messages on your request.</string>
    <key>NSUserActivityTypes</key>
    <array>
        <string>INSendMessageIntent</string>
        <string>RemindAboutChatIntent</string>
    </array>
    <key>UIAppFonts</key>
    <array>
        <string>SFCompactRounded-Semibold.otf</string>
        <string>AremacFS-Regular.otf</string>
        <string>AremacFS-Semibold.otf</string>
        <string>SF-Pro-Display-Regular.otf</string>
        <string>SF-Pro-Display-Medium.otf</string>
        <string>SF-Pro-Display-Semibold.otf</string>
        <string>SF-Pro-Display-Bold.otf</string>
        <string>SF-Pro-Display-BoldItalic.otf</string>
        <string>SF-Pro-Text-Regular.otf</string>
        <string>SF-Pro-Text-Medium.otf</string>
        <string>SF-Pro-Text-Semibold.otf</string>
    </array>
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
        <string>fetch</string>
        <string>location</string>
        <string>remote-notification</string>
        <string>voip</string>
    </array>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
    <key>UIFileSharingEnabled</key>
    <false/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIRequiresPersistentWiFi</key>
    <true/>
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleDefault</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UIRequiresFullScreen</key>
    <true/>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    <key>UIViewEdgeAntialiasing</key>
    <false/>
    <key>UIViewGroupOpacity</key>
    <false/>
    <key>UTImportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeConformsTo</key>
            <array>
                <string>public.data</string>
            </array>
            <key>UTTypeDescription</key>
            <string>Elloapp iOS Color Theme File</string>
            <key>UTTypeIconFiles</key>
            <array>
                <string>BlueIcon@3x.png</string>
            </array>
            <key>UTTypeIdentifier</key>
            <string>org.elloapp.ElloApp-iOS.theme</string>
            <key>UTTypeTagSpecification</key>
            <dict>
                <key>public.filename-extension</key>
                <array>
                    <string>tgios-theme</string>
                </array>
            </dict>
        </dict>
    </array>
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    """.format(
        elloapp_bundle_id = elloapp_bundle_id,
    )
)

#local_provisioning_profile(
#    name = "xcode_managed_profile",
#    profile_name = "ElloApp",
#    team_id = "JU5JK7ZGBZ",
#    tags = ["manual"],
#)

ios_application(
    name = "ElloApp",
    bundle_id = "{elloapp_bundle_id}".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = ["iphone", "ipad"],
    minimum_os_version = ElloApp_minimum_os_ver,
#    provisioning_profile = select({
#        ":disableProvisioningProfilesSetting": None,
#        "//conditions:default": "@build_configuration//provisioning:ElloApp.mobileprovision",
#    }),
    provisioning_profile = "ElloApp.mobileprovision",
    entitlements = ":ElloAppEntitlements.entitlements",
    infoplists = [
        ":ElloAppInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":UrlTypesInfoPlist",
    ],
    alternate_icons = [
        ":{}".format(name) for name in alternate_icon_folders
    ],
    #ipa_post_processor = ":AddAlternateIcons",
    resources = [
        ":LaunchScreen",
        ":DefaultAppIcon",
        #":AdditionalIcons",
        #":PrivacyInfo",
    ],
    frameworks = [
        ":MtProtoKitFramework",
        ":SwiftSignalKitFramework",
        ":PostboxFramework",
        ":ElloAppCoreFramework",
        ":ElloAppUIFramework",
    ],
    strings = [
        ":AppStringResources",
    ],
    extensions = select({
        ":disableExtensionsSetting": [],
        "//conditions:default": [
            ":ShareExtension",
            ":NotificationContentExtension",
            ":NotificationServiceExtension",
#            ":IntentsExtension",
#            ":WidgetExtension",
#            ":BroadcastUploadExtension",
        ],
    }),
    watch_application = select({
        ":disableExtensionsSetting": None,
        "//conditions:default": None#":ElloAppWatchApp",
    }) if elloapp_enable_watch else None,
    deps = [
        ":Main",
        ":Lib",
    ],
    visibility = ["//visibility:public"],
)

xcodeproj(
    name = "ElloApp_xcodeproj",
    build_mode = "bazel",
    bazel_path = elloapp_bazel_path,
    project_name = "ElloApp",
    tags = ["manual"],
    top_level_targets = top_level_targets(
        labels = [":ElloApp"],
        target_environments = ["device", "simulator"]
    )
)

# Temporary targets used to simplify webrtc build tests

ios_application(
    name = "webrtc_build_test",
    bundle_id = "{elloapp_bundle_id}".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = ["iphone", "ipad"],
    minimum_os_version = webrtc_build_test_minimum_os_ver,
    provisioning_profile = select({
        ":disableProvisioningProfilesSetting": None,
        "//conditions:default": "@build_configuration//provisioning:ElloApp.mobileprovision",
    }),
    entitlements = ":ElloAppEntitlements.entitlements",
    infoplists = [
        ":ElloAppInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":UrlTypesInfoPlist",
    ],
    deps = [
        "//third-party/webrtc:webrtc_lib",
    ],
)

ios_application(
    name = "libvpx_build_test",
    bundle_id = "{elloapp_bundle_id}".format(
        elloapp_bundle_id = elloapp_bundle_id,
    ),
    families = ["iphone", "ipad"],
    minimum_os_version = libvpx_build_test_minimum_os_ver,
    provisioning_profile = select({
        ":disableProvisioningProfilesSetting": None,
        "//conditions:default": "@build_configuration//provisioning:ElloApp.mobileprovision",
    }),
    entitlements = ":ElloAppEntitlements.entitlements",
    infoplists = [
        ":ElloAppInfoPlist",
        ":BuildNumberInfoPlist",
        ":VersionInfoPlist",
        ":RequiredDeviceCapabilitiesPlist",
        ":UrlTypesInfoPlist",
    ],
    deps = [
        "//third-party/libvpx:vpx",
    ],
)
