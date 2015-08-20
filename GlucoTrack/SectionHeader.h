//
//  SectionHeader.h
//  SugarNursing
//
//  Created by Dan on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionHeader : UITableViewCell

@property (nonatomic) NSInteger section;

@property (weak, nonatomic) IBOutlet UIButton *headerBtn;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@end
