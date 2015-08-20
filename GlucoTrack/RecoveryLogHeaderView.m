//
//  RecoveryLogHeaderView.m
//  SugarNursing
//
//  Created by Dan on 14-12-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RecoveryLogHeaderView.h"

@interface RecoveryLogHeaderView ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *titleBackground;

@end

@implementation RecoveryLogHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleBackground = [UIView new];
        self.titleBackground.layer.cornerRadius = nearbyintf(15.0);
        [self addSubview:self.titleBackground];
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [UIColor clearColor];
        
        self.backgroundView = backgroundView;
        
        self.title = [UILabel new];
        self.title.font = [UIFont systemFontOfSize:14];
        self.title.backgroundColor = [UIColor clearColor];
        [self addSubview:self.title];
        
        [self.titleBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.title).with.insets(UIEdgeInsetsMake(-6.0, -12.0, -4.0, -12.0));
        }];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setDay:(NSDate *)day
{
    _day = day;
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"EEE MMM d" : @"yyyy-MM-dd EEEE");
    }
    self.title.text = [dateFormatter stringFromDate:day];
    [self setNeedsLayout];
}

- (void)setCurrentDay:(BOOL)currentDay
{
    _currentDay = currentDay;
    
    if (currentDay) {
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont boldSystemFontOfSize:16.0];
        self.titleBackground.backgroundColor = [UIColor colorWithRed:231/255.0 green:76/255.0 blue:60/255.0 alpha:1];
    } else {
        self.title.font = [UIFont systemFontOfSize:16.0];
        self.title.textColor = [UIColor blackColor];
        self.titleBackground.backgroundColor = [UIColor clearColor];
    }
}


@end