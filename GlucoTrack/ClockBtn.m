//
//  ClockBtn.m
//  SugarNursing
//
//  Created by Dan on 14-12-8.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "ClockBtn.h"
#import <QuartzCore/QuartzCore.h>

@implementation ClockBtn

- (void)customSetUp
{
//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.layer.borderWidth = 0.3f;
    
    // Add Top border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    // Add Right border
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(self.frame.size.width-1, 0.0f, 1, self.frame.size.height+1);
    rightBorder.backgroundColor = [UIColor lightGrayColor].CGColor;

    [self.layer addSublayer:topBorder];
    [self.layer addSublayer:rightBorder];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self customSetUp];
    return self;
}

- (void)awakeFromNib
{
    [self customSetUp];
}

@end
