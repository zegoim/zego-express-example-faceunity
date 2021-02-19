//
//  ZGLoginViewController.m
//  ZegoExpressExample-FaceUnity-iOS
//
//  Created by Patrick Fu on 2020/5/10.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGLoginViewController.h"
#import "ZGPublishStreamCustomVideoCaptureViewController.h"
#import "ZGPublishStreamCustomVideoProcessViewController.h"
#import "ZGPlayStreamViewController.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "FURenderer.h"

NSString* const ZGRoomIDKey = @"ZGRoomID";
NSString* const ZGStreamIDKey = @"ZGStreamID";

@interface ZGLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSeg;

@property (weak, nonatomic) IBOutlet UILabel *engineVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *faceUnityVersionLabel;

@end

@implementation ZGLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];

}

- (void)setupUI {
    self.engineVersionLabel.text = [NSString stringWithFormat:@"ZegoExpressEngine SDK Version: %@", [ZegoExpressEngine getVersion]];
    self.faceUnityVersionLabel.text = [NSString stringWithFormat:@"FaceUnity SDK Version: %@", [FURenderer getVersion]];

    self.roomIDTextField.text = [self savedValueForKey:ZGRoomIDKey];
    self.streamIDTextField.text = [self savedValueForKey:ZGStreamIDKey];
}

- (IBAction)publishStreamButtonClicked:(UIButton *)sender {
    [self saveValue:self.roomIDTextField.text forKey:ZGRoomIDKey];
    [self saveValue:self.streamIDTextField.text forKey:ZGStreamIDKey];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if (self.modeSeg.selectedSegmentIndex == 0) {
        ZGPublishStreamCustomVideoProcessViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPublishStreamCustomVideoProcessViewController class])];
        vc.roomID = self.roomIDTextField.text;
        vc.streamID = self.streamIDTextField.text;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.modeSeg.selectedSegmentIndex == 1) {
        ZGPublishStreamCustomVideoCaptureViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPublishStreamCustomVideoCaptureViewController class])];
        vc.roomID = self.roomIDTextField.text;
        vc.streamID = self.streamIDTextField.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)playStreamButtonClicked:(UIButton *)sender {
    [self saveValue:self.roomIDTextField.text forKey:ZGRoomIDKey];
    [self saveValue:self.streamIDTextField.text forKey:ZGStreamIDKey];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    ZGPlayStreamViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPlayStreamViewController class])];
    vc.roomID = self.roomIDTextField.text;
    vc.streamID = self.streamIDTextField.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)modeTipsButtonClicked:(UIButton *)sender {
    NSString *tips = @"'Custom Process' refers to using the ZEGO SDK to capture video frame from camera, the SDK will call back to the app after the video frame data is collected, and the app will resend the video frame to the SDK after processing the video frame by FaceUnity.\n\n"\

        "'Custom Capture' refers to manage the device's camera at the demo app (ie custom video capture), and send the video frame data collected by the camera to the ZEGO SDK after processing by FaceUnity.";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mode Difference" message:tips preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
