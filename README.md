# Zego Express Example FaceUnity (Android/iOS)

[English](README.md) | [中文](README_zh.md)

Zego Express Example FaceUnity Demo (Android/iOS)

## Prepare the environment

Please ensure that the development environment meets the following technical requirements:

> Android

* Android Studio 2.1 or higher
* Android SDK Packages: Android SDK 25, Android SDK Build-Tools 25.0.2, Android SDK Platform-Tools 25.*.*
* An Android Device (or emulator) running on Android 4.0.3 or higher version with a camera and microphone (a real device is recommended).
* The Android device and your computer are connected to the Internet.

> iOS

* Xcode 6.0 or higher
* iOS devices or simulators with iOS version no less than 8.0 and audio and video support (the real machine is recommended).
* iOS device already connected to Internet

## Download SDK

### Android

The SDK `libZegoExpressEngine.so` and `ZegoExpressEngine.jar` required to run the Demo project is missing from this Repository, and needs to be downloaded and placed in the Libs folder of the Demo project.

**[https://storage.zego.im/express/video/android/en/zego-express-video-android-en.zip](https://storage.zego.im/express/video/android/en/zego-express-video-android-en.zip)**

finally, the structure under the `android/app/libs` directory should be as follows:

```tree
.
├── README.md
├── README_zh.md
├── ios
└── android
    └── app
        └── libs
            ├── ZegoExpressEngine.jar
            ├── arm64-v8a
            │   └── libZegoExpressEngine.so
            ├── armeabi-v7a
            │   └── libZegoExpressEngine.so
            └── x86
                └── libZegoExpressEngine.so
```

### iOS

The SDK `ZegoExpressEngine.framework` required to run the Demo project is missing from this Repository, and needs to be downloaded and placed in the `Libs` folder of the Demo project

> Run Demo directly, if the pre-compilation script detects that there is no SDK Framework under `Libs`, it will automatically download the **English version** SDK. You can also download it yourself and put it in the `Libs` folder.

**[https://storage.zego.im/express/video/ios/en/zego-express-video-ios-en.zip](https://storage.zego.im/express/video/ios/en/zego-express-video-ios-en.zip)**

> Note that there are two folders in the zip file: `armv7-arm64` and `armv7-arm64-x86_64`, differences:

1. The dynamic framework in `armv7-arm64` contains only the architecture of the real machine (armv7, arm64). Developers need to use `ZegoExpressEngine.framework` in this folder when distributing the app, otherwise it may be rejected by App Store.

2. The dynamic framework in `armv7-arm64-x86_64` contains the real machine and simulator architecture (armv7, arm64, x86_64). If developers need to use the simulator to develop and debug, they need to use `ZegoExpressEngine.framework` in this folder. But when the app is finally distributed, you need to switch back to the Framework under the `armv7-arm64` folder. (Note: If you use CocoaPods to integrate, you do n’t need to worry about the framework architecture. CocoaPods will automatically cut the simulator architecture when Archive)

> Please unzip and put the `ZegoExpressEngine.framework` under `Libs`

```tree
.
├── README.md
├── README_zh.md
├── android
└── ios
    ├── Libs
    │   ├── FaceUnity
    │   └── ZegoExpressEngine.framework
    ├── ZegoExpressExample-FaceUnity-iOS
    └── ZegoExpressExample-FaceUnity-iOS.xcodeproj
```

## Running the sample code

### Obtain Your ZEGO AppID and AppSign

To build and run this sample app, you will need a ZEGO AppID and a corresponding AppSign for the app to access the ZEGO server. Please refer to the [ZEGO Admin Console User Manual | _blank](https://doc-en.zego.im/en/1271.html) for the detailed instructions on how to obtain this information.

### Obtain Your FaceUnity authpack

The authpack in the project is bound to BundleID, you need to contact [FaceUnity](http://www.faceunity.com/) to obtain authpack and replace.

### Android

1. Modify the source file `GetAppIdConfig.java` in the directory `android/app/src/main/java/im/zego/expressample/faceu/demo/` to assign values to the variables `appID` and `appSign`.

    > Please note that you need to **append a letter L to the AppID value** you get from the ZEGO Admin Console when assigning the value to the variable `appID` in the program.

    <img src="https://storage.zego.im/sdk-doc/Pics/Android/ExpressSDK/SampleRunningGuide/fill_appid_appSign_in_android_demo.jpg">

2. Replace your `authpack.java` obtained from FaceUnity to the path `android/app/src/main/java/im/zego/expressample/faceu/demo/faceunity/authpack.java`.

### iOS

1. Modify the source file `ZGKeyCenter.m` under the directory `ios/ZegoExpressExample-FaceUnity-iOS/Helper/` to fill in the correct AppID and AppSign.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/appid-appsign-en.png" width=70% height=70%>

2. Replace your `authpack.h` obtained from FaceUnity to the path `ios/Libs/FaceUnity/authpack.h`.
