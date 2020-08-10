# Please put the Android ZegoExpressEngine SDK under this folder

The SDK `libZegoExpressEngine.so` and `ZegoExpressEngine.jar` required to run the Demo project is missing from this Repository, and needs to be downloaded and placed in the Libs folder of the Demo project.

**[https://storage.zego.im/express/video/android/zego-express-video-android.zip](https://storage.zego.im/express/video/android/zego-express-video-android.zip)**

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
