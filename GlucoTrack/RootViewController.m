//
//  RootViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RootViewController.h"
#import "UIStoryboard+Storyboards.h"
#import "TestTrackerViewController.h"
#import "LeftMenuController.h"
#import "UtilsMacro.h"
#import "DeviceHelper.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 4;
    self.contentViewShadowEnabled = YES;
    self.panFromEdge = YES;
    
    self.contentViewController = [[UIStoryboard testTracker] instantiateInitialViewController];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenu"];
//    self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightMenu"];
    self.delegate = self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RESideMenuDelegate

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    LeftMenuController *leftMenu = (LeftMenuController *)menuViewController;
    UserMessages *userMessages;
    if ([leftMenu.mfetchController.fetchedObjects count] == 0) {
        userMessages = nil;
    }else{
        userMessages = leftMenu.mfetchController.fetchedObjects[0];
    }
    
    if ([[(UINavigationController*)sideMenu.contentViewController viewControllers][0] isKindOfClass:[MyServiceViewController class]]) {
        if (![userMessages.agentMsg isEqualToString:@"0"]) {
            userMessages.agentMsg = @"0";
            [[CoreDataStack sharedCoreDataStack] saveContext];
            
        }
    }
    
    if ([[(UINavigationController *)sideMenu.contentViewController viewControllers][0] isKindOfClass:[AdviseViewController class]]) {
        if (![userMessages.suggest isEqualToString:@"0"]) {
            userMessages.suggest = @"0";
            [[CoreDataStack sharedCoreDataStack] saveContext];
            
        }
    }
    
}

@end
