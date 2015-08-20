//
//  AppNotificationHelper.h
//  GlucoTrack
//
//  Created by Dan on 15-3-9.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppNotificationHelper : NSObject

+ (instancetype)shareNotificationHelper;

- (void)handleNotification:(NSDictionary *)userInfo;

@end
