//
//  NoDataView.m
//  GlucoTrack
//
//  Created by Dan on 15-1-30.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NoDataView.h"
#import <Masonry.h>


@implementation NoDataView

- (void)awakeFromNib
{
        self.noLabel = [UILabel new];
        self.noLabel.text = NSLocalizedString(@"No Data", nil);
        self.noLabel.font = [UIFont systemFontOfSize:17.0f];
        self.noLabel.textColor = [UIColor grayColor];
        [self addSubview:self.noLabel];
    
        [self.noLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.noLabel = [UILabel new];
        self.noLabel.text = NSLocalizedString(@"No Data", nil);
        self.noLabel.font = [UIFont systemFontOfSize:17.0f];
        self.noLabel.textColor = [UIColor grayColor];
        [self addSubview:self.noLabel];
        
        [self.noLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

@end
