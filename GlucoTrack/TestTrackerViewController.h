//
//  TestTrackerViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BEMSimpleLineGraphView.h>
#import <RMDateSelectionViewController.h>

@interface TestTrackerViewController : UIViewController<BEMSimpleLineGraphDataSource,BEMSimpleLineGraphDelegate,UITableViewDataSource,UITableViewDelegate,UITabBarDelegate>

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *trackerChart;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;


@end
