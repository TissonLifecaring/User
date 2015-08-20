//
//  NSString+Ret_msg.m
//  GlucoCare
//
//  Created by Dan on 15-1-12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NSString+Ret_msg.h"
#import "AppDelegate+UserLogInOut.h"
#import <MBProgressHUD.h>

@implementation NSString (Ret_msg)

+ (NSString *)localizedMsgFromRet_code:(NSString *)ret_code withHUD:(BOOL)hasHud;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ret_code" ofType:@"plist"];
    NSDictionary *codeDic = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSString *localizedString = [codeDic valueForKey:ret_code];
    
    if (!localizedString) {
        localizedString = NSLocalizedString(@"Request Error", nil);
    }
    
    
    if ([ret_code isEqualToString:@"-6"])
    {
        
        if (!hasHud)
        {
            UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
            [windowView addSubview:hud];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = localizedString;
            [hud show:YES];
            [hud hide:YES afterDelay:1.25];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AppDelegate userLogOut];
        });
        
    }
    
    
    return localizedString;
}

+ (NSString *)localizedErrorMesssagesFromError:(NSError *)error
{
    NSString *message;
    if (error.localizedDescription && (error.localizedRecoverySuggestion || error.localizedFailureReason)) {
        
        if (error.localizedRecoverySuggestion) {
            message = error.localizedRecoverySuggestion;
        } else {
            message = error.localizedFailureReason;
        }
    } else if (error.localizedDescription) {
        
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            switch ([error code]) {
                case NSURLErrorCannotFindHost:
                    message = NSLocalizedString(@"Cannot find specified host.", nil);
                    break;
                case NSURLErrorCannotConnectToHost:
                    message = NSLocalizedString(@"Cannot connect to specified host.", nil);
                    break;
                case NSURLErrorNotConnectedToInternet:
                    message = NSLocalizedString(@"Cannot connect to the internet.", nil);
                    break;
                default:
                    message = [error localizedDescription];
                    break;
            }
        }else{
            message = [error localizedDescription];
        }
        
        
    } else {
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Error: %ld", @"Localizable", @"Fallback Error Failure Reason Format"), error.domain, (long)error.code];
    }
    
    return message;
}


@end
