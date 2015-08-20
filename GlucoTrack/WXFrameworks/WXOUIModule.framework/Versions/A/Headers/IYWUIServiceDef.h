//
//  IYWUIServiceDef.h
//  WXOpenIMUIKit
//
//  Created by huanglei on 15/4/10.
//  Copyright (c) 2015年 www.alibaba.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YWPerson;

@protocol IYWMessage;

/**
 * 消息类型
 */
/// 文本消息
FOUNDATION_EXTERN NSInteger const YWIMKitNewMessageTypeText;
/// 音频消息
FOUNDATION_EXTERN NSInteger const YWIMKitNewMessageTypeVoice;
/// 图片消息
FOUNDATION_EXTERN NSInteger const YWIMKitNewMessageTypeImage;
/// 其他类型
FOUNDATION_EXTERN NSInteger const YWIMKitNewMessageTypeOther;


/**
 *  UIService错误域
 */
FOUNDATION_EXTERN NSString *const YWUIServiceErrorDomain;

/**
 *  Error的UserInfo中使用这个Key来传递错误描述信息
 */
FOUNDATION_EXTERN NSString *const YWUIServiceErrorDescriptionKey;


#pragma mark - Fetch Profile

/**
 *  成功获取Profile后，通过这个回调，通知旺信
 *  @param aUserId userId
 *  @param aDisplayName 显示名称
 *  @param aAvatarImage 头像
 */
typedef void(^YWFetchProfileCompletionBlock)(BOOL aIsSuccess, YWPerson *aPerson, NSString *aDisplayName, UIImage *aAvatarImage);

/**
 *  当IM需要显示profile时，会调用这个block
 *  @param aUserId 用户Id
 *  @param aCompletionBlock 获取profile完成后，调用这个block通知IM
 */
typedef void(^YWFetchProfileBlock)(YWPerson *aPerson, YWFetchProfileCompletionBlock aCompletionBlock);


#pragma mark - Make Navigation Back Button

/**
 *  当IM需要显示导航栏按钮时，会调用这个block，你需要构建一个新的按钮，用于显示在导航栏的左上角
 */
typedef UIButton *(^YWMakeBackButtonBlock)();


#pragma mark - Open URL

/**
 *  打开某个url的回调block
 *  @param aURLString 某个url
 *  @param aParentController 用于打开的顶层控制器
 */
typedef void(^YWOpenURLBlock)(NSString *aURLString, UIViewController *aParentController);

#pragma mark - Preview Image

/**
 *  当IMUIKit需要预览图片消息时，会调用这个block
 */
typedef void(^YWUIPreviewImageMessageBlock)(id<IYWMessage> aMessage, UIViewController *aFromController);

#pragma mark - Open Profile
/**
 *  打开某个profile的回调block
 *  @param aUserId 某个userId
 *  @param aParentController 用于打开的顶层控制器
 */
typedef void(^YWOpenProfileBlock)(YWPerson *aPerson, UIViewController *aParentController);


#pragma mark - IM Events
/**
 *  未读数发生变化
 *  @param aCount 总的未读数
 */
typedef void(^YWUnreadCountChangedBlock)(NSInteger aCount);

/**
 *  新消息通知
 */
typedef void(^YWOnNewMessageBlock)(NSString *aSenderId, NSString *aContent, NSInteger aType, NSDate *aTime);

/**
 *  h5页面需要免登的回调block
 */
typedef void(^YWAutoLoginForH5Block)();


/**
 *  提示信息的类型定义
 */
typedef NS_ENUM(NSInteger, YWMessageNotificationType) {
    /// 普通消息
    YWMessageNotificationTypeMessage = 0,
    /// 警告
    YWMessageNotificationTypeWarning,
    /// 错误
    YWMessageNotificationTypeError,
    /// 成功
    YWMessageNotificationTypeSuccess
};

/**
 *  当IMUIKit需要显示通知时，会调用这个block。
 *  开发者需要实现并设置这个block，以便给用户提示。
 *  @param aViewController 当前的controller
 *  @param aTitle 标题
 *  @param aSubtitle 子标题
 *  @param aType 类型
 */
typedef void(^YWShowNotificationBlock)(UIViewController *aViewController, NSString *aTitle, NSString *aSubtitle, YWMessageNotificationType aType);




@interface IYWUIServiceDef : NSObject

@end
