//
//  DetectDataCell.h
//  GlucoTrack
//
//  Created by Dan on 15-1-26.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface DetectDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CustomLabel *detectDate;
@property (weak, nonatomic) IBOutlet CustomLabel *detectTime;
@property (weak, nonatomic) IBOutlet CustomLabel *detectValue;

@end
