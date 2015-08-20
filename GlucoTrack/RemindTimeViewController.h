//
//  RemindTimeViewController.h
//  GlucoTrack
//
//  Created by Ian on 15-2-26.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RemindTimeChangedBlock)();

@interface RemindTimeViewController : UITableViewController

@property (copy, nonatomic) RemindTimeChangedBlock reminderTimeChangedBlock;

@end
