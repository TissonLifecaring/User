//
//  NSString+UserCommon.m
//  SugarNursing
//
//  Created by Dan on 14-12-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSString+UserCommon.h"
#import "UtilsMacro.h"

@implementation NSString (UserCommon)

+ (User *)fetchUser
{
    NSArray *userObjects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if ([userObjects count] == 0) {
        DDLogDebug(@"No User Exists");
        return nil;
    }
    User *user = userObjects[0];
    return user;

}

+ (UserInfomation *)fetchUserInfo
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    NSArray *userInfoObjects = [UserInfomation findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
    
    if (userInfoObjects.count == 0) {
        DDLogInfo(@"NO UserInfo Exists");
        return nil;
    }
    
    UserInfomation *userInfo = userInfoObjects[0];
    return userInfo;
}

+ (NSString *)userIsLogin
{
    NSString *isLogin;
    User *user = [self fetchUser];
    if (!user)
    {
        isLogin = @"0";
    }
    else if (user.sessionId && user.sessionToken && user.sessionId.length>0 && user.sessionToken.length>0)
    {
        isLogin = @"1";
    }
    else
    {
        isLogin = @"0";
    }
    
    return isLogin;
}

+ (NSString *)userID
{
    User *user = [self fetchUser];
    if (!user) {
        return @"";
    }
    return user.userId ? user.userId : @"";
}

+ (NSString *)linkmanID
{
    User *user = [self fetchUser];
    if (!user) {
        return @"";
    }
    return user.linkManId ? user.linkManId : @"";
}

+ (NSString *)sessionID
{
    User *user = [self fetchUser];
    if (!user) {
        return @"";
    }
    return user.sessionId ? user.sessionId : @"";
}

+ (NSString *)sessionToken
{
    User *user = [self fetchUser];
    if (!user) {
        return @"";
    }
    return user.sessionToken ? user.sessionToken :@"";
}

+ (NSString *)userName
{
    UserInfomation *userInfo = [self fetchUserInfo];
    if (!userInfo) {
        return @"";
    }
    return userInfo.userName ? userInfo.userName : @"";
}

+ (NSString *)centerID
{
    UserInfomation *userInfo = [self fetchUserInfo];
    if (!userInfo) {
        return @"";
    }
    return userInfo.centerId ? userInfo.centerId : @"";
}

+ (NSString *)userThumbnail
{
    UserInfomation *userInfo = [self fetchUserInfo];
    if (!userInfo) {
        return @"";
    }
    return userInfo.headImageUrl ? userInfo.headImageUrl : @"";
}

+ (NSString *)phoneNumber
{
    UserInfomation *userInfo = [self fetchUserInfo];
    if (!userInfo) {
        return @"";
    }
    return userInfo.mobilePhone ? userInfo.mobilePhone : @"";
}

+ (NSString *)indentityCard
{
    UserInfomation *userInfo = [self fetchUserInfo];
    if (!userInfo) {
        return @"";
    }
    return userInfo.identifyCard ? userInfo.identifyCard : @"";
}

+ (NSString *)email
{
    UserInfomation *userInfo = [self fetchUserInfo];
    if (!userInfo) {
        return @"";
    }
    return userInfo.email ? userInfo.email : @"";
}

// UserSetting

+ (NSString *)language
{
    NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    //    const char *langStr = [preferredLang UTF8String];
    
    // Default is zh-Hans
    NSString *lang = @"1";
    
    if ([preferredLang isEqualToString:@"zh-Hans"]) {
        lang = @"1";
    }
    if ([preferredLang isEqualToString:@"zh-Hant"]) {
        lang = @"2";
    }
    if ([preferredLang isEqualToString:@"en"]) {
        lang = @"3";
    }
    return lang;
}

+ (NSString *)clientSystem
{
    return @"ios";
}

+ (NSString *)deviceToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults valueForKey:@"Device_Token"];
    return token ? token : @"";
}

@end
