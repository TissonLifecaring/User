//
//  DeviceHelper.h
//  GlucoTrack
//
//  Created by Ian on 15-4-17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceHelper : NSObject

//判断设备并设置适当的字体大小
+ (void)configureAppropriateFontSize;

+ (NSString *)deviceModelName;

+ (BOOL)iphone4;

+ (BOOL)iphone5;

+ (BOOL)iphone6;

+ (BOOL)iphone6Plus;

+ (BOOL)ipad;

+ (BOOL)phone;

+ (BOOL)pad;


+ (CGFloat)normalFontSize;

+ (CGFloat)biggerFontSize;

+ (CGFloat)smallerFontSize;

+ (CGFloat)biggestFontSize;



@end
