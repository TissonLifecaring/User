//
//  DataView.h
//  GlucoTrack
//
//  Created by Dan on 15-3-11.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *titleLineView;

@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIButton *confirmBtn;

@end
