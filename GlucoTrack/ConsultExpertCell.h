//
//  ConsultExpertCell.h
//  GlucoTrack
//
//  Created by Ian on 15/7/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailImageView.h"

@interface ConsultExpertCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ThumbnailImageView *expertImageView;

@property (weak, nonatomic) IBOutlet UILabel *expertNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *expertDetailLabel;

@end
