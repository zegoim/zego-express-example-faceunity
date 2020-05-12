//
//  ZGLoginViewController.m
//  ZegoExpressExample-FaceUnity-iOS
//
//  Created by Patrick Fu on 2020/5/10.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGLoginViewController.h"
#import "ZGPublishStreamViewController.h"
#import "ZGPlayStreamViewController.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "FURenderer.h"

NSString* const ZGRoomIDKey = @"ZGRoomID";
NSString* const ZGStreamIDKey = @"ZGStreamID";

@interface ZGLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self saveValue:self.roomIDTextField.text forKey:ZGRoomIDKey];
    [self saveValue:self.streamIDTextField.text forKey:ZGStreamIDKey];

    if ([segue.identifier isEqualToString:@"ZGPublishStreamSegue"]) {
        ZGPublishStreamViewController *vc = segue.destinationViewController;
        vc.roomID = self.roomIDTextField.text;
        vc.streamID = self.streamIDTextField.text;
    } else if ([segue.identifier isEqualToString:@"ZGPlayStreamSegue"]) {
        ZGPlayStreamViewController *vc = segue.destinationViewController;
        vc.roomID = self.roomIDTextField.text;
        vc.streamID = self.streamIDTextField.text;
    }
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
