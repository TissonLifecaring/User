//
//  IWXOUIService.h
//  WXOpenIMSDK
//
//  Created by huanglei on 14/12/16.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "IYWUIServiceDef.h"

@class YWPerson, YWTribe;

@class YWConversationListViewController, YWConversationViewController;


#pragma mark - 常量及类型定义



#pragma mark - Service接口定义

/**
 *  UI Service公开接口
 */

@protocol IYWUIService <NSObject>

#pragma mark - UI API

/**
 *  打开首页
 *  @brief 如果尚未连接到服务器，首先会连接到服务器
 *  @param aController 用以弹出IM页面的外部Controller，例如H5容器Controller
 *  @return 如果尚未设置登录能力，则返回NO，否则返回YES
 */
- (BOOL)openHomeFromController:(UIViewController *)aController;

/**
 *  创建会话列表页面
 *  @return 所创建的会话列表页面
 */
- (YWConversationListViewController *)makeConversationListViewController;

/**
 *  打开单聊页面
 *  @brief 如果尚未连接到服务器，首先会连接到服务器
 *  @param aPerson 聊天对象
 *  @param aController 用以弹出IM页面的外部Controller，例如H5容器Controller
 *  @return 如果尚未设置登录能力或者personId为空，则返回NO，否则返回YES
 */
- (BOOL)openChatWithPerson:(YWPerson *)aPerson fromController:(UIViewController *)aController;

/**
 *  构建单聊页面
 *  @param aPerson 聊天对象
 */
- (YWConversationViewController *)makeConversationViewControllerWithPerson:(YWPerson *)aPerson;


/**
 *  打开群聊页面
 *  @param aTribe 群
 *  @param aController 用以弹出IM页面的外部Controller，例如H5容器Controller
 *  @return 如果尚未设置登录能力或者aTribe为空，则返回NO
 */
- (BOOL)openChatWithTribe:(YWTribe *)aTribe fromController:(UIViewController *)aController;

/**
 *  构建群聊页面
 *  @param aTribe 群聊对象
 */
- (YWConversationViewController *)makeConversationViewControllerWithTribe:(YWTribe *)aTribe;


/**
 *  打开单聊页面
 *  @brief 如果尚未连接到服务器，首先会连接到服务器
 *  @param aConversationId 聊天会话Id。注意：conversationId与personId并不等同。您一般不能自己构造一个conversationId，而是从conversation等特定接口中才能读取到conversationId。如果需要使用personId来打开会话，应该使用openChatWithPerson这个接口。
 *  @param aController 用以弹出IM页面的外部Controller，例如H5容器Controller
 *  @return 如果尚未设置登录能力或者conversation为空，则返回NO，否则返回YES
 */

- (BOOL)openChatWithConversationId:(NSString *)aConversationId fromController:(UIViewController *)aController;

/**
 *  通过会话Id构建聊天页面
 *  @param aConversationId 会话Id
 *  @return 聊天页面
 */
- (YWConversationViewController *)makeConversationViewControllerWithConversationId:(NSString *)aConversationId;

/**
 *  关闭openIM SDK的UI界面，但是不会断开登录。
 *  @param aAnimated 是否需要动画
 */
- (void)dismissSDKUIAnimated:(BOOL)aAnimated;


/**
 *  导航栏返回按钮，如果没有设置，则为默认返回字样
 */
@property (nonatomic, strong) UIButton *navigationBackButton;



#pragma mark - 能力获取

@property (nonatomic, copy, readonly) YWFetchProfileBlock fetchProfileBlock;
/**
 *  当IM需要显示profile时，会调用这个block
 *  @param aUserId 用户Id
 *  @param aCompletionBlock 获取profile完成后，调用这个block通知IM
 */
- (void)setFetchProfileBlock:(YWFetchProfileBlock)fetchProfileBlock;

@property (nonatomic, copy, readonly) YWMakeBackButtonBlock makeBackButtonBlock;
/**
 *  当IM需要显示导航栏按钮时，会调用这个block，你需要构建一个新的按钮，用于显示在导航栏的左上角
 */
- (void)setMakeBackButtonBlock:(YWMakeBackButtonBlock)makeBackButtonBlock;




#pragma mark - 事件回调


@property (nonatomic, copy, readonly) YWUnreadCountChangedBlock unreadCountChangedBlock;
/**
 *  未读数发生变化
 *  @param aCount 总的未读数
 */
- (void)setUnreadCountChangedBlock:(YWUnreadCountChangedBlock)aBlock;


@property (nonatomic, copy, readonly) YWOnNewMessageBlock onNewMessageBlock;
/// 新消息通知的block
- (void)setOnNewMessageBlock:(YWOnNewMessageBlock)aBlock;






#pragma mark - 用户行为回调


@property (nonatomic, copy, readonly) YWOpenURLBlock openURLBlock;
/**
 *  打开某个url的回调block
 *  @param aURLString 某个url
 *  @param aParentController 用于打开的顶层控制器
 */
- (void)setOpenURLBlock:(YWOpenURLBlock)aBlock;


@property (nonatomic, copy, readonly) YWAutoLoginForH5Block autoLoginForH5Block;
/**
 *  h5页面需要免登的回调
 */
- (void)setAutoLoginForH5Block:(YWAutoLoginForH5Block)autoLoginForH5Block;


@property (nonatomic, copy, readonly) YWUIPreviewImageMessageBlock previewImageMessageBlock;
/**
 *  当IMUIKit需要预览图片消息时，会调用这个block
 */
- (void)setPreviewImageMessageBlock:(YWUIPreviewImageMessageBlock)previewImageMessageBlock;


@property (nonatomic, copy, readonly) YWOpenProfileBlock openProfileBlock;
/**
 *  打开某个profile的回调block
 *  @param aUserId 某个userId
 *  @param aParentController 用于打开的顶层控制器
 */
- (void)setOpenProfileBlock:(YWOpenProfileBlock)openProfileBlock;





#pragma mark - 提示信息

@property (nonatomic, copy, readonly) YWShowNotificationBlock showNotificationBlock;
/**
 *  当IMUIKit需要显示通知时，会调用这个block。
 *  开发者需要实现并设置这个block，以便给用户提示。
 *  @param aViewController 当前的controller
 *  @param aTitle 标题
 *  @param aSubtitle 子标题
 *  @param aType 类型
 */
- (void)setShowNotificationBlock:(YWShowNotificationBlock)showNotificationBlock;





#pragma mark - 数据获取

/**
 *  获取所有未读消息数
 */
- (NSUInteger)getTotalUnreadCount;

/**
 *  获取某个联系人的未读消息数
 */
- (NSUInteger)getUnreadCountOfPerson:(YWPerson *)aPerson;

#pragma mark - 其他属性获取


/// 当前IM页面的根Controller
@property (nonatomic, strong, readonly) UINavigationController *rootNavigationController;

/**
 *  @brief 设置IMUIKit界面绘制所需资源包，默认使用自带资源包。
 *  @param customizedUIResources 自定义界面后所使用的资源包。
 *  @return 是否成功设置
 */
- (BOOL)setCustomizedUIResources:(NSBundle *)customizedUIResources;

@end


