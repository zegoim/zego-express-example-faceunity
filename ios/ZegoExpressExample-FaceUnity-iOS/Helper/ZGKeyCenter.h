//
//  ZGKeyCenter.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Sky on 2019/5/10.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This example does not provide ZGKeyCenter.m
 
 Need to be implemented by the user, providing two functions, such as
 
 + (unsigned int)appID {
    return 1234567890;
 }
 
 + (NSString *)appSign {
     return @"0123456789abcdefghijklmnopqrstuzwxyz0123456789abcdefghijklmnopqr";
 }
 
 Please get AppID and AppSign in the ZEGO management console
*/

NS_ASSUME_NONNULL_BEGIN

@interface ZGKeyCenter : NSObject

+ (unsigned int)appID;

+ (NSString *)appSign;

@end

NS_ASSUME_NONNULL_END
