//
//  RESideMenu+Helper.m
//  Pods
//
//  Created by Dan on 14-11-13.
//
//

#import "RESideMenu+Helper.h"

@implementation RESideMenu (Helper)

- (void)disableExpensiveLayout
{
    for (UIView *subView in [self.contentViewController.view subviews]) {
        if ([subView isKindOfClass:[BEMSimpleLineGraphView class]]) {
            BEMSimpleLineGraphView *graphView = (BEMSimpleLineGraphView *)subView;
            graphView.avoidLayoutSubViews = YES;
        }
    }
}

- (void)enableExpensiveLayout
{
    for (UIView *subView in [self.contentViewController.view subviews]) {
        if ([subView isKindOfClass:[BEMSimpleLineGraphView class]]) {
            BEMSimpleLineGraphView *graphView = (BEMSimpleLineGraphView *)subView;
            graphView.avoidLayoutSubViews = NO;
        }
    }
}

@end
