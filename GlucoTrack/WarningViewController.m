//
//  WarningViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "WarningViewController.h"
#import "WarningCell.h"

@interface WarningViewController ()

@end

@implementation WarningViewController

- (void)awakeFromNib
{
    self.dataArray = [NSMutableArray array];
    
    NSArray *data = @[
                      @[@"胰岛素",@"诺和平",@"每两天一次",@"一天三次",@"每次三克"],
                      @[@"胰岛素",@"诺和平",@"每三天两次",@"一天一次",@"每次三克"],
                      @[@"胰岛素",@"诺和平",@"每天一次",@"一天三次",@"每次三毫克"],
                      @[@"胰岛素",@"诺和平",@"每天四次",@"一天三次",@"每次三毫克"],];
    
    [self.dataArray addObjectsFromArray:data];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WarningCell *cell = [self.warningTableView dequeueReusableCellWithIdentifier:@"WarningCell" forIndexPath:indexPath];
    [self configureWarningCell:cell indexPath:indexPath];
    return cell;
}

- (void)configureWarningCell:(WarningCell *)cell indexPath:(NSIndexPath *)indexPath
{
    cell.medicationTypeLabel.text = self.dataArray[indexPath.row][0];
    cell.medicationLabel.text = self.dataArray[indexPath.row][1];
    cell.medicateCycleLabel.text = self.dataArray[indexPath.row][2];
    cell.medicateTimeLabel.text = self.dataArray[indexPath.row][3];
    cell.medicateUsageLabel.text = self.dataArray[indexPath.row][4];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)TabSwitch:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case 1:

            break;
            
        case 2:

        default:
            break;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
