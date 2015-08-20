//
//  AppDelegate+CustomAppearence.m
//  SugarNursing
//
//  Created by Dan on 14-12-9.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AppDelegate+CustomAppearence.h"
#import "CustomLabel.h"

@implementation AppDelegate (CustomAppearence)

- (void)customLabelAppearenceWithFontSize:(CGFloat)fontSize
{
    [[CustomLabel appearance] setFont:[UIFont systemFontOfSize:fontSize]];
}

@end
