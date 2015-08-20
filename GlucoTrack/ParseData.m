//
//  ParseData.m
//  SugarNursing
//
//  Created by Dan on 15-1-5.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ParseData.h"
#import "UtilsMacro.h"


@implementation ParseData

+ (id)parseDictionary:(NSDictionary *)data ForKeyPath:(NSString *)keyPath
{
    if (!data) {
        DDLogDebug(@"Dictionary to parese is nil.");
        return nil;
    }
    if (!keyPath) {
        DDLogDebug(@"Keypath of Dictionary is nil.");
        return nil;
    }
    if (![data isKindOfClass:[NSDictionary class]]) {
        DDLogDebug(@"Data to parse is not NSDictionaray class.");
        return nil;
    }
    
    id  parseData = data;
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    
    for (__block NSString *key in keys) {
        
        
        if ([parseData isKindOfClass:[NSDictionary class]] || [parseData isKindOfClass:[NSMutableDictionary class]]) {
            if (![[parseData allKeys] containsObject:key]) {
//                DDLogDebug(@"%@ does not contains key:%@",data, key);
                return nil;
            }
            parseData = parseData[key];
            
        }else if ([parseData isKindOfClass:[NSArray class]] || [parseData isKindOfClass:[NSMutableArray class]]){
            if (0 == [key integerValue] && ![key isEqualToString:@"0"]) {
                DDLogDebug(@"Array keypath is not a integer Value.");
                return nil;
            }
            if (!([key integerValue] >= 0 && [key integerValue] < [parseData count])) {
                DDLogDebug(@"Index %ld beyond array bounds",(long)[key integerValue]);
                return nil;
            }
            
            parseData = [parseData objectAtIndex:[key integerValue]];
            
        }else{
            DDLogDebug(@"Unkonwn Error in parse data. Running %@ %@",[self class],NSStringFromSelector(_cmd));
            return nil;
        }
        
    }
    
    return parseData;
}

+ (BOOL)parseDateIsAvaliable:(NSDate *)date
{
    NSDate *now = [NSDate date];
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:date];
    if (timeInterval < 0) {
        
        UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
        [windowView addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Date Format is not avaliable", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)parseFuthureDateIsAvaliable:(NSDate *)date
{
    NSDate *now = [NSDate date];
    NSTimeInterval timeinterval = [now timeIntervalSinceDate:date];
    if (timeinterval > 0) {
        UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
        [windowView addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Futhure Date Format is not avaliable", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)parseDateStringIsAvaliable:(NSString *)dateString format:(NSString *)format
{
    if (!dateString || !format) {
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return [self parseDateIsAvaliable:date];
}

+ (BOOL)parseUserNameIsAvaliable:(NSString *)userName
{
    if ([userName isEqualToString:@""] || !userName) {
        UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
        [windowView addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"UserName cannot be empty", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return NO;
    }
    
    NSString *match = @"(^[A-Za-z0-9_@. ]{1,24}$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",match];
    if (![predicate evaluateWithObject:userName]) {
        UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
        [windowView addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"UserName Format is not avaliable", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return NO;
    }
    
    return YES;
}

+ (BOOL)parsePasswordIsAvaliable:(NSString *)password
{
    if (!password || [password length] < 6 || [password length] > 16) {
        
        UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
        [windowView addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Password Format is not avaliable", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        
        return NO;
    }
    return YES;
}

+ (BOOL)parseStringIsAvaliable:(NSString *)string
{
    if (!string) {
        return NO;
    }
    if ([string isEqualToString:@""] || [string isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}

+ (BOOL)parseIsCurrentUser:(NSString *)userName
{
    if (![[NSString userName] isEqualToString:userName]) {
        
        if (![[NSString email] isEqualToString:userName]) {
            
            if (![[NSString indentityCard] isEqualToString:userName]) {
                
                if (![[NSString phoneNumber] isEqualToString:userName]) {
                    UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
                    [windowView addSubview:hud];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = NSLocalizedString(@"You are not the current user", nil);
                    [hud show:YES];
                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
                    
                    return NO;
                }
                
            }
        }
        
       
    }
    return YES;
}

+ (BOOL)parseCodeIsAvaliable:(NSString *)codeString
{
    if (!codeString) {
        UIView *windowView = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windowView];
        [windowView addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Code cannot be empty", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        
        return NO;
    }
    return YES;
}

@end
