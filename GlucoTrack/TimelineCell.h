//
//  TimelineCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"

@interface TimelineCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *timelineImageView;

@property (weak, nonatomic) IBOutlet LinesLabel *titleLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *timeLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *detailLabel;

@end
