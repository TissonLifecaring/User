//
//  AdviseCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "LinesLabel.h"

@interface AdviseCell :SWTableViewCell

@property (weak, nonatomic) IBOutlet UIView *adviseView;
@property (weak, nonatomic) IBOutlet LinesLabel *adviseLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *dateLabel;

@end
