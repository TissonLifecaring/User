//
//  AppVersionHelper.h
//  GlucoTrack
//
//  Created by Dan on 15-2-10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobClick.h>
#import "VendorMacro.h"


@interface AppVersionHelper : NSObject

+ (instancetype)shareVersionHelper;

- (void)configureAppFramework;
- (void)checkAppVersion;

@end
