//
//  ShareHelper.h
//  GlucoTrack
//
//  Created by Ian on 15/5/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocial.h"


typedef NS_ENUM(NSInteger, SocialShareType)
{
    SocialShareTypeImage = 0,
    SocialShareTypeText
};

@interface ShareHelper : NSObject

+ (void)socailShareWithViewController:(UIViewController<UMSocialUIDelegate> *)viewController shareText:(NSString *)shareText shareType:(SocialShareType)type photographView:(UIView *)photographView shareToSnsNames:(NSArray *)snsNames;

@end
