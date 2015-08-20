//
//  RemindTimeCell.h
//  GlucoTrack
//
//  Created by Ian on 15-2-26.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"

@interface RemindTimeCell : UITableViewCell


@property (strong, nonatomic) IBOutlet LinesLabel *remindTitleLabel;
@property (strong, nonatomic) IBOutlet LinesLabel *remindTimeLabel;


@end
