//
//  WarningCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarningCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *medicationTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *medicationLabel;
@property (weak, nonatomic) IBOutlet UILabel *medicateCycleLabel;
@property (weak, nonatomic) IBOutlet UILabel *medicateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *medicateUsageLabel;


@end
