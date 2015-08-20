//
//  FeelingCell.m
//  GlucoTrack
//
//  Created by Dan on 15-1-22.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "FeelingCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeelingCell


//- (instancetype)initWithCoder:(NSCoder *)coder {
//    self = [super initWithCoder:coder];
//    if (self) [self commonInit];
//    return self;
//}

- (void)initialSelectedBtn
{
    if (!self.selectedArray)
    {
        self.selectedArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    for (UIButton *button in self.containerView.subviews)
    {
        if ([self.selectedArray containsObject:button.currentTitle])
        {
            [self buttonSelected:button];
        }
        else [self buttonNormal:button];
        
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initialSelectedBtn];
}

- (IBAction)toggleBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        [self buttonNormal:btn];
    }else{
        [self buttonSelected:btn];
        
        if (btn.tag == 1)
        {
            for (UIView *button in self.containerView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]]) {
                    if (button.tag != 1) {
                        [self buttonNormal:(UIButton *)button];
                    }
                }
            }
        }else{
            for (UIButton *button in self.containerView.subviews) {
                if (button.tag == 1) {
                    if (button.selected) {
                        [self buttonNormal:button];
                    }
                }
            }
        }
    }
    
    if (self.selectedFeelingBlock) {
        self.selectedFeelingBlock(self.selectedArray);
    }
    
}

- (void)buttonNormal:(UIButton *)btn
{
    btn.selected = NO;
    btn.layer.cornerRadius = nearbyint(15.0);
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    
    if ([self.selectedArray containsObject:btn.currentTitle]) {
        [self.selectedArray removeObject:btn.currentTitle];
    }
}

- (void)buttonSelected:(UIButton *)btn
{
    btn.selected = YES;
    btn.layer.cornerRadius = nearbyint(15.0);
    btn.layer.borderWidth = 0;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    if (![self.selectedArray containsObject:btn.currentTitle]) {
        [self.selectedArray addObject:btn.currentTitle];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
