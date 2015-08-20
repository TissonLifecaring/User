//
//  UIViewController+DateAndTimePicker.m
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "UIViewController+DateAndTimePicker.h"
#import <MBProgressHUD.h>

@implementation UIViewController (DateAndTimePicker)

@dynamic datePicker;
@dynamic timePicker;
@dynamic dateBtn;
@dynamic timeBtn;


- (UIView *)viewOfHUD
{
    UIViewController *iter = self.parentViewController;
    
    while (iter) {
        if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            return iter.view;
        }
    }
    
    return self.view;
}

- (void)showDatePicker
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewOfHUD animated:YES];
    hud.customView = self.datePicker;
    hud.mode = MBProgressHUDModeCustomView;
}

- (void)showTimePicker
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewOfHUD animated:YES];
    hud.customView = self.timePicker;
    hud.mode = MBProgressHUDModeCustomView;
}

- (IBAction)datePick:(id)sender
{
    NSDate *selectDate = [self.datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *selectDateString = [dateFormatter stringFromDate:selectDate];
    [self.dateBtn setTitle:selectDateString forState:UIControlStateNormal];
    
    [MBProgressHUD hideHUDForView:self.viewOfHUD animated:YES];
}

- (IBAction)timePick:(id)sender
{
    NSDate *selectDate = [self.timePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *selectDateString = [dateFormatter stringFromDate:selectDate];
    [self.timeBtn setTitle:selectDateString forState:UIControlStateNormal];
    
    [MBProgressHUD hideHUDForView:self.viewOfHUD animated:YES];
}

@end
