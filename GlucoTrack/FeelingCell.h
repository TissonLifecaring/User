//
//  FeelingCell.h
//  GlucoTrack
//
//  Created by Dan on 15-1-22.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

typedef void (^SelectedFeelingBlock) (NSMutableArray *);


@interface FeelingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CustomLabel *title;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (copy) SelectedFeelingBlock selectedFeelingBlock;

- (void)initialSelectedBtn;

@end

