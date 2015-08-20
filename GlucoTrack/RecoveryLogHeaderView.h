//
//  RecoveryLogHeaderView.h
//  SugarNursing
//
//  Created by Dan on 14-12-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>


@interface RecoveryLogHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSDate *day;
@property (nonatomic, assign) BOOL currentDay;

@end
