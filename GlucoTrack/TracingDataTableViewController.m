//
//  TracingDataTableViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "TracingDataTableViewController.h"
#import <MBProgressHUD.h>
#import "UIViewController+DateAndTimePicker.h"

@interface TracingDataTableViewController (){
    MBProgressHUD *hud;
}

@end

@implementation TracingDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
}

- (IBAction)btnTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if ([btn isEqual:self.tracingType]) {
        hud = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
        [self.parentViewController.view addSubview:hud];
        
        hud.margin = 10;
        hud.customView = self.tracingTypeView;
        hud.mode = MBProgressHUDModeCustomView;
        [hud show:YES];
    } else if ([btn isEqual:self.dateBtn]) {
        [self showDatePicker];
        
    } else if ([btn isEqual:self.timeBtn]) {
        [self showTimePicker];
    }
}

- (IBAction)tracingTypeChoose:(id)sender
{
    [hud hide:YES afterDelay:0.2];
    [self.tracingType setTitle:[(UIButton *)sender currentTitle] forState:UIControlStateNormal];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
