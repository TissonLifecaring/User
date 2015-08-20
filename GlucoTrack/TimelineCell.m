//
//  TimelineCell.m
//  SugarNursing
//
//  Created by Dan on 14-11-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "TimelineCell.h"

@implementation TimelineCell

- (void)awakeFromNib
{
    self.containerView.opaque = YES;
    self.containerView.layer.cornerRadius = 4.0f;
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 1);
    self.containerView.layer.shadowRadius = 1;
    self.containerView.layer.shouldRasterize = YES;
    self.containerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
