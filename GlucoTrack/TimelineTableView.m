//
//  TimelineTableView.m
//  SugarNursing
//
//  Created by Dan on 14-11-19.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "TimelineTableView.h"

@implementation TimelineTableView


- (void)drawRect:(CGRect)rect
{
    UIColor *color = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:0.8];
    [color set];

    UIBezierPath *linePath = [UIBezierPath bezierPath];
    linePath.lineCapStyle = kCGLineCapRound;
    linePath.lineWidth = 1;

    CGPoint initailPoint = CGPointMake(29, 0);
    CGPoint finalPoint = CGPointMake(29, self.bounds.size.height);

    [linePath moveToPoint:initailPoint];
    [linePath addLineToPoint:finalPoint];

    [linePath closePath];
    [linePath stroke];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
