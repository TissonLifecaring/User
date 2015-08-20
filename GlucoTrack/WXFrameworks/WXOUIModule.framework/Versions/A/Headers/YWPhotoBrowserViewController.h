//
//  WXOPhotoBrowserViewController.h
//  TAEDemo
//
//  Created by Jai Chen on 14/12/26.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IYWMessage;

@interface YWPhotoBrowserViewController : UIViewController

/**
 *  构建一个图片消息预览controller
 *  @param aMessage 需要预览的图片消息
 *  @return 如果消息体并非图片消息体，则返回nil
 */
+ (instancetype)makeControllerWithMessage:(id<IYWMessage>)aMessage;

/**
 *  异步保存大图到相册
 */
- (void)asyncSaveBigImageWithDownloadProgressBlock:(void(^)(CGFloat aProgress))aProgressBlock completionBlock:(void(^)(NSError *aError))aCompletionBlock;

@property (nonatomic, strong, readonly) id<IYWMessage> message;

@end
