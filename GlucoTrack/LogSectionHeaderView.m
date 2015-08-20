//
//  LogSectionHeaderView.m
//  SugarNursing
//
//  Created by Dan on 14-12-2.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "LogSectionHeaderView.h"

@implementation LogSectionHeaderView

- (void)awakeFromNib
{
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithRed:26/255.0 green:188/255.0 blue:156/255.0 alpha:1];
    self.backgroundView = bgView;
}


- (IBAction)toggleAdd:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(LogSectionHeaderView:sectionToggleAdd:)]) {
        [self.delegate LogSectionHeaderView:self sectionToggleAdd:self.section];
    }
}

@end