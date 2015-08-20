//
//  UIButton+GCBlock.m
//  GlucoTrack
//
//  Created by Dan on 15-2-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "UIButton+GCBlock.h"
#import <objc/runtime.h>

@implementation UIButton (GCBlock)

#pragma mark - Custom accessors

- (void)addActionBlock:(GCButtonActionBlock)actionBlock forControlEvents:(UIControlEvents)events {
    
    // Store it.
    objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // Add self as target and -performActionBlock as action.
    [self addTarget:self action:@selector(performActionBlock:) forControlEvents:events];
}

- (GCButtonActionBlock)actionBlock {
    return objc_getAssociatedObject(self, @selector(actionBlock));
}

#pragma mark - IBActions

- (IBAction)performActionBlock:(id)sender {
    
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

@end
