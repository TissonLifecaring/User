//
//  RecurrenceViewController.h
//  GlucoTrack
//
//  Created by Dan on 15-3-5.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RecurrenceRuleBlock)(NSMutableArray *);

@interface RecurrenceViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *rulesArray;
@property (copy,nonatomic) RecurrenceRuleBlock recurrenceRuleBlock;

@end
