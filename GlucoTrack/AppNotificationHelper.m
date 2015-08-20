//
//  AppNotificationHelper.m
//  GlucoTrack
//
//  Created by Dan on 15-3-9.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AppNotificationHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RootViewController.h"
#import "UIStoryboard+Storyboards.h"
#import "NSString+UserCommon.h"


@implementation AppNotificationHelper

+ (instancetype)shareNotificationHelper
{
    static AppNotificationHelper *notificationHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationHelper = [[AppNotificationHelper alloc] init];
    });
    
    return notificationHelper;
}

- (void)setUpNotificationAudio
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"wav"];
    SystemSoundID soundID;
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)handleNotification:(NSDictionary *)userInfo
{
    if ([[NSString sessionID] isEqualToString:@""] && [[NSString sessionToken] isEqualToString:@""]) {
        return;
    }
    
    RootViewController *rootVC = (RootViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ([[userInfo valueForKey:@"type"] isEqualToString:@"userMessage"]) {
        
        [rootVC presentLeftMenuViewController];

    }

    if ([[userInfo valueForKey:@"type"] isEqualToString:@"userAdvice"]) {
       
        [rootVC presentLeftMenuViewController];
    }
    


    [self setUpNotificationAudio];

}



@end
