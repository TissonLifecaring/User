//
//  WXOWebViewController.h
//  WXOpenIMUIKit
//
//  Created by huanglei on 15/3/12.
//  Copyright (c) 2015年 www.alibaba.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWWebViewController : UIViewController

/**
 *  创建WebViewController
 *  @param aUrlString 需要打开的链接
 */
+ (instancetype)makeControllerWithUrlString:(NSString *)aUrlString;

@property (nonatomic, copy, readonly) NSString *urlString;

@end
