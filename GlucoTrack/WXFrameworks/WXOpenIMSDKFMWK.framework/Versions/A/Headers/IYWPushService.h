//
//  IYWPushService.h
//  
//
//  Created by huanglei on 14/12/16.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IYWMessage;

/// Push服务错误域
FOUNDATION_EXTERN NSString *const YWPushServiceDomain;

/**
 Push服务
 */

@protocol IYWPushService <NSObject>

/**
 *  登记DeviceToken. ISV需要在获得DeviceToken后设入DeviceToken。
 */
@property (nonatomic, copy, readwrite) NSData *deviceToken;
/**
 *  获取转换后的deviceToken字符串
 */
@property (nonatomic, readonly) NSString *deviceTokenString;



#pragma mark - V1

/**
 *  Push处理回调
 *  @param aAPS APS消息本身
 *  @param aConversationId 会话Id
 */
typedef void(^YWPushHandleResultBlock)(NSDictionary *aAPS, NSString *aConversationId);

/**
 *  处理启动参数
 *  @param aLaunchOptions 启动参数
 *  @param aCompletionBlock 如果OpenIM接受处理该启动参数，在处理完毕后通过此回调返回结果
 *  @return OpenIM是否接受处理该启动参数
 */
- (BOOL)handleLaunchOptions:(NSDictionary *)aLaunchOptions completionBlock:(YWPushHandleResultBlock)aCompletionBlock;

/**
 *  处理Push消息
 *  @param aPushUserInfo
 *  @param aCompletionBlock
 *  @return OpenIM是否接受处理该Push
 */
- (BOOL)handlePushUserInfo:(NSDictionary *)aPushUserInfo completionBlock:(YWPushHandleResultBlock)aCompletionBlock;


#pragma mark - V2

/**
 *  Push处理回调
 *  @param aAPS APS消息本身
 *  @param aConversationId 会话Id
 *  @param aConversationClass 会话类型，返回值可能是：[YWP2PConversation class]、[YWTribeConversation class]
 */
typedef void(^YWPushHandleResultBlockV2)(NSDictionary *aAPS, NSString *aConversationId, Class aConversationClass);

/**
 *  处理启动参数
 *  @param aLaunchOptions 启动参数
 *  @param aCompletionBlock 如果OpenIM接受处理该启动参数，在处理完毕后通过此回调返回结果
 *  @return OpenIM是否接受处理该启动参数
 */
- (BOOL)handleLaunchOptionsV2:(NSDictionary *)aLaunchOptions completionBlock:(YWPushHandleResultBlockV2)aCompletionBlock;

/**
 *  处理Push消息
 *  @param aPushUserInfo
 *  @param aCompletionBlock
 *  @return OpenIM是否接受处理该Push
 */
- (BOOL)handlePushUserInfoV2:(NSDictionary *)aPushUserInfo completionBlock:(YWPushHandleResultBlockV2)aCompletionBlock;



@end
