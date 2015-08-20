//
//  WarningCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"
#import "UISwitch+GCBlock.h"

@interface RemindCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIView *remindView;
@property (weak, nonatomic) IBOutlet UILabel *remindTime;
@property (weak, nonatomic) IBOutlet UILabel *remindRules;
@property (weak, nonatomic) IBOutlet LinesLabel *remindLabel;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;


@end
