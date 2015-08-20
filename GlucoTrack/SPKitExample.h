//
//  SPKitExample.h
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/11.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WXOpenIMSDKFMWK/YWFMWK.h>
#import <WXOUIModule/YWUIFMWK.h>

#import "AppDelegate.h"

@class SPLoginController;
@class YWIMKit;

@interface SPKitExample : NSObject

+ (instancetype)sharedInstance;


#pragma mark - basic

/**
 *  初始化的示例代码
 */
- (BOOL)exampleInit;


/**
 *  登录的示例代码
 */
- (void)exampleLoginWithUserID:(NSString *)aUserID password:(NSString *)aPassword successBlock:(void(^)())aSuccessBlock failedBlock:(void(^)(NSError *aError))aFailedBlock;

/**
 *  监听连接状态
 */
- (void)exampleListenConnectionStatus;

/**
 *  注销的示例代码
 */
- (void)exampleLogout;

#pragma mark - abilities

/**
 *  设置头像和昵称
 */
- (void)exampleSetProfile;

#pragma mark - UI pages

/**
 *  创建会话列表页面
 */
- (YWConversationListViewController *)exampleMakeConversationListControllerWithSelectItemBlock:(YWConversationsListDidSelectItemBlock)aSelectItemBlock;

/**
 *  打开某个会话
 */
- (void)exampleOpenConversationViewControllerWithConversation:(YWConversation *)aConversation fromNavigationController:(UINavigationController *)aNavigationController;

/**
 *  某个会话Controller
 */
- (YWConversationViewController *)exampleMakeConversationViewControllerWithConversation:(YWConversation *)aConversation;


/**
 *  打开单聊页面
 */
- (void)exampleOpenConversationViewControllerWithPerson:(YWPerson *)aPerson fromNavigationController:(UINavigationController *)aNavigationController;

/**
 *  打开群聊页面
 */
- (void)exampleOpenConversationViewControllerWithTribe:(YWTribe *)aTribe fromNavigationController:(UINavigationController *)aNavigationController;

#pragma mark - Customize

/**
 *  添加输入面板插件
 */
- (void)exampleAddInputViewPluginToConversationController:(YWConversationViewController *)aConversationController;

/**
 *  发送自定义消息
 */
- (void)exampleSendCustomMessageWithConversationController:(YWConversationViewController *)aConversationController;

/**
 *  设置如何显示自定义消息
 */
- (void)exampleShowCustomMessageWithConversationController:(YWConversationViewController *)aConversationController;

/**
 *  自定义全局导航栏
 */
- (void)exampleCustomGlobleNavigationBar;

/**
 *  自定义皮肤
 */
- (void)exampleCustomUISkin;

#pragma mark - events

/**
 *  监听新消息
 */
- (void)exampleListenNewMessage;

/**
 * 头像点击事件
 */
- (void)exampleListenOnClickAvatar;

/**
 *  链接点击事件
 */
- (void)exampleListenOnClickUrl;


#pragma mark - apns

/**
 *  设置DeviceToken
 */
- (void)exampleSetDeviceToken:(NSData *)aDeviceToken;

/**
 *  处理启动时APNS消息
 */
- (void)exampleHandleAPNSWithLaunchOptions:(NSDictionary *)aLaunchOptions;

/**
 *  处理运行时APNS消息
 */
- (void)exampleHandleRunningAPNSWithUserInfo:(NSDictionary *)aUserInfo;

#pragma mark - EService

/**
 *  获取EService对象
 */
- (YWPerson *)exampleFetchEServicePersonWithPersonId:(NSString *)aPersonId groupId:(NSString *)aGroupId;

@end

@interface SPKitExample ()

@property (nonatomic, readonly) AppDelegate *appDelegate;

@property (nonatomic, readonly) UINavigationController *rootNavigationController;

@property (nonatomic, readonly) SPLoginController *rootLoginController;

@end
