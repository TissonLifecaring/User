//
//  UIViewController+RootViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "UIViewController+RootViewController.h"
#import "UIStoryboard+MyApp.h"


@implementation UIViewController(RootViewController)

+ (RootViewController *)rootViewController
{
    RootViewController *rootViewController =(RootViewController *)[[UIStoryboard mainStoryboard] instantiateInitialViewController];
    return rootViewController;
}

@end
