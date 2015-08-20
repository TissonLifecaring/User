//
//  SPUtil.h
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <WXOpenIMSDKFMWK/YWFMWK.h>

typedef NS_ENUM(NSInteger, SPMessageNotificationType) {
    SPMessageNotificationTypeMessage = 0,
    SPMessageNotificationTypeWarning,
    SPMessageNotificationTypeError,
    SPMessageNotificationTypeSuccess
};


@interface SPUtil : NSObject


+ (instancetype)sharedInstance;


/**
 *  显示提示信息
 */
- (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(SPMessageNotificationType)type;



/**
 *  获取用户的profile
 */
- (void)getPersonDisplayName:(NSString **)aName avatar:(UIImage **)aAvatar ofPerson:(YWPerson *)aPerson;

- (void)getPersonDisplayInfoOfPerson:(YWPerson *)aPerson CompleteBlock:(void(^)(NSString *name, UIImage *image))completeBlock;


@end
