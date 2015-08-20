//
//  ControlHeaderView.h
//  SugarNursing
//
//  Created by Dan on 14-12-8.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+GCBlock.h"
#import "UISwitch+GCBlock.h"




@interface ControlHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *controlPlanButton;
@property (weak, nonatomic) IBOutlet UISwitch *controlPlanSwitch;

@end
