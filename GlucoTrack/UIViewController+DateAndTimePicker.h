//
//  UIViewController+DateAndTimePicker.h
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DateAndTimePicker)

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (strong, nonatomic) IBOutlet UIButton *dateBtn;
@property (strong, nonatomic) IBOutlet UIButton *timeBtn;

@property (strong, readonly, nonatomic) UIView *viewOfHUD;

- (void)showDatePicker;
- (void)showTimePicker;

- (IBAction)datePick:(id)sender;
- (IBAction)timePick:(id)sender;

@end
