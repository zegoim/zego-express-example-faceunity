# Zego Express Example FaceUnity (Android/iOS)

[English](README.md) | [中文](README_zh.md)

Zego Express FaceUnity 示例 demo

## 准备环境

请确保开发环境满足以下技术要求：

> Android

* Android Studio 2.1 或以上版本
* 已经下载好 Android SDK 28、Android SDK Platform-Tools 28.*.*
* Android 版本不低于 4.0.3 且支持音视频的 Android 设备或模拟器（推荐使用真机），如果是真机，请开启“允许调试”选项。
* Android 设备已经连接到 Internet

> iOS

* Xcode 6.0 或以上版本
* iOS 8.0 或以上版本且支持音视频的 iOS 设备或模拟器（推荐使用真机）
* iOS 设备已经连接到 Internet

## 下载 SDK

### Android

此 Repository 中可能缺少运行 Demo 工程所需的 SDK `libZegoExpressEngine.so` 与 `ZegoExpressEngine.jar`，若工程的 `ZegoExpressExample/main/libs` 文件夹中不存在对应的`libZegoExpressEngine.so` 与 `ZegoExpressEngine.jar`， 需要下载并放入 Demo 工程的 `ZegoExpressExample/main/libs` 文件夹中。

**[https://storage.zego.im/express/video/android/zh/zego-express-video-android-zh.zip](https://storage.zego.im/express/video/android/zh/zego-express-video-android-zh.zip)**

最终，`android/app/libs` 目录下的结构应如下

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

此 Repository 中缺少运行 Demo 工程所需的 SDK `ZegoExpressEngine.framework`，需要下载并放入 Demo 工程的 `Libs` 文件夹中

> 直接运行 Demo，编译前脚本若检测到 `Libs` 文件夹下不存在 SDK Framework 时会自动下载 **英文版** SDK。如需 **中文版** SDK 请自行下载并放入 `Libs` 文件夹中。

**[https://storage.zego.im/express/video/ios/zh/zego-express-video-ios-zh.zip](https://storage.zego.im/express/video/ios/zh/zego-express-video-ios-zh.zip)**

> 请注意，压缩包中有两个文件夹：`armv7-arm64` 和 `armv7-arm64-x86_64`，区别在于：

1. `armv7-arm64` 内的动态库仅包含真机的架构（armv7, arm64）。开发者在最终上架 App 时，需要使用此文件夹下的 `ZegoExpressEngine.framework`，否则可能被 App Store 拒绝。

2. `armv7-arm64-x86_64` 内的动态库包含了真机与模拟器架构（armv7, arm64, x86_64）。如果开发者需要使用到模拟器来开发调试，需要使用此文件夹下的 `ZegoExpressEngine.framework`。但是最终上架 App 时，要切换回 `armv7-arm64` 文件夹下的 Framework。（注：如果使用 CocoaPods 集成则无需担心包架构问题，CocoaPods 在 Archive 时会自动裁掉模拟器架构）

> 请解压缩 `ZegoExpressEngine.framework` 并将其放在 `Libs` 目录下

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

## 运行示例代码

### 获取 ZEGO AppID 和 AppSign

要运行此示例 App，您将需要一个 ZEGO AppID 和一个对应的 AppSign，该 App 才能访问 ZEGO 服务器。请参考 [获取 AppID 和 AppSign 指引](https://doc.zego.im/API/HideDoc/GetExpressAppIDGuide/GetAppIDGuideline.html)

### 获取 FaceUnity 鉴权证书 authpack

此项目中的 authpack 已经绑定了 BundleID，您需要联系 [FaceUnity](http://www.faceunity.com/) 获取鉴权证书 authpack 并替换。

### Android

1. 修改 `android/app/src/main/java/im/zego/expressample/faceu/demo/` 目录下的 `GetAppIdConfig.java`，填写正确的 AppID 和 AppSign。

    > **注意：需要在 AppID 后加 L**，需要补充的地方请参考下图：

    <img src="https://storage.zego.im/sdk-doc/Pics/Android/ExpressSDK/SampleRunningGuide/fill_appid_appSign_in_android_demo.jpg">

### iOS

1. 修改 `ios/ZegoExpressExample-FaceUnity-iOS/Helper/` 目录下的 `ZGKeyCenter.m`，填写正确的 AppID 和 AppSign。

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/appid-appsign.png" width=80% height=80%>

2. 替换从 FaceUnity 获取到的 `authpack.h` 并替换到 `ios/Libs/FaceUnity/authpack.h`。
