//
//  EvaluateCell.m
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "EvaluateCell.h"

@implementation EvaluateCell

- (void)awakeFromNib {
    // Initialization code
    self.scoreLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.evaluateTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.evaluateTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //Make sure the ContentView does a layout pass here so that its subViews have their fame set ,whick we need to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsDisplay];
    [self.contentView layoutIfNeeded];
    
    self.scoreLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.scoreLabel.frame);
    self.evaluateTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.evaluateTextLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
