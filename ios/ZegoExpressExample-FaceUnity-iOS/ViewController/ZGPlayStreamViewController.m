//
//  ZGPlayStreamViewController.m
//  ZegoExpressExample-FaceUnity-iOS
//
//  Created by Patrick Fu on 2020/5/10.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGPlayStreamViewController.h"
#import "ZGKeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGPlayStreamViewController () <ZegoEventHandler>

@property (weak, nonatomic) IBOutlet UIView *playView;;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDstreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *playResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *playQualityLabel;

@property (nonatomic, strong) UIBarButtonItem *startLiveButton;
@property (nonatomic, strong) UIBarButtonItem *stopLiveButton;

@end

@implementation ZGPlayStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self createEngineAndLoginRoom];
    [self startLive];
}

- (void)dealloc {
    NSLog(@" 🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:^{
        // This callback is only used to notify the completion of the release of internal resources of the engine.
        // Developers cannot release resources related to the engine within this callback.
        //
        // In general, developers do not need to listen to this callback.
        NSLog(@" 🚩 🏳️ Destroy ZegoExpressEngine complete");
    }];
}

- (void)setupUI {
    self.title = @"Play Stream";

    self.roomStateLabel.text = @"Disconnected 🔴";
    self.roomStateLabel.textColor = [UIColor whiteColor];
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.playerStateLabel.text = @"NoPlay 🔴";
    self.playerStateLabel.textColor = [UIColor whiteColor];
    self.playerStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.roomIDstreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
    self.roomIDstreamIDLabel.textColor = [UIColor whiteColor];
    self.roomIDstreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.playResolutionLabel.text = @"Resolution:";
    self.playResolutionLabel.textColor = [UIColor whiteColor];
    self.playResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    self.playQualityLabel.text = @"Quality:";
    self.playQualityLabel.textColor = [UIColor whiteColor];
    self.playQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];

    // Start/Stop live button
    self.startLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startLive)];
    self.stopLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopLive)];
    self.navigationItem.rightBarButtonItem = self.startLiveButton;
}

- (void)createEngineAndLoginRoom {

    NSLog(@" 🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:[ZGKeyCenter appID] appSign:[ZGKeyCenter appSign] isTestEnv:YES scenario:ZegoScenarioGeneral eventHandler:self];

    // Login room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    NSLog(@" 🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];
}

- (void)startLive {
    // Start playing
    NSLog(@" 📥 Start playing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:[ZegoCanvas canvasWithView:self.playView]];
}

- (void)stopLive {
    // Stop playing
    NSLog(@" 📥 Stop playing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];

    self.playResolutionLabel.text = @"Resolution:";
    self.playQualityLabel.text = @"Quality:";
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

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {

    if (errorCode != 0) {
        NSLog(@" 🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode: %d", streamID, errorCode);
    } else {
        if (state == ZegoPlayerStatePlaying) {
            NSLog(@" 🚩 📥 Playing stream");

            self.playerStateLabel.text = @"PlayerState: Playing 🟢";
            self.navigationItem.rightBarButtonItem = self.stopLiveButton;

        } else if (state == ZegoPlayerStatePlayRequesting) {
            NSLog(@" 🚩 📥 Requesting play stream");
            self.playerStateLabel.text = @"PlayerState: Requesting 🟡";
            self.navigationItem.rightBarButtonItem = self.stopLiveButton;

        } else if (state == ZegoPlayerStateNoPlay) {
            NSLog(@" 🚩 📥 Stop playing stream");
            self.playerStateLabel.text = @"PlayerState: NoPlay 🔴";
            self.navigationItem.rightBarButtonItem = self.startLiveButton;
        }
    }
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    self.playResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
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
    [text appendFormat:@"FPS: %d fps\n", (int)quality.videoRecvFPS];
    [text appendFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"HardwareDecode: %@ \n", quality.isHardwareDecode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.playQualityLabel.text = [text copy];
}

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    NSLog(@" 🚩 Debug error, errorCode: %d, funcName: %@, info: %@", errorCode, funcName, info);
}



@end
