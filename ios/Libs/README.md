# Please put the `ZegoExpressEngine.framework` under this folder

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
