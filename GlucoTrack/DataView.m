//
//  DataView.m
//  GlucoTrack
//
//  Created by Dan on 15-3-11.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "DataView.h"
#import <Masonry.h>

@implementation DataView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.titleLabel.textColor = [UIColor grayColor];
        [self addSubview:self.titleLabel];
        
        self.titleLineView = [UIView new];
        [self addSubview:self.titleLineView];
        
        self.detailLabel = [UILabel new];
        self.detailLabel.font = [UIFont systemFontOfSize:14.0f];
        self.detailLabel.textColor = [UIColor grayColor];
        self.detailLabel.numberOfLines = 0;
        [self addSubview:self.detailLabel];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.font = [UIFont systemFontOfSize:12.0f];
        self.timeLabel.textColor = [UIColor grayColor];
        [self addSubview:self.timeLabel];
        
        self.confirmBtn = [UIButton new];
        [self.confirmBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
        [self addSubview:self.confirmBtn];
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(0);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.width.equalTo(@280);
        make.height.mas_equalTo(@44);
    }];
    
    [self.titleLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(0);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.width.equalTo(self);
        make.height.mas_equalTo(@1);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLineView.mas_bottom).with.offset(10);
        make.left.equalTo(self.mas_left).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(10);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailLabel.mas_bottom).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(10);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.bottom.equalTo(self.mas_bottom).with.offset(0);
        make.height.mas_equalTo(@44);
    }];
    
    
}



@end
