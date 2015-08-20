//
//  ControlPlanCell.h
//  SugarNursing
//
//  Created by Dan on 14-12-8.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"

@interface ControlPlanCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *controlPlanView;
@property (weak, nonatomic) IBOutlet LinesLabel *timeLabel;

@end
