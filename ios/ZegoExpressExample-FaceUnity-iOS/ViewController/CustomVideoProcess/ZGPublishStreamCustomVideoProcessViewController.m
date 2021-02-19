//
//  ZGPublishStreamCustomVideoProcessViewController.m
//  ZegoExpressExample-FaceUnity-iOS
//
//  Created by Patrick Fu on 2021/1/18.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGPublishStreamCustomVideoProcessViewController.h"
#import "ZGPublishSettingTableViewController.h"

#import "ZGKeyCenter.h"
#import "ZGUserIDHelper.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>

#import "FUManager.h"
#import "FUAPIDemoBar.h"

@interface ZGPublishStreamCustomVideoProcessViewController () <ZegoEventHandler, ZegoCustomVideoProcessHandler, FUAPIDemoBarDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDstreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;

@property (nonatomic, strong) UIBarButtonItem *settingButton;
@property (nonatomic, strong) UIBarButtonItem *startLiveButton;
@property (nonatomic, strong) UIBarButtonItem *stopLiveButton;

// The FaceUnity control bar at the bottom of the screen
@property (nonatomic, strong) FUAPIDemoBar *faceUnityDemoBar;

@end

@implementation ZGPublishStreamCustomVideoProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Enable FaceUnity filter
    [[FUManager shareManager] loadFilter];

    // Load FaceUnity's Light Beauty Bundle
    [[FUManager shareManager] loadMakeupBundleWithName:@"light_makeup"];

    // Setup UI
    [self setupLabel];
    [self setupBarButton];
    [self setupFaceUnityDemoBar];

    // Start
    [self createEngineAndLoginRoom];
    [self startLive];
}

- (void)dealloc {
    NSLog(@" 🏳️ Release FaceUnity");
    // Release FaceUnity SDK
    [FUManager releaseManager];

    NSLog(@" 🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:^{
        // This callback is only used to notify the completion of the release of internal resources of the engine.
        // Developers cannot release resources related to the engine within this callback.
        //
        // In general, developers do not need to listen to this callback.
        NSLog(@" 🚩 🏳️ Destroy ZegoExpressEngine complete");
    }];

    // In order not to affect the play stream demo, restore the default engine configuration.
    [ZegoExpressEngine setEngineConfig:[[ZegoEngineConfig alloc] init]];
}

- (void)setupLabel {
    self.title = @"Publish Stream";

    self.roomStateLabel.text = @"Disconnected 🔴";
    self.roomStateLabel.textColor = [UIColor whiteColor];
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.publisherStateLabel.text = @"NoPublish 🔴";
    self.publisherStateLabel.textColor = [UIColor whiteColor];
    self.publisherStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.roomIDstreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
    self.roomIDstreamIDLabel.textColor = [UIColor whiteColor];
    self.roomIDstreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.publishResolutionLabel.text = @"Resolution: 720x1280";
    self.publishResolutionLabel.textColor = [UIColor whiteColor];
    self.publishResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.publishQualityLabel.text = @"Quality:";
    self.publishQualityLabel.textColor = [UIColor whiteColor];
    self.publishQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
}

- (void)setupFaceUnityDemoBar {
    // The FaceUnity control bar at the bottom of the screen
    self.faceUnityDemoBar = [[FUAPIDemoBar alloc] init];
    [self demoBarSetBeautyDefultParams];
    [self.view addSubview:self.faceUnityDemoBar];

    self.faceUnityDemoBar.translatesAutoresizingMaskIntoConstraints = NO;

    NSArray *hLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[demoBar]|" options:0 metrics:nil views:@{@"demoBar": self.faceUnityDemoBar}];
    [self.view addConstraints:hLayout];

    NSString *vFormat;
    if (@available(iOS 11.0, *)) {
        vFormat = [NSString stringWithFormat:@"V:[demoBar(>=200)]-%d-|", (int)UIApplication .sharedApplication.keyWindow.safeAreaInsets.bottom];
    } else {
        vFormat = @"V:[demoBar(>=200)]|";
    }
    NSArray *vLayout = [NSLayoutConstraint constraintsWithVisualFormat:vFormat options:0 metrics:nil views:@{@"demoBar": self.faceUnityDemoBar}];
    [self.view addConstraints:vLayout];
}

- (void)setupBarButton {
    // Setting Button
    self.settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingController)];

    // Start/Stop live button
    self.startLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startLive)];
    self.stopLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopLive)];
    self.navigationItem.rightBarButtonItems = @[self.startLiveButton, self.settingButton];

}

- (void)showSettingController {
    ZGPublishSettingTableViewController *vc = [ZGPublishSettingTableViewController instanceFromStoryboard];
    vc.preferredContentSize = CGSizeMake(250.0, 150.0);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.barButtonItem = self.settingButton;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)createEngineAndLoginRoom {

    NSLog(@" 🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:[ZGKeyCenter appID] appSign:[ZGKeyCenter appSign] isTestEnv:YES scenario:ZegoScenarioGeneral eventHandler:self];

    // Init process config
    ZegoCustomVideoProcessConfig *processConfig = [[ZegoCustomVideoProcessConfig alloc] init];
    processConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;

    // Enable custom video process
    [[ZegoExpressEngine sharedEngine] enableCustomVideoProcessing:YES config:processConfig];

    // Set custom video process handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoProcessHandler:self];

    // Login room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    NSLog(@" 🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];

    // Set video config, 720p
    [[ZegoExpressEngine sharedEngine] setVideoConfig:[ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P]];
}

- (void)startLive {
    // Start preview
    NSLog(@" 🔌 Start preview");
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.previewView]];

    // Start publishing
    NSLog(@" 📤 Start publishing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
}

- (void)stopLive {
    // Stop preview
    NSLog(@" 🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    // Stop publishing
    NSLog(@" 📤 Stop publishing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];

    self.publishQualityLabel.text = @"Quality:";
}

#pragma mark - ZegoCustomVideoProcessHandler

- (void)onCapturedUnprocessedCVPixelBuffer:(CVPixelBufferRef)buffer timestamp:(CMTime)timestamp channel:(ZegoPublishChannel)channel {

    // ⭐️ Processing video frame data with FaceUnity
    CVPixelBufferRef processedPixelBuffer = [[FUManager shareManager] renderItemsToPixelBuffer:buffer];

    // ⭐️ Send pixel buffer to ZEGO SDK
    [[ZegoExpressEngine sharedEngine] sendCustomVideoProcessedCVPixelBuffer:processedPixelBuffer timestamp:timestamp];
}

#pragma mark - ZegoEventHandler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {

    if (errorCode != 0) {
        NSLog(@" 🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode);
    } else {
        if (state == ZegoRoomStateConnected) {
            NSLog(@" 🚩 🚪 Login room success");
            self.roomStateLabel.text = @"RoomState: Connected 🟢";
        } else if (state == ZegoRoomStateConnecting) {
            NSLog(@" 🚩 🚪 Requesting login room");
            self.roomStateLabel.text = @"RoomState: Requesting 🟡";
        } else if (state == ZegoRoomStateDisconnected) {
            NSLog(@" 🚩 🚪 Logout room");
            self.roomStateLabel.text = @"RoomState: Disconnected 🔴";
        }
    }
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {

    if (errorCode != 0) {
        NSLog(@" 🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode: %d", streamID, errorCode);
    } else {
        if (state == ZegoPublisherStatePublishing) {
            NSLog(@" 🚩 📤 Publishing stream");
            self.publisherStateLabel.text = @"PublisherState: Publishing 🟢";
            self.navigationItem.rightBarButtonItems = @[self.stopLiveButton, self.settingButton];

        } else if (state == ZegoPlayerStatePlayRequesting) {
            NSLog(@" 🚩 📤 Requesting publish stream");
            self.publisherStateLabel.text = @"PublisherState: Requesting 🟡";
            self.navigationItem.rightBarButtonItems = @[self.stopLiveButton, self.settingButton];

        } else if (state == ZegoPlayerStateNoPlay) {
            NSLog(@" 🚩 📤 Stop publishing stream");
            self.publisherStateLabel.text = @"PublisherState: NoPublish 🔴";
            self.navigationItem.rightBarButtonItems = @[self.startLiveButton, self.settingButton];
        }
    }
}

// When using custom video capture, this callback will not be triggered
- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSString *networkQuality = @"";
    switch (quality.level) {
        case 0:
            networkQuality = @"☀️";
            break;
        case 1:
            networkQuality = @"⛅️";
            break;
        case 2:
            networkQuality = @"☁️";
            break;
        case 3:
            networkQuality = @"🌧";
            break;
        case 4:
            networkQuality = @"❌";
            break;
        default:
            break;
    }
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"FPS: %d fps \n", (int)quality.videoSendFPS];
    [text appendFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareEncode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = [text copy];
}

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    NSLog(@" 🚩 Debug error, errorCode: %d, funcName: %@, info: %@", errorCode, funcName, info);
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark - FaceUnity method

// The following methods are all FaceUnity business logic

- (void)demoBarSetBeautyDefultParams {
    _faceUnityDemoBar.delegate = nil ;
    _faceUnityDemoBar.skinDetect = [FUManager shareManager].skinDetectEnable;
    _faceUnityDemoBar.heavyBlur = [FUManager shareManager].blurShape ;
    _faceUnityDemoBar.blurLevel = [FUManager shareManager].blurLevel ;
    _faceUnityDemoBar.colorLevel = [FUManager shareManager].whiteLevel ;
    _faceUnityDemoBar.redLevel = [FUManager shareManager].redLevel;
    _faceUnityDemoBar.eyeBrightLevel = [FUManager shareManager].eyelightingLevel ;
    _faceUnityDemoBar.toothWhitenLevel = [FUManager shareManager].beautyToothLevel ;

    _faceUnityDemoBar.vLevel =  [FUManager shareManager].vLevel;
    _faceUnityDemoBar.eggLevel = [FUManager shareManager].eggLevel;
    _faceUnityDemoBar.narrowLevel = [FUManager shareManager].narrowLevel;
    _faceUnityDemoBar.smallLevel = [FUManager shareManager].smallLevel;
    _faceUnityDemoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
    _faceUnityDemoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
    _faceUnityDemoBar.chinLevel = [FUManager shareManager].jewLevel ;
    _faceUnityDemoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
    _faceUnityDemoBar.noseLevel = [FUManager shareManager].noseLevel ;
    _faceUnityDemoBar.mouthLevel = [FUManager shareManager].mouthLevel ;

    _faceUnityDemoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
    _faceUnityDemoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
    _faceUnityDemoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
    _faceUnityDemoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
    _faceUnityDemoBar.selectedFilterLevel = [FUManager shareManager].selectedFilterLevel;
    _faceUnityDemoBar.delegate = self;
    _faceUnityDemoBar.demoBar.selMakeupIndex = _faceUnityDemoBar.demoBar.makeupView.supIndex;
}

#pragma mark FUAPIDemoBarDelegate

// Set beauty parameters

- (void)demoBarBeautyParamChanged{
    [self syncBeautyParams];
}

- (void)restDefaultValue:(int)type{
    if (type == 1) { // Skin beauty
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeSkin];
    }

    if (type == 2) {
        [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeShape];
    }

    [self demoBarSetBeautyDefultParams];
}

- (void)syncBeautyParams{
    [FUManager shareManager].skinDetectEnable = _faceUnityDemoBar.skinDetect;
    [FUManager shareManager].blurShape = _faceUnityDemoBar.heavyBlur;
    [FUManager shareManager].blurLevel = _faceUnityDemoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _faceUnityDemoBar.colorLevel;
    [FUManager shareManager].redLevel = _faceUnityDemoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _faceUnityDemoBar.eyeBrightLevel;
    [FUManager shareManager].beautyToothLevel = _faceUnityDemoBar.toothWhitenLevel;
    [FUManager shareManager].vLevel = _faceUnityDemoBar.vLevel;
    [FUManager shareManager].eggLevel = _faceUnityDemoBar.eggLevel;
    [FUManager shareManager].narrowLevel = _faceUnityDemoBar.narrowLevel;
    [FUManager shareManager].smallLevel = _faceUnityDemoBar.smallLevel;
    [FUManager shareManager].enlargingLevel = _faceUnityDemoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _faceUnityDemoBar.thinningLevel;
    [FUManager shareManager].jewLevel = _faceUnityDemoBar.chinLevel;
    [FUManager shareManager].foreheadLevel = _faceUnityDemoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _faceUnityDemoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _faceUnityDemoBar.mouthLevel;;

    /* 暂时解决展示表中，没有显示滤镜，引起bug */
    if (![[FUManager shareManager].beautyFiltersDataSource containsObject:_faceUnityDemoBar.selectedFilter]) {
        return;
    }
    [FUManager shareManager].selectedFilter = _faceUnityDemoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _faceUnityDemoBar.selectedFilterLevel;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.faceUnityDemoBar hiddeTopView];
}

@end
