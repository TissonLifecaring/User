//
//  AppDelegate+UserLogInOut.m
//  SugarNursing
//
//  Created by Dan on 14-11-6.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AppDelegate+UserLogInOut.h"
#import "UIStoryboard+Storyboards.h"
#import "UtilsMacro.h"
#import "UMessage.h"
#import "VendorMacro.h"
#import "AppDelegate.h"
#import "SPKitExample.h"


@implementation AppDelegate (UserLogInOut)

+ (void)userLogIn
{
    [self configureAPNSSettings];
    [self configureSupportedLanguage];
    [self loginIMWithSuccessBlock:nil failedBlock:nil];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = [[UIStoryboard mainStoryboard] instantiateInitialViewController];
}

+ (void)configureAPNSSettings
{

    [UMessage addTag:DEVICE_IPHONE response:^(id responseObject, NSInteger remain, NSError *error) {
    }];
    [UMessage addAlias:[NSString userID] type:@"userId" response:^(id responseObject, NSError *error) {
        
    }];
   
}
//登陆阿里百川
+ (void)loginIMWithSuccessBlock:(void(^)())successBlock failedBlock:(void(^)())failedBlock
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.ywIMKit)
    {
        NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"openIMAccount"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"openIMPwd"];
        
        [[SPKitExample sharedInstance] exampleLoginWithUserID:account password:password successBlock:^{
            if (successBlock)
            {
                successBlock();
            }
        } failedBlock:^(NSError *aError) {
            if (failedBlock)
            {
                failedBlock();
            }
        }];
    }
}

+ (void)configureSupportedLanguage
{

    NSDictionary *parameters = @{@"method":@"setUserLanguage",
                                 @"sessionId":[NSString sessionID],
                                 @"accountId":[NSString userID],
                                 @"language":[NSString language],
                                 @"sign":@"sign"};
    
    [GCRequest userGetAppLanguageWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
            }
        }
    }];
}


+ (void)userLogOut
{
    
    
    [self removeAPNSSettings];

    // Delete user loginInfo in CoreData when user logout.
    NSArray *userObjects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    for (User *user in userObjects)
    {
        user.sessionId = @"";
        user.sessionToken = @"";
    }
    [[CoreDataStack sharedCoreDataStack] saveContext];
    
    //注销阿里百川
    [self logOutIM];
    
    // Delete user reminders in Calendar stack when user logout
    [[CalendarStack shareCalendarStack] deleteAllReminderForCalendarType:EKTypeDrug completionBlock:^{
    }];
    [[CalendarStack shareCalendarStack] deleteAllReminderForCalendarType:EKTypeDetection completionBlock:^{
    }];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GCUserIsReminded"];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = [[UIStoryboard loginStoryboard] instantiateInitialViewController];
    
}

+ (void)logOutIM
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[appDelegate.ywIMKit.IMCore getLoginService] isCurrentLogined])
    {
        [[SPKitExample sharedInstance] exampleLogout];
    }
}

+ (void)removeAPNSSettings
{
    [UMessage removeAllTags:^(id responseObject, NSInteger remain, NSError *error) {}];
    [UMessage removeAlias:[NSString userID] type:@"userId" response:^(id responseObject, NSError *error) {}];
}

@end
