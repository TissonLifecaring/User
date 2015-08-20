//
//  LeftMenuController.h
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RESideMenu/RESideMenu.h>
#import "UIStoryboard+Storyboards.h"
#import "UtilsMacro.h"
#import "AdviseViewController.h"
#import "MyServiceViewController.h"




@interface LeftMenuController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITableView *leftMenu;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) NSFetchedResultsController *mfetchController;
@property (nonatomic, strong) UserMessages *userMessages;

- (void)configureNewMessages:(NSDictionary *)userInfo;
- (void)getNewMessages;
- (void)getUserInfo;


@end
