//
//  UISwitch+GCBlock.m
//  GlucoTrack
//
//  Created by Dan on 15-3-6.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "UISwitch+GCBlock.h"
#import <objc/runtime.h>

@implementation UISwitch (GCBlock)

#pragma mark - Custom accessors

- (void)addActionBlock:(GCSwitchActionBlock)actionBlock forControlEvents:(UIControlEvents)events
{
    // Store it.
    objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // Add self as target and -performActionBlock as action.
    [self addTarget:self action:@selector(performActionBlock:) forControlEvents:events];
}

- (GCSwitchActionBlock)actionBlock
{
    return objc_getAssociatedObject(self, @selector(actionBlock));
}

#pragma mark - IBActions

- (IBAction)performActionBlock:(id)sender {
    
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

@end
