//
//  MemberInfoCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailImageView.h"
#import "TDBadgedCell.h"

@interface MemberInfoCell : TDBadgedCell

@property (weak, nonatomic) IBOutlet ThumbnailImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *sexAndAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;



@end
