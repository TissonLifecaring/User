//
//  WarningViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"
#import "ControlHeaderView.h"
#import "ControlPlanCell.h"

@interface RemindViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
SwipeViewDataSource,
SwipeViewDelegate,
UITabBarDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UIPickerView *planPickerView;
@property (strong, nonatomic) IBOutlet UIView *pickerView;

@end
