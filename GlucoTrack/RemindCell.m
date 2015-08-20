//
//  WarningCell.m
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RemindCell.h"
@import QuartzCore;

@implementation RemindCell

- (void)awakeFromNib
{
    self.remindView.opaque = YES;
    self.remindView.layer.cornerRadius = 4.0f;
    self.remindView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.remindView.layer.shadowOpacity = 0.2;
    self.remindView.layer.shadowOffset = CGSizeMake(0, 1);
    self.remindView.layer.shadowRadius = 1;
    self.remindView.layer.shouldRasterize = YES;
    self.remindView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
