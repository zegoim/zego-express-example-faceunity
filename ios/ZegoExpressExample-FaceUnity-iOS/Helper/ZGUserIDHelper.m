//
//  ZGUserIDHelper.m
//  ZegoExpressExample-FaceUnity-iOS
//
//  Created by Patrick Fu on 2020/5/10.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGUserIDHelper.h"
#import <sys/utsname.h>

NSString* const ZGUserIDKey = @"ZGUserID";
NSString* const ZGUserNameKey = @"ZGUserName";

static NSString *_userID = nil;
static NSString *_userName = nil;

@implementation ZGUserIDHelper

+ (NSString *)userID {
    if (_userID.length == 0) {
        NSString *userID = [self savedValueForKey:ZGUserIDKey];
        if (userID.length > 0) {
            _userID = userID;
        } else {
            srand((unsigned)time(0));
            userID = [NSString stringWithFormat:@"%@@%u", [ZGUserIDHelper getDeviceModel], (unsigned)rand()%100000];
            _userID = userID;
            [self saveValue:userID forKey:ZGUserIDKey];
        }
    }

    return _userID;
}

+ (NSString *)userName {
    if (_userName.length == 0) {
        NSString *userName = [self savedValueForKey:ZGUserNameKey];
        if (userName.length > 0) {
            _userName = userName;
        } else {
            userName = [ZGUserIDHelper getDeviceModel];
            _userName = userName;
            [self saveValue:userName forKey:ZGUserNameKey];
        }
    }

    return _userName;
}


+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
}

@end
