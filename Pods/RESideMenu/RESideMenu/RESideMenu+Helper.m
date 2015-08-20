//
//  RESideMenu+Helper.m
//  Pods
//
//  Created by Dan on 14-11-13.
//
//

#import "RESideMenu+Helper.h"
#import "BEMSimpleLineGraphView.h"

@implementation RESideMenu (Helper)

- (void)disableExpensiveLayout
{
    
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)self.contentViewController;
        
        for (UIView *subView in [[(UIViewController *)[nav viewControllers][0] view] subviews]) {
            if ([subView isKindOfClass:[BEMSimpleLineGraphView class]]) {
                BEMSimpleLineGraphView *graphView = (BEMSimpleLineGraphView *)subView;
                graphView.avoidLayoutSubviews = YES;
            }
        }
    }
    
    
}

- (void)enableExpensiveLayout
{
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)self.contentViewController;
        
        for (UIView *subView in [[[nav viewControllers][0] view] subviews]) {
            if ([subView isKindOfClass:[BEMSimpleLineGraphView class]]) {
                BEMSimpleLineGraphView *graphView = (BEMSimpleLineGraphView *)subView;
                graphView.avoidLayoutSubviews = NO;
            }
        }
    }
    
    
}

@end
