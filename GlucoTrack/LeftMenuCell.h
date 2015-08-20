//
//  LeftMenuCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"

@interface LeftMenuCell : TDBadgedCell


@property (weak, nonatomic) IBOutlet UIImageView *LeftMenuIcon;
@property (weak, nonatomic) IBOutlet UILabel *LeftMenuLabel;

- (void)configureCellWithIconName:(NSString *)iconName LabelText:(NSString *)labelText;

@end
