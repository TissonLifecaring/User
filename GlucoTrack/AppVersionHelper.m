//
//  AppVersionHelper.m
//  GlucoTrack
//
//  Created by Dan on 15-2-10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AppVersionHelper.h"
#import <MBProgressHUD.h>

@interface AppVersionHelper()<MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (strong, nonatomic ) NSString *appURL;

@end

@implementation AppVersionHelper

+ (instancetype)shareVersionHelper
{
    static AppVersionHelper *versionHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionHelper = [[AppVersionHelper alloc] init];
    });
    return versionHelper;
}

- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)configureAppFramework
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick startWithAppkey:UM_ANALYTICS_KEY reportPolicy:BATCH channelId:nil];
    [MobClick setAppVersion:version];
    [MobClick checkUpdate:NSLocalizedString(@"New Version", nil) cancelButtonTitle:NSLocalizedString(@"Skip", nil) otherButtonTitles:NSLocalizedString(@"Go", nil)];
}

- (void)checkAppVersion
{
    UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
    hud = [[MBProgressHUD alloc] initWithView:windowView];
    [windowView addSubview:hud];
    hud.labelText = NSLocalizedString(@"Loading…", nil);
    [hud show:YES];
    [hud hide:YES afterDelay:15.0f];
    
    [MobClick checkUpdateWithDelegate:self selector:@selector(versionInfoCallBack:)];
    
}

- (void)versionInfoCallBack:(NSDictionary *)versionInfo
{
    
    if ([[versionInfo valueForKey:@"update"] isEqualToString:@"YES"]) {
        
        [hud hide:YES];
        NSString *title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"New Version", nil),[versionInfo valueForKey:@"version"]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:[versionInfo valueForKey:@"update_log"] delegate:self cancelButtonTitle:NSLocalizedString(@"Skip", nil) otherButtonTitles:NSLocalizedString(@"Go", nil), nil];
        [alertView show];
        self.appURL = [versionInfo valueForKey:@"path"];
        
    }else{
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"已是最新版本", nil);
        [hud hide:YES afterDelay:1.25];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appURL]];
    }
}


@end
