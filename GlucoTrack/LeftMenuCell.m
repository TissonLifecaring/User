//
//  LeftMenuCell.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell

- (void)configureCellWithIconName:(NSString *)iconName LabelText:(NSString *)labelText
{
    self.LeftMenuIcon.image = [UIImage imageNamed:iconName];
    self.LeftMenuLabel.text = labelText;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
