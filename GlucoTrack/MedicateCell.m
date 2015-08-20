//
//  MedicateCell.m
//  SugarNursing
//
//  Created by Dan on 14-12-2.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MedicateCell.h"

@implementation MedicateCell

- (void)awakeFromNib {
    // Initialization code
    self.drugField.adjustsFontSizeToFitWidth = YES;
    self.drugField.minimumFontSize = 12.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
