#!/bin/bash

export ELLOAPP_ENV_SET="1"

export DEVELOPMENT_CODE_SIGN_IDENTITY="Apple Distribution: Ello Messenger Corporation (JU5JK7ZGBZ)"
export DISTRIBUTION_CODE_SIGN_IDENTITY="Apple Distribution: Ello Messenger Corporation (JU5JK7ZGBZ)"
export DEVELOPMENT_TEAM="JU5JK7ZGBZ"

export API_ID="6"
export API_HASH="014b35b6184100b085b0d0572f9b5103"

export BUNDLE_ID="com.ello.messenger"
export APP_CENTER_ID="0"
export IS_INTERNAL_BUILD="false"
export IS_APPSTORE_BUILD="true"
export APPSTORE_ID="6469151194"
export APP_SPECIFIC_URL_SCHEME="elloapp"
export PREMIUM_IAP_PRODUCT_ID="org.elloapp.elloPremium.monthly"

if [ -z "$BUILD_NUMBER" ]; then
	echo "BUILD_NUMBER is not defined"
	exit 1
fi

export DEVELOPMENT_PROVISIONING_PROFILE_APP="match Development com.elloapp.messenger"
export DISTRIBUTION_PROVISIONING_PROFILE_APP="match AppStore com.elloapp.messenger"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_SHARE="match Development com.elloapp.messenger.Share"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_SHARE="match AppStore com.elloapp.messenger.Share"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_WIDGET="match Development com.elloapp.messenger.Widget"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_WIDGET="match AppStore com.elloapp.messenger.Widget"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONSERVICE="match Development com.elloapp.messenger.NotificationService"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONSERVICE="match AppStore com.elloapp.messenger.NotificationService"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONCONTENT="match Development com.elloapp.messenger.NotificationContent"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONCONTENT="match AppStore com.elloapp.messenger.NotificationContent"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_INTENTS="match Development com.elloapp.messenger.SiriIntents"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_INTENTS="match AppStore com.elloapp.messenger.SiriIntents"
export DEVELOPMENT_PROVISIONING_PROFILE_WATCH_APP="match Development com.elloapp.messenger.watchkitapp"
export DISTRIBUTION_PROVISIONING_PROFILE_WATCH_APP="match AppStore com.elloapp.messenger.watchkitapp"
export DEVELOPMENT_PROVISIONING_PROFILE_WATCH_EXTENSION="match Development com.elloapp.messenger.watchkitapp.watchkitextension"
export DISTRIBUTION_PROVISIONING_PROFILE_WATCH_EXTENSION="match AppStore com.elloapp.messenger.watchkitapp.watchkitextension"

BUILDBOX_DIR="buildbox"

export CODESIGNING_PROFILES_VARIANT="appstore"

$@
