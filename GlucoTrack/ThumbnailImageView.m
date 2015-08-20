//
//  ThumbnailImageView.m
//  SugarNursing
//
//  Created by Dan on 14-12-7.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "ThumbnailImageView.h"

@implementation ThumbnailImageView

- (void)customSetUp
{
    self.layer.borderWidth = 3.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.clipsToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    [self customSetUp];
    return self;
}

- (void)awakeFromNib
{
    [self customSetUp];
}

@end
