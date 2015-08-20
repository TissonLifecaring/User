//
//  UISwitch+GCBlock.h
//  GlucoTrack
//
//  Created by Dan on 15-3-6.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GCSwitchActionBlock)(UISwitch *sender);

@interface UISwitch (GCBlock)

- (void)addActionBlock:(GCSwitchActionBlock)actionBlock forControlEvents:(UIControlEvents)events;

- (GCSwitchActionBlock)actionBlock;

@end
