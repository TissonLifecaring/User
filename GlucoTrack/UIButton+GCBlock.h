//
//  UIButton+GCBlock.h
//  GlucoTrack
//
//  Created by Dan on 15-2-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GCButtonActionBlock)(UIButton *sender);

@interface UIButton (GCBlock)

- (void)addActionBlock:(GCButtonActionBlock)actionBlock forControlEvents:(UIControlEvents)events;

- (GCButtonActionBlock)actionBlock;

@end
