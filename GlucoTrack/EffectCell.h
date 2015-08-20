//
//  EffectCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EffectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *evaluateType;

@property (weak, nonatomic) IBOutlet UILabel *testCount;
@property (weak, nonatomic) IBOutlet UILabel *overproofCount;
@property (weak, nonatomic) IBOutlet UILabel *maximumValue;
@property (weak, nonatomic) IBOutlet UILabel *minimumValue;
@property (weak, nonatomic) IBOutlet UILabel *averageValue;

@end
