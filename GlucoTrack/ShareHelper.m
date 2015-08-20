//
//  ShareHelper.m
//  GlucoTrack
//
//  Created by Ian on 15/5/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ShareHelper.h"
#import <UIKit/UIKit.h>
#import "UMSocial.h"
#import "VendorMacro.h"


static NSString *shareString;


@implementation ShareHelper

#pragma mark - Social Share
+ (void)socailShareWithViewController:(UIViewController<UMSocialUIDelegate> *)viewController shareText:(NSString *)shareText shareType:(SocialShareType)type photographView:(UIView *)photographView shareToSnsNames:(NSArray *)snsNames
{
    UIImage *shareImage;
    
    if (type == SocialShareTypeImage)
    {
        CGRect rect = viewController.view.bounds;
        rect.origin.y += [self statusBarHeight] + 10;
        UIImage *currentScreen = [self getScreenImage:photographView];
        shareImage = [self cutImage:currentScreen rect:rect];
    }
    
    
    [UMSocialSnsService presentSnsIconSheetView:viewController
                                         appKey:nil
                                      shareText:@""
                                     shareImage:type == SocialShareTypeImage ? shareImage : nil
                                shareToSnsNames:snsNames
                                       delegate:viewController];
}



+ (UIImage *)cutImage:(UIImage *)image rect:(CGRect)rect
{
    rect.size.height += rect.size.height;
    rect.size.width  += rect.size.width;
    
    //要裁剪的图片区域，按照原图的像素大小，超过原图大小的边自动适配
    CGImageRef cgimg = CGImageCreateWithImageInRect([image CGImage], rect);
    return [UIImage imageWithCGImage:cgimg];
}


+ (UIImage *)getScreenImage:(UIView *)view
{
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (CGFloat)statusBarHeight
{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}



@end
