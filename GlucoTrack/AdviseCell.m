//
//  AdviseCell.m
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AdviseCell.h"
@import QuartzCore;

@implementation AdviseCell

- (void)awakeFromNib {
    // Initialization code
    self.adviseView.opaque = YES;
    self.adviseView.layer.cornerRadius = 4.0f;
    self.adviseView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.adviseView.layer.shadowOpacity = 0.2;
    self.adviseView.layer.shadowOffset = CGSizeMake(0, 1);
    self.adviseView.layer.shadowRadius = 1;
    self.adviseView.layer.shouldRasterize = YES;
    self.adviseView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
