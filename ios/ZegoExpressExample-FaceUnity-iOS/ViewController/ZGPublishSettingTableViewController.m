//
//  ZGPublishSettingTableViewController.m
//  ZegoExpressExample-FaceUnity-iOS
//
//  Created by Patrick Fu on 2020/5/11.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGPublishSettingTableViewController.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGEnableCameraKey = @"ZGEnableCamera";
NSString* const ZGMuteMicrophoneKey = @"ZGMuteMicrophone";
NSString* const ZGMuteSpeakerKey = @"ZGMuteSpeaker";
NSString* const ZGCaptureVolumeKey = @"ZGCaptureVolume";
NSString* const ZGMirrorModeKey = @"ZGMirrorMode";

@interface ZGPublishSettingTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *microphoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *speakerSwitch;
@property (weak, nonatomic) IBOutlet UISlider *captureVolumeSlider;

@property (nonatomic, assign) BOOL enableCamera;
@property (nonatomic, assign) BOOL muteMicrophone;
@property (nonatomic, assign) BOOL muteSpeaker;
@property (nonatomic, assign) int captureVolume;

@end

@implementation ZGPublishSettingTableViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPublishSettingTableViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    NSNumber *enableCameraValue = [self savedValueForKey:ZGEnableCameraKey];
    if (enableCameraValue == nil) {
        self.enableCamera = YES;
    } else {
        self.enableCamera = enableCameraValue.boolValue;
    }
    self.muteMicrophone = ((NSNumber *)[self savedValueForKey:ZGMuteMicrophoneKey]).boolValue;
    self.muteSpeaker = ((NSNumber *)[self savedValueForKey:ZGMuteSpeakerKey]).boolValue;
    self.captureVolume = ((NSNumber *)[self savedValueForKey:ZGCaptureVolumeKey]).intValue ?: 100;

    [self setupUI];
}

- (void)setupUI {
    self.cameraSwitch.on = self.enableCamera;
    self.microphoneSwitch.on = !self.muteMicrophone;
    self.speakerSwitch.on = !self.muteSpeaker;
    self.captureVolumeSlider.continuous = NO;
    self.captureVolumeSlider.value = self.captureVolume;
}

- (IBAction)cameraSwitchValueChanged:(UISwitch *)sender {
    BOOL enableCamera = sender.on;
    [self saveValue:@(enableCamera) forKey:ZGEnableCameraKey];
    [[ZegoExpressEngine sharedEngine] enableCamera:enableCamera];
}

- (IBAction)microphoneSwitchValueChanged:(UISwitch *)sender {
    BOOL muteMicrophone = !sender.on;
    [self saveValue:@(muteMicrophone) forKey:ZGMuteMicrophoneKey];
    [[ZegoExpressEngine sharedEngine] muteMicrophone:muteMicrophone];
}

- (IBAction)speakerSwitchValueChanged:(UISwitch *)sender {
    BOOL muteSpeaker = !sender.on;
    [self saveValue:@(muteSpeaker) forKey:ZGMuteSpeakerKey];
    [[ZegoExpressEngine sharedEngine] muteSpeaker:muteSpeaker];
}

- (IBAction)captureVolumeSliderValueChanged:(UISlider *)sender {
    int volume = (int)sender.value;
    [self saveValue:@(volume) forKey:ZGCaptureVolumeKey];
    [[ZegoExpressEngine sharedEngine] setCaptureVolume:volume];
}


@end
