//
//  SPKitExample.m
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/11.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "SPKitExample.h"

#import <WXOpenIMSDKFMWK/YWFMWK.h>
#import <WXOUIModule/YWUIFMWK.h>

#import "AppDelegate.h"
#import "SPUtil.h"


#import "LoginViewController.h"
#import "SPInputViewPluginCustomize.h"

#import "SPBaseBubbleChatViewCustomize.h"
#import "SPBubbleViewModelCustomize.h"
#import "LoginViewController.h"
#import "UtilsMacro.h"
#import "NSString+UserCommon.h"



@interface SPKitExample ()

@end

@implementation SPKitExample


#pragma mark - properties

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (UINavigationController *)rootNavigationController
{
    return [self.appDelegate.window.rootViewController isKindOfClass:[UINavigationController class]] ? (UINavigationController *)self.appDelegate.window.rootViewController : nil;
}

- (LoginViewController *)rootLoginController
{
    return [self.rootNavigationController.viewControllers.firstObject isKindOfClass:[LoginViewController class]] ? self.rootNavigationController.viewControllers.firstObject : nil;
}


#pragma mark - private methods


#pragma mark - public methods

+ (instancetype)sharedInstance
{
    static SPKitExample *sExample = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sExample = [[SPKitExample alloc] init];
    });
    
    return sExample;
}

#pragma mark - basic

/**
 *  初始化示例代码
 */
- (BOOL)exampleInit;
{
    /// 设置环境
    [[YWAPI sharedInstance] setEnvironment:YWEnvironmentRelease];
    /// 开启日志
    [[YWAPI sharedInstance] setLogEnabled:YES];
    
    NSLog(@"SDKVersion:%@", [YWAPI sharedInstance].YWSDKIdentifier);
    
    NSError *error = nil;
    
    /// 异步初始化IM SDK
    [[YWAPI sharedInstance] syncInitWithOwnAppKey:IM_USER_KEY getError:&error];
    
    if (error.code != 0 && error.code != YWSdkInitErrorCodeAlreadyInited) {
        /// 初始化失败
        return NO;
    } else {
        if (error.code == 0)
        {
            /// 首次初始化成功
            /// 获取一个IMKit并持有
            self.appDelegate.ywIMKit = [[YWAPI sharedInstance] fetchIMKitForOpenIM];
        }
        else
        {
            /// 已经初始化
        }
        return YES;
    }
}

/**
 *  登录的示例代码
 */
- (void)exampleLoginWithUserID:(NSString *)aUserID password:(NSString *)aPassword successBlock:(void(^)())aSuccessBlock failedBlock:(void (^)(NSError *))aFailedBlock
{
    aSuccessBlock = [aSuccessBlock copy];
    aFailedBlock = [aFailedBlock copy];
    
    /// 登录之前，先告诉IM如何获取登录信息。
    /// 当IM向服务器发起登录请求之前，会调用这个block，来获取用户名和密码信息。
    [[self.appDelegate.ywIMKit.IMCore getLoginService] setFetchLoginInfoBlock:^(YWFetchLoginInfoCompletionBlock aCompletionBlock) {
        /// 你可能需要从你的服务器异步获取这些信息，包括用户的显示名称等。成功后再调用aCompletionBlock，告诉IM
        /// 在示例中，我们就直接把输入框中的信息，告诉IM
        NSString *name = [NSString userName];
        aCompletionBlock(YES, aUserID, aPassword, name, nil);
    }];
    
    /// 发起登录
    [[self.appDelegate.ywIMKit.IMCore getLoginService] asyncLoginWithCompletionBlock:^(NSError *aError, NSDictionary *aResult) {
        if (aError.code == 0 || [[self.appDelegate.ywIMKit.IMCore getLoginService] isCurrentLogined]) {
            /// 登录成功
            
            if (aSuccessBlock) {
                aSuccessBlock();
            }
        } else {
            
            NSLog(@"IM 登录失败 error: %@",aError.description);
            if (aFailedBlock) {
                aFailedBlock(aError);
            }
        }
    }];
}

/**
 *  监听连接状态
 */
- (void)exampleListenConnectionStatus
{
    
    [[self.appDelegate.ywIMKit.IMCore getLoginService] addConnectionStatusChangedBlock:^(YWIMConnectionStatus aStatus, NSError *aError) {
        if (aStatus == YWIMConnectionStatusForceLogout || aStatus == YWIMConnectionStatusMannualLogout || aStatus == YWIMConnectionStatusAutoConnectFailed) {
            
            /// 手动登出、被踢、自动连接失败，都记录下来
            self.appDelegate.ywIsConnect = NO;
        }
        if (aStatus == YWIMConnectionStatusConnected)
        {
            self.appDelegate.ywIsConnect = YES;
        }
    } forKey:[self description] ofPriority:YWBlockPriorityDeveloper];
}


/**
 *  注销的示例代码
 */
- (void)exampleLogout
{
    [[self.appDelegate.ywIMKit.IMCore getLoginService] asyncLogoutWithCompletionBlock:NULL];
}


#pragma mark - abilities

- (void)exampleSetProfile
{
    /// IM会在需要显示profile时，调用这个block，来获取用户的头像和昵称
    [self.appDelegate.ywIMKit setFetchProfileBlock:^(YWPerson *aPerson, YWFetchProfileCompletionBlock aCompletionBlock) {
        /// 理论上您一般会从服务器异步获取用户的profile信息，在成功后调用aCompletionBlock，将结果告诉IM
        /// 在我们的示例代码中，则直接从本地获取
        
        [[SPUtil sharedInstance] getPersonDisplayInfoOfPerson:aPerson CompleteBlock:^(NSString *name, UIImage *image) {
            aCompletionBlock(YES, aPerson, name, image);
        }];
        
    }];
}


#pragma mark - ui pages

/**
 *  创建会话列表页面
 */
- (YWConversationListViewController *)exampleMakeConversationListControllerWithSelectItemBlock:(YWConversationsListDidSelectItemBlock)aSelectItemBlock
{
    YWConversationListViewController *result = [self.appDelegate.ywIMKit makeConversationListViewController];
    
    [result setDidSelectItemBlock:aSelectItemBlock];
    
    return result;
}

/**
 *  打开某个会话
 */
- (void)exampleOpenConversationViewControllerWithConversation:(YWConversation *)aConversation fromNavigationController:(UINavigationController *)aNavigationController
{
    __block YWConversationViewController *alreadyController = nil;
    [aNavigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YWConversationViewController class]]) {
            YWConversationViewController *c = obj;
            if (aConversation.conversationId && [c.conversation.conversationId isEqualToString:aConversation.conversationId]) {
                alreadyController = c;
                *stop = YES;
            }
        }
    }];
    
    if (alreadyController) {
        [aNavigationController popToViewController:alreadyController animated:YES];
        [aNavigationController setNavigationBarHidden:NO];
        return;
    } else {
        YWConversationViewController *conversationController = [self.appDelegate.ywIMKit makeConversationViewControllerWithConversationId:aConversation.conversationId];
        
        [aNavigationController pushViewController:conversationController animated:YES];
        [aNavigationController setNavigationBarHidden:NO];
        
        /// 添加自定义插件
        [self exampleAddInputViewPluginToConversationController:conversationController];
        
        /// 添加自定义表情
        [self exampleShowCustomEmotionWithConversationController:conversationController];
        
        /// 设置显示自定义消息
        [self exampleShowCustomMessageWithConversationController:conversationController];
    }
}

/**
 *  某个会话Controller
 */
- (YWConversationViewController *)exampleMakeConversationViewControllerWithConversation:(YWConversation *)aConversation
{
    YWConversationViewController *conversationController = [self.appDelegate.ywIMKit makeConversationViewControllerWithConversationId:aConversation.conversationId];
    
    /// 添加自定义插件
    [self exampleAddInputViewPluginToConversationController:conversationController];
    
    /// 设置显示自定义消息
    [self exampleShowCustomMessageWithConversationController:conversationController];
    
    return conversationController;
}



/**
 *  打开单聊页面
 */
- (void)exampleOpenConversationViewControllerWithPerson:(YWPerson *)aPerson fromNavigationController:(UINavigationController *)aNavigationController
{
    YWConversation *conversation = [YWP2PConversation fetchConversationByPerson:aPerson creatIfNotExist:YES baseContext:self.appDelegate.ywIMKit.IMCore];
    
    [self exampleOpenConversationViewControllerWithConversation:conversation fromNavigationController:aNavigationController];
}

/**
 *  打开群聊页面
 */
- (void)exampleOpenConversationViewControllerWithTribe:(YWTribe *)aTribe fromNavigationController:(UINavigationController *)aNavigationController
{
    YWConversation *conversation = [YWTribeConversation fetchConversationByTribe:aTribe createIfNotExist:YES baseContext:self.appDelegate.ywIMKit.IMCore];
    
    [self exampleOpenConversationViewControllerWithConversation:conversation fromNavigationController:aNavigationController];
}


#pragma mark - Customize

/**
 *  自定义全局导航栏
 */
- (void)exampleCustomGlobleNavigationBar
{
    // 自定义导航栏背景
    if ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedDescending )
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:1.f*0xb4/0xff blue:1.f alpha:1.f]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    else
    {
        UIImage *originImage = [UIImage imageNamed:@"pub_title_bg"];
        UIImage *backgroundImage = [originImage resizableImageWithCapInsets:UIEdgeInsetsMake(44, 7, 4, 7)];
        [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    
    
    // 自定义导航栏及导航按钮，可参考下面的文章
    // http://www.appcoda.com/customize-navigation-status-bar-ios-7/
}

/**
 *  自定义皮肤
 */
- (void)exampleCustomUISkin
{
    // 使用自定义UI资源和配置
    YWIMKit *imkit = self.appDelegate.ywIMKit;
    
    NSString *bundleName = @"CustomizedUIResources.bundle";
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleName];
    NSBundle *customizedUIResourcesBundle = [NSBundle bundleWithPath:bundlePath];
    [imkit setCustomizedUIResources:customizedUIResourcesBundle];
}

/**
 *  添加输入面板插件
 */
- (void)exampleAddInputViewPluginToConversationController:(YWConversationViewController *)aConversationController
{
    /// 创建自定义插件
    SPInputViewPluginCustomize *plugin = [[SPInputViewPluginCustomize alloc] init];
    /// 添加插件
    [aConversationController.messageInputView addPlugin:plugin];
}

/**
 *  发送自定义消息
 */
- (void)exampleSendCustomMessageWithConversationController:(YWConversationViewController *)aConversationController
{
    __weak typeof(aConversationController) weakController = aConversationController;
    
    /// 构建一个自定义消息
    YWMessageBodyCustomize *body = [[YWMessageBodyCustomize alloc] initWithMessageCustomizeContent:@"Hi!" summary:@"您收到一个招呼"];
    
    /// 发送该自定义消息
    [aConversationController.conversation asyncSendMessageBody:body progress:^(CGFloat progress, NSString *messageID) {
        NSLog(@"消息发送进度:%lf", progress);
    } completion:^(NSError *error, NSString *messageID) {
#ifdef DEBUG
        if (error.code == 0) {
            [[SPUtil sharedInstance] showNotificationInViewController:weakController title:@"打招呼成功!" subtitle:nil type:SPMessageNotificationTypeSuccess];
        } else {
            [[SPUtil sharedInstance] showNotificationInViewController:weakController title:@"打招呼失败!" subtitle:nil type:SPMessageNotificationTypeError];
        }
#endif
    }];
}

/**
 *  设置如何显示自定义消息
 */
- (void)exampleShowCustomMessageWithConversationController:(YWConversationViewController *)aConversationController
{
    /// 设置用于显示自定义消息的ViewModel
    /// ViewModel，顾名思义，一般用于解析和存储结构化数据
    [aConversationController setHook4BubbleViewModel:^YWBaseBubbleViewModel *(id<IYWMessage> message) {
        if ([[message messageBody] isKindOfClass:[YWMessageBodyCustomize class]]) {
            SPBubbleViewModelCustomize *viewModel = [[SPBubbleViewModelCustomize alloc] initWithMessage:message];
            return viewModel;
        }
        
        return nil;
    }];
    
    /// 设置用于显示自定义消息的ChatView
    /// ChatView一般从ViewModel中获取已经解析的数据，用于显示
    [aConversationController setHook4BubbleView:^YWBaseBubbleChatView *(YWBaseBubbleViewModel *message) {
        if ([message isKindOfClass:[SPBubbleViewModelCustomize class]]) {
            SPBaseBubbleChatViewCustomize *chatView = [[SPBaseBubbleChatViewCustomize alloc] init];
            return chatView;
        }
        
        return nil;
    }];
}

/**
 *  设置如何显示自定义表情
 */
- (void)exampleShowCustomEmotionWithConversationController:(YWConversationViewController *)aConversationController
{
    for ( id item in aConversationController.messageInputView.allPluginList )
    {
        if ( ![item isKindOfClass:[YWInputViewPluginEmoticonPicker class]] ) continue;
        
        YWInputViewPluginEmoticonPicker *emotionPicker = (YWInputViewPluginEmoticonPicker *)item;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"YW_TGZ_Emoitons" ofType:@"emo"];
        NSArray *groups = [YWEmoticonGroupLoader emoticonGroupsWithEMOFilePath:filePath];
        
        for (YWEmoticonGroup *group in groups)
        {
            [emotionPicker addEmoticonGroup:group];
        }
    }
}


#pragma mark - events

/**
 *  监听新消息
 */
- (void)exampleListenNewMessage
{
    [self.appDelegate.ywIMKit setOnNewMessageBlock:^(NSString *aSenderId, NSString *aContent, NSInteger aType, NSDate *aTime) {
        /// 你可以播放您的提示音
    }];
}

/**
 * 头像点击事件
 */
- (void)exampleListenOnClickAvatar
{
    [self.appDelegate.ywIMKit setOpenProfileBlock:^(YWPerson *aPerson, UIViewController *aParentController) {
        /// 您可以打开该用户的profile页面
        [[SPUtil sharedInstance] showNotificationInViewController:aParentController title:@"打开profile" subtitle:aPerson.description type:SPMessageNotificationTypeMessage];
    }];
}


/**
 *  链接点击事件
 */
- (void)exampleListenOnClickUrl
{
    [self.appDelegate.ywIMKit setOpenURLBlock:^(NSString *aURLString, UIViewController *aParentController) {
        /// 您可以使用您的容器打开该URL
        YWWebViewController *controller = [YWWebViewController makeControllerWithUrlString:aURLString];
        [aParentController.navigationController pushViewController:controller animated:YES];
    }];
}


#pragma mark - apns

/**
 *  设置DeviceToken
 */
- (void)exampleSetDeviceToken:(NSData *)aDeviceToken
{
#ifdef DEBUG
    [[SPUtil sharedInstance] showNotificationInViewController:self.appDelegate.window.rootViewController title:@"设置DeviceToken" subtitle:aDeviceToken.description type:SPMessageNotificationTypeMessage];
#endif
    
    [[[YWAPI sharedInstance] getGlobalPushService] setDeviceToken:aDeviceToken];
}

/**
 *  处理启动时APNS消息
 */
- (void)exampleHandleAPNSWithLaunchOptions:(NSDictionary *)aLaunchOptions
{
    /// 初始化->登录->打开单聊页面
    
    __weak typeof(self) weakSelf = self;
    
    [[[YWAPI sharedInstance] getGlobalPushService] handleLaunchOptionsV2:aLaunchOptions completionBlock:^(NSDictionary *aAPS, NSString *aConversationId, __unsafe_unretained Class aConversationClass) {
        
        if (aConversationId == nil) {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.rootLoginController autoLoginWithCompletionBlock:^{
//                YWConversation *conversation = nil;
//                if (aConversationClass == [YWP2PConversation class]) {
//                    conversation = [YWP2PConversation fetchConversationByConversationId:aConversationId creatIfNotExist:YES baseContext:weakSelf.appDelegate.ywIMKit.IMCore];
//                } else if (aConversationClass == [YWTribeConversation class]) {
//                    conversation = [YWTribeConversation fetchConversationByConversationId:aConversationId creatIfNotExist:YES baseContext:weakSelf.appDelegate.ywIMKit.IMCore];
//                }
//                if (conversation) {
//                    [weakSelf exampleOpenConversationViewControllerWithConversation:conversation fromNavigationController:weakSelf.rootNavigationController];
//                }
//            }];
        });
    }];
}

/**
 *  处理运行时APNS消息
 */
- (void)exampleHandleRunningAPNSWithUserInfo:(NSDictionary *)aUserInfo
{
    __weak typeof(self) weakSelf = self;
    
    /// 第一时间获取state，在block中获取的state不准确
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    
    [[[YWAPI sharedInstance] getGlobalPushService] handlePushUserInfoV2:aUserInfo completionBlock:^(NSDictionary *aAPS, NSString *aConversationId, __unsafe_unretained Class aConversationClass) {
        
        if (aConversationId == nil) {
            return;
        }
        
        if (state != UIApplicationStateActive) {
//            [self.rootLoginController autoLoginWithCompletionBlock:^{
//                YWConversation *conversation = nil;
//                if (aConversationClass == [YWP2PConversation class]) {
//                    conversation = [YWP2PConversation fetchConversationByConversationId:aConversationId creatIfNotExist:YES baseContext:weakSelf.appDelegate.ywIMKit.IMCore];
//                } else if (aConversationClass == [YWTribeConversation class]) {
//                    conversation = [YWTribeConversation fetchConversationByConversationId:aConversationId creatIfNotExist:YES baseContext:weakSelf.appDelegate.ywIMKit.IMCore];
//                }
//                if (conversation) {
//                    [weakSelf exampleOpenConversationViewControllerWithConversation:conversation fromNavigationController:weakSelf.rootNavigationController];
//                }
//            }];
        } else {
            /// 应用处于前台
            /// 建议不做处理，等待IM连接建立后，收取离线消息。
        }
    }];
}

#pragma mark - EService

/**
 *  获取EService对象
 */
- (YWPerson *)exampleFetchEServicePersonWithPersonId:(NSString *)aPersonId groupId:(NSString *)aGroupId
{
    return [[YWPerson alloc] initWithPersonId:aPersonId EServiceGroupId:aGroupId baseContext:self.appDelegate.ywIMKit.IMCore];
}
@end
