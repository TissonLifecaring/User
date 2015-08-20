//
//  CustomLabel.m
//  SugarNursing
//
//  Created by Dan on 14-12-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppMacro.h"
#import "DeviceHelper.h"

@implementation CustomLabel

- (void)customSetup
{
    
    CGFloat fontSize = [DeviceHelper normalFontSize];
    self.font = [UIFont systemFontOfSize:fontSize];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self customSetup];
    return self;
}

- (void)awakeFromNib
{
    [self customSetup];
}

@end
