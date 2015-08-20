//
//  ServiceCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "LinesLabel.h"
#import "ThumbnailImageView.h"

@interface ServiceCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet LinesLabel *serviceLabel;
@property (weak, nonatomic) IBOutlet LinesLabel *dateLabel;
@property (weak, nonatomic) IBOutlet ThumbnailImageView *thumbnailImageView;


@end
