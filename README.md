# ElloApp iOS Source Code Compilation Guide

## Starting 

For current app progress one should run in Terminal such command:
```
git clone https://github.com/valsegal/ellomessenger-ios.git
```
## Adjust Configuration

1. Edit `ElloApp/BUILD` to change bundleID.
2. Place your `App provision profile` to `ElloApp`, `build-system/elloapp-codesigning/profiles`, `build-system/example-configuration/provisioning/profiles` folders with `ElloApp.mobileprovision` name.
3. Place your `AppNotificationContent provision profile` to `ElloApp`, `build-system/elloapp-codesigning/profiles`, `build-system/example-configuration/provisioning/profiles` folders with `ElloAppNotificationContent.mobileprovision` name.
4. Place your `AppNotificationService provision profile` to `ElloApp`, `build-system/elloapp-codesigning/profiles`, `build-system/example-configuration/provisioning/profiles` folders with `ElloAppNotificationService.mobileprovision` name.
5. Place your `AppShare provision profile` to `ElloApp`, `build-system/elloapp-codesigning/profiles`, `build-system/example-configuration/provisioning/profiles` folders with `ElloAppShare.mobileprovision` name.
6. Edit the file `submodules/ELServer/Sources/ELServer.swift` and replace `..._server.example.com` with your server address. 

## Compilation Guide

To work with project one should run build script **r.sh**.

This script have couple options:

 **--clear** clear project cache
 
 **--project** build and create xcode project for app try and debug.
 
 **--build** build and create **.ipa** file for uploading to AppStore.
 
 **-bn=xx** default = 100. Optional key for setup projects build' number.
 
 **App version** setups in file **versions.json**  
