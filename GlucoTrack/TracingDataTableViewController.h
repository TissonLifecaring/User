//
//  TracingDataTableViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracingDataTableViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UIButton *tracingType;
@property (weak, nonatomic) IBOutlet UIButton *deviceType;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;

@property (strong, nonatomic) IBOutlet UIView *tracingTypeView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;

@end
