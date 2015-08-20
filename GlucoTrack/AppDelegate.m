 //
//  AppDelegate.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AppDelegate.h"
#import "UIStoryboard+Storyboards.h"
#import "AppDelegate+CustomAppearence.h"
#import "RootViewController.h"
#import "LeftMenuController.h"
#import <CocoaLumberjack.h>
#import "UtilsMacro.h"
#import "VendorMacro.h"
#import "AppDelegate+UserLogInOut.h"
#import "AppVersionHelper.h"
#import "UMessage.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
//#import "UMSocialTencentWeiboHandler.h"
#import "AppNotificationHelper.h"
#import "AppMacro.h"
#import "DeviceHelper.h"
#import "SPKitExample.h"



@interface AppDelegate ()

@property(nonatomic, strong) id rootVCObserveToken;
@property(nonatomic, strong) NSDictionary *launchOptions;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [self configureDefaultSetting:launchOptions];
    [self configureSystemFontSize];
    [self configureCustomizing];
    [self configureCocoaLumberjackFramework];
    [self configureUMAnalytics];
    [self configureUMSocialService];
    [self initWXIM];
    [self configureUMAPNS];
    [self configureUserLogin];
    
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    // Not to setFrame for UIWindow, it invokes some orientation issues!
    // self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    return YES;
}

- (void)configureDefaultSetting:(NSDictionary *)launchOptions
{
    self.launchOptions = launchOptions;
    self.rootVCObserveToken = [KeyValueObserver observeObject:self.window keyPath:@"rootViewController" target:self selector:@selector(rootVCDidLoad:) options:NSKeyValueObservingOptionOld];
}

#pragma mark - Application Status

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    DDLogInfo(@"My token is: %@", deviceToken);
    
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:newToken forKey:@"Device_Token"];
    [userDefaults synchronize];
    
    [UMessage registerDeviceToken:deviceToken];
}

- (void)fetchNewMessage
{
    RootViewController *rootVC = (RootViewController *)self.window.rootViewController;
    LeftMenuController *leftMenu = (LeftMenuController *)rootVC.leftMenuViewController;
    [leftMenu getNewMessages];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//     App will not recieve remote notifications when user login out.
    [self fetchNewMessage];

    switch (application.applicationState) {
        case UIApplicationStateActive:
        case UIApplicationStateBackground:
        {
            AppNotificationHelper *notifHelper = [AppNotificationHelper shareNotificationHelper];
            [notifHelper handleNotification:userInfo];
            [UMessage didReceiveRemoteNotification:userInfo];
            break;
        }
        case UIApplicationStateInactive:
        {
            break;
        }
        default:
            break;
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"action1_identifier"]) {

    }
    completionHandler();
}


- (void)applicationWillTerminate:(UIApplication *)application {

    //Handle Terminate condition
}

- (void)configureCustomizing
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:44/255.0 green:125/255.0 blue:198/255.0 alpha:1]];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

#pragma mark - User Login

- (void)configureUserLogin
{
    // Not User exists.
    if (![[NSString userIsLogin] boolValue])
    {
        [AppDelegate userLogOut];
        return;
    }
    
    [AppDelegate userLogIn];
}

- (void)rootVCDidLoad:(NSDictionary *)change
{
    if (![[NSString userIsLogin] boolValue])
    {
        return;
    }
    
    // handle remoteNotification when app lanuched.
    UILocalNotification *remoteNotif = [self.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *userInfo = (NSDictionary *)remoteNotif;
    
    if (remoteNotif)
    {
        AppNotificationHelper *notifHelper = [AppNotificationHelper shareNotificationHelper];
        [notifHelper handleNotification:userInfo];
    }
    else
    {
//        RootViewController *rootVC = (RootViewController *)self.window.rootViewController;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [rootVC presentLeftMenuViewController];
//        });
    }

}

#pragma Configure Library Framework

- (void)configureCocoaLumberjackFramework
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    UIColor *blue = [UIColor colorWithRed:(34/255.0) green:(79/255.0) blue:(188/255.0) alpha:0.8];
    UIColor *green = [UIColor colorWithRed:(27/255.0) green:(152/255.0) blue:(73/255.0) alpha:0.8];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:blue backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:green backgroundColor:nil forFlag:DDLogFlagDebug];
}

- (void)configureUMAnalytics
{
//    AppVersionHelper *helper = [AppVersionHelper shareVersionHelper];
//    [helper configureAppFramework];
}

- (void)configureUMSocialService
{
    [UMSocialData setAppKey:UM_ANALYTICS_KEY];
    [UMSocialWechatHandler setWXAppId:@"wx4acaaa802038adc0" appSecret:@"5461992f15f32ac74314a8be13973918" url:UM_REDIRECT_URL];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.lifecaring.cn/"];
//    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
    [UMSocialConfig setNavigationBarConfig:^(UINavigationBar *bar, UIButton *closeButton, UIButton *backButton, UIButton *postButton, UIButton *refreshButton, UINavigationItem *navigationItem) {
        [bar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [bar setBarTintColor:[UIColor colorWithRed:44/255.0 green:125/255.0 blue:198/255.0 alpha:1]];
        [bar setTranslucent:YES];
        [closeButton setImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
        [postButton setImage:[UIImage imageNamed:@"yes.png"] forState:UIControlStateNormal];
        
        UILabel *label = (UILabel *)navigationItem.titleView;
        label.textColor = [UIColor whiteColor];
        
    }];
}


#pragma mark - FontSize
- (void)configureSystemFontSize
{
    [DeviceHelper configureAppropriateFontSize];
//    [[UILabel appearance] setFont:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]];
}


#pragma mark - 初始化阿里百川IM
- (void)initWXIM{
    
    if ([[SPKitExample sharedInstance] exampleInit]) {
        /// 监听连接状态
        [[SPKitExample sharedInstance] exampleListenConnectionStatus];
        
        /// 设置头像和昵称
        [[SPKitExample sharedInstance] exampleSetProfile];
        
        
        /// 监听新消息
        [[SPKitExample sharedInstance] exampleListenNewMessage];
        
        /// 监听头像点击事件
        [[SPKitExample sharedInstance] exampleListenOnClickAvatar];
        
        /// 监听链接点击事件
        [[SPKitExample sharedInstance] exampleListenOnClickUrl];
        
        /// 自定义皮肤
        [[SPKitExample sharedInstance] exampleCustomUISkin];
        return;
    }
    else
    {
        
    }
    
    
}

#pragma mark - APNS
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)configureUMAPNS
{
    [UMessage startWithAppkey:UM_MESSAGE_APPKEY launchOptions:self.launchOptions];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title= NSLocalizedString(@"Accept", nil);
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title= NSLocalizedString(@"Reject", nil);
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:UIUserNotificationActionContextDefault];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObjects:categorys, nil]];

        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert
         |UIRemoteNotificationTypeNewsstandContentAvailability];
    }
#else
    
    //register remoteNotification types
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    
    //for log
    [UMessage setLogEnabled:YES];
    [UMessage setAutoAlert:NO];
    [UMessage setBadgeClear:NO];
    
}


@end
