//
//  RecurrenceViewController.m
//  GlucoTrack
//
//  Created by Dan on 15-3-5.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "RecurrenceViewController.h"

@interface RecurrenceViewController ()

@end

@implementation RecurrenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"RecurrenceRule", nil);
    self.tableView.rowHeight = 44;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureTableViewCell];

}

- (void)configureTableViewCell
{
    NSArray *cell = [self.tableView visibleCells];
    
    [cell enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell *cell = (UITableViewCell *)obj;
        UIImageView *clock = (UIImageView *)[cell viewWithTag:8];
        UILabel *day = (UILabel *)[cell viewWithTag:7];
        
        if ([self.rulesArray containsObject:day.text]) {
            clock.image = [UIImage imageNamed:@"clock"];
        }
        
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *clock = (UIImageView *)[cell viewWithTag:8];
    UILabel *day = (UILabel *)[cell viewWithTag:7];
    if (clock.image) {
        //Cancel
        clock.image = nil;
        [self.rulesArray removeObject:day.text];
        
    }else{
        //Selected
        clock.image = [UIImage imageNamed:@"clock"];
        [self.rulesArray addObject:day.text];
    }
    
    if (self.recurrenceRuleBlock) {
        self.recurrenceRuleBlock(self.rulesArray);
    }
    
}


@end
