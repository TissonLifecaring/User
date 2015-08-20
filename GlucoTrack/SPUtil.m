//
//  SPUtil.m
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "SPUtil.h"
#import <MBProgressHUD.h>
#import "UtilsMacro.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "MyDoctor.h"
#import <UIImageView+AFNetworking.h>

@implementation SPUtil

+ (instancetype)sharedInstance
{
    static SPUtil *sUtil = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sUtil = [[SPUtil alloc] init];
    });
    
    return sUtil;
}

- (void)showNotificationInViewController:(UIViewController *)viewController title:(NSString *)title  subtitle:(NSString *)subtitle type:(SPMessageNotificationType)type
{
    /// 我们在Demo中使用了第三方库TSMessage来显示提示信息
    /// 强烈建议您使用自己的提示信息显示方法，以便保持App内风格一致
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.detailsLabelText = subtitle;
    [hud show:YES];
    [hud hide:YES afterDelay:1.2];
}


- (void)getPersonDisplayName:(NSString *__autoreleasing *)aName avatar:(UIImage *__autoreleasing *)aAvatar ofPerson:(YWPerson *)aPerson
{
    //自己
    if ([aPerson.personId isEqualToString:[NSString linkmanID]])
    {
        
        NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (objects.count>0)
        {
            UserInfomation *info = objects[0];
            
            if (aName) {
                *aName = info.nickName;
            }
            
            if (aAvatar) {
                NSURL *url = [NSURL URLWithString:info.headImageUrl];
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                                                                      options:SDWebImageDownloaderHighPriority
                                                                     progress:nil
                                                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                        
                                                                        *aAvatar = image;
                                                                    }];
            }
        }
    }
    else
    {
        NSArray *objects = [MyDoctor findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        if (objects.count>0)
        {
            MyDoctor *doctor = objects[0];
            
            if (aName)
            {
                *aName = doctor.exptName;
            }
            
            if (aAvatar)
            {
                NSURL *url = [NSURL URLWithString:doctor.headimageUrl];
                //                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                //                                                                      options:SDWebImageDownloaderHighPriority
                //                                                                     progress:nil
                //                                                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                //
                //                                                                        *aAvatar = image;
                //                                                                    }];
                
                UIImageView *imageView = [UIImageView new];
                [imageView sd_setImageWithURL:[NSURL URLWithString:doctor.headimageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
            }
        }
    }
}


- (void)getPersonDisplayInfoOfPerson:(YWPerson *)aPerson CompleteBlock:(void(^)(NSString *name, UIImage *image))completeBlock
{
    
    NSString *aName = nil;
    NSString *personId = aPerson.personId;
    //自己
    
    NSString *openIMAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"openIMAccount"];
    if ([personId isEqualToString:openIMAccount])
    {
        
        NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (objects.count>0)
        {
            UserInfomation *info = objects[0];
            aName = info.nickName;
            
            
            NSString *imageUrl = info.headImageUrl;
            if (!imageUrl || imageUrl.length<=0)
            {
                completeBlock(aName, nil);
                return;
            }
            
            
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:info.headImageUrl]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    completeBlock(aName, image);
                                }];
        }
        
    }
    else
    {
        NSArray *objects = [MyDoctor findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        if (objects.count>0)
        {
            MyDoctor *doctor = objects[0];
            
            aName = doctor.exptName;
            
            
            NSString *imageUrl = doctor.headimageUrl;
            if (!imageUrl || imageUrl.length<=0)
            {
                completeBlock(aName, nil);
                return;
            }
            
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:doctor.headimageUrl]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    completeBlock(aName, image);
                                }];
        }
    }

}



    @end
