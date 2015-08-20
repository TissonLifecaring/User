//
//  MedicationTableViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MedicationTableViewController.h"
#import <MBProgressHUD.h>
#import "UIViewController+DateAndTimePicker.h"

@interface MedicationTableViewController (){
    MBProgressHUD *hud;
}

@end

@implementation MedicationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
}

- (IBAction)btnTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if ([btn isEqual:self.dateBtn]) {
        [self showDatePicker];
    } else if ([btn isEqual:self.timeBtn]) {
        [self showTimePicker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
