//
//  TDBadgedCell+Customizing.m
//  GlucoTrack
//
//  Created by Dan on 15-3-10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "TDBadgedCell+Customizing.h"

@implementation TDBadgedCell (Customizing)

- (void)customizeBadgedCell
{
    self.badgeColor = [UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1];
    self.badge.fontSize = 14.0f;
    self.badgeTextColor = [UIColor whiteColor];
    self.badgeTextColorHighlighted = [UIColor whiteColor];
    self.badge.radius = 20/2;
}

@end
