//
//  LogSectionHeaderView.h
//  SugarNursing
//
//  Created by Dan on 14-12-2.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogSectionHeaderViewDelegate;

@interface LogSectionHeaderView : UITableViewHeaderFooterView

@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet id<LogSectionHeaderViewDelegate> delegate;
@property (nonatomic) NSInteger section;

@end

@protocol LogSectionHeaderViewDelegate <NSObject>

- (void)LogSectionHeaderView:(LogSectionHeaderView *)headerView sectionToggleAdd:(NSInteger)section;

@end
