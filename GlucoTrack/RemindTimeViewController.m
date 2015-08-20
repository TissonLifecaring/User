//
//  RemindTimeViewController.m
//  GlucoTrack
//
//  Created by Ian on 15-2-26.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "RemindTimeViewController.h"
#import "RemindTimeCell.h"
#import <MBProgressHUD.h>
#import "LinesLabel.h"
#import "DeviceHelper.h"

@interface RemindTimeViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) NSIndexPath *selectIndexPath;

@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *timeArray;

@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation RemindTimeViewController


- (void)awakeFromNib
{
    self.timeArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemindTimeLine"] mutableCopy];
    
    self.titleArray = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RemindTimeName" ofType:@"plist"]] mutableCopy];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)configureRightBarButton
{
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    }
}

- (IBAction)save:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:self.timeArray forKey:@"RemindTimeLine"];
    if (self.reminderTimeChangedBlock) {
        self.reminderTimeChangedBlock();
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RemindTimeCell *cell = (RemindTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"RemindTimeCell"
                                                            forIndexPath:indexPath];
    
    cell.remindTitleLabel.text = self.titleArray[indexPath.row];
    cell.remindTimeLabel.text = self.timeArray[indexPath.row];
    
    cell.remindTitleLabel.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    cell.remindTimeLabel.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showDatePickerHud];
}


#pragma mark - DatePicker Hud
- (void)showDatePickerHud
{
    
    [self setDatePickerDateWithSelectRow:self.selectIndexPath.row];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    HUD.delegate = self;
    HUD.margin = 0;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = self.datePickerView;
    [HUD show:YES];
}

- (IBAction)datePickerViewAction:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case 1000:
        {
            break;
        }
        case 1001:
        {
            if([self judgeTimeRational])
            {
                [self configureRightBarButton];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                
                NSString *time = [formatter stringFromDate:self.datePicker.date];
                if ([[time substringToIndex:1] isEqualToString:@"0"])
                {
                    time = [time substringFromIndex:1];
                }
                
                [self.timeArray setObject:time atIndexedSubscript:self.selectIndexPath.row];
                [self.tableView reloadData];
                
            }
            break;
        }
    }
    [HUD hide:YES afterDelay:0.25];

    
}


- (BOOL)judgeTimeRational
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSString *selectTimeString = [formatter stringFromDate:self.datePicker.date];
    NSDate *selectTime = [formatter dateFromString:selectTimeString];
    
    if (self.selectIndexPath.row > 0)
    {
        
        NSString *lastTimeString = self.timeArray[self.selectIndexPath.row-1];
        NSDate *lastTime = [formatter dateFromString:lastTimeString];
        
        NSComparisonResult result = [selectTime compare:lastTime];
        
        if (result <= 0)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"cannot be earlier than last time", nil) delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    
    
    if (self.selectIndexPath.row < self.timeArray.count-1)
    {
        NSString *nextTimeString = self.timeArray[self.selectIndexPath.row+1];
        NSDate *nextTime = [formatter dateFromString:nextTimeString];
        
        NSComparisonResult result = [selectTime compare:nextTime];
        
        if (result >= 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"cannot be later than next time", nil]) delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    
    return YES;
}


- (void)setDatePickerDateWithSelectRow:(NSInteger)row
{
    
    NSString *dateString = self.timeArray[row];
    
    if (dateString && dateString.length>0)
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSDate *date = [dateFormatter dateFromString:dateString];
        
        [self.datePicker setDate:date animated:NO];
    }
}

@end
