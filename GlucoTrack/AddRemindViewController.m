//
//  AddRemindViewController.m
//  GlucoTrack
//
//  Created by Ian on 15-2-27.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AddRemindViewController.h"
#import "ControlHeaderView.h"
#import <MBProgressHUD.h>
#import "BasicCell.h"
#import "MedicateCell.h"
#import "Medicine.h"
#import "LogSectionHeaderView.h"
#import "UtilsMacro.h"
#import "CalendarStack.h"
#import "RemindItem.h"
#import "LogTextField.h"
#import "RecurrenceViewController.h"

#define NUMBERS @"1234567890."

#define INSULIN_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"insulin.plist"]
#define DRUGS_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"drugs.plist"]


#define HEADER_HEIGHT 30


static NSString *ControlHeaderViewIdentifier = @"ControlHeaderViewIdentifier";

static NSString *BasicCellIdentifier = @"BasicCell";
static NSString *MediacteCellIdentifier = @"MedicateCell";

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";




@interface AddRemindViewController ()<UITextFieldDelegate,LogSectionHeaderViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
    BOOL _remindOpen;
}


@property (weak, nonatomic) IBOutlet UITableView *medicalTableView;

@property (strong, nonatomic) NSMutableArray *timeArray;

@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *medicalPicker;
@property (strong, nonatomic) IBOutlet UIView *medicalPickerView;



@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
//drug
@property (strong, nonatomic) NSMutableArray *insulinArray;
@property (strong, nonatomic) NSMutableArray *drugsArray;
@property (strong, nonatomic) NSMutableArray *othersArray;
@property (strong, nonatomic) NSMutableArray *medicationData;


@property (strong, nonatomic) NSMutableArray *drugData;
@property (strong, nonatomic) NSMutableArray *insulinData;



@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSMutableArray *days;

@end

@implementation AddRemindViewController

- (void)dealloc
{
    [hud removeFromSuperview];
    hud = nil;
}

- (void)dataSetup
{
    self.selectedIndexPath = nil;
    
    if (!self.insulinArray)
    {
        self.insulinArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (!self.drugsArray) {
        self.drugsArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (!self.othersArray) {
        self.othersArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (!self.days) {
        self.days = [[NSMutableArray alloc] initWithCapacity:7];
    }
    
    switch (self.remindType) {
        case RemindTypeAdd:
        {
            self.days = [@[NSLocalizedString(@"Sunday", nil),
                           NSLocalizedString(@"Monday", nil),
                           NSLocalizedString(@"Tuesday", nil),
                           NSLocalizedString(@"Wednesday", nil),
                           NSLocalizedString(@"Thursday", nil),
                           NSLocalizedString(@"Friday", nil),
                           NSLocalizedString(@"Saturday", nil)] mutableCopy];
            break;
        }
        case RemindTypeEdit:
        {
            NSArray *drugsArray = [self.reminder.notes componentsSeparatedByString:@"\n"];
            [drugsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                NSString *drugStr = (NSString *)obj;
                NSArray *drugStrArr = [drugStr componentsSeparatedByString:@" "];
                
                Medicine *medicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                medicine.sort = drugStrArr[0];
                medicine.usage = drugStrArr[2]; 
                medicine.drug = drugStrArr[1];
                medicine.dose = drugStrArr[3];
                medicine.unit = drugStrArr[4];
                
                if ([medicine.sort isEqualToString:@"胰岛素"]) {
                    [self.insulinArray addObject:medicine];
                }
                if ([medicine.sort isEqualToString:@"降糖药"]) {
                    [self.drugsArray addObject:medicine];
                }
                if ([medicine.sort isEqualToString:@"其他"]) {
                    [self.othersArray addObject:medicine];
                }
            }];
            
            EKRecurrenceRule *recurrenceRule = (EKRecurrenceRule *)self.reminder.recurrenceRules[0];
            
            [recurrenceRule.daysOfTheWeek enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                EKRecurrenceDayOfWeek *recurrence = (EKRecurrenceDayOfWeek *)obj;
                switch (recurrence.dayOfTheWeek-1) {
                    case 0:
                        [self.days addObject:NSLocalizedString(@"Sunday", nil)];
                        break;
                    case 1:
                        [self.days addObject:NSLocalizedString(@"Monday", nil)];
                        break;
                    case 2:
                        [self.days addObject:NSLocalizedString(@"Tuesday", nil)];
                        break;
                    case 3:
                        [self.days addObject:NSLocalizedString(@"Wednesday", nil)];
                        break;
                    case 4:
                        [self.days addObject:NSLocalizedString(@"Thursday", nil)];
                        break;
                    case 5:
                        [self.days addObject:NSLocalizedString(@"Friday", nil)];
                        break;
                    case 6:
                        [self.days addObject:NSLocalizedString(@"Saturday", nil)];
                        break;
                    default:
                        break;
                }
            }];
            
            break;
        }
    }
    
    [self loadDrugDataSource];
    
}

- (void)loadDrugDataSource
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:INSULIN_PATH])
    {
        NSString *insulinPath = [[NSBundle mainBundle] pathForResource:@"Insulin" ofType:@"plist"];
        self.insulinData= [[NSMutableArray alloc] initWithContentsOfFile:insulinPath];
        [self.insulinData writeToFile:INSULIN_PATH atomically:YES];
    }
    else self.insulinData = [NSMutableArray arrayWithContentsOfFile:INSULIN_PATH];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:DRUGS_PATH])
    {
        NSString *drugsPath = [[NSBundle mainBundle] pathForResource:@"Drugs" ofType:@"plist"];
        self.drugData = [[NSMutableArray alloc] initWithContentsOfFile:drugsPath];
        [self.drugData writeToFile:DRUGS_PATH atomically:YES];
    }
    else self.drugData = [NSMutableArray arrayWithContentsOfFile:DRUGS_PATH];
    
    NSArray *usageArr = @[NSLocalizedString(@"Oral_", nil),
                          NSLocalizedString(@"Insulin", nil),
                          NSLocalizedString(@"Injection", nil)
                          ];
    NSArray *unitArr = @[NSLocalizedString(@"mg", nil),
                         NSLocalizedString(@"g", nil),
                         NSLocalizedString(@"grain", nil),
                         NSLocalizedString(@"slice", nil),
                         NSLocalizedString(@"unit", nil),
                         NSLocalizedString(@"ml", nil),
                         NSLocalizedString(@"piece", nil),
                         NSLocalizedString(@"bottle", nil)
                         ];
    NSArray *medicateDataDefault = @[
                                     @{@"01":self.insulinData,
                                       @"02":self.drugData},
                                     usageArr,
                                     unitArr
                                     ];
    
    self.medicationData = [NSMutableArray arrayWithArray:medicateDataDefault];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Recurrence"]) {
        RecurrenceViewController *vc = [segue destinationViewController];
        vc.rulesArray = self.days;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        vc.recurrenceRuleBlock = ^(NSMutableArray *rules){
            
            self.days = rules;
            BasicCell *cell = (BasicCell *)[self.medicalTableView cellForRowAtIndexPath:indexPath];
            NSString *days = [self.days componentsJoinedByString:@" "];
            if (![days isEqualToString:@""]) {
                cell.detailText.text = days;
            }else cell.detailText.text = NSLocalizedString(@"Never", nil);
            
            [self configureRightBarButtonItem];
        };
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch (self.remindType) {
        case RemindTypeAdd:
            self.title = NSLocalizedString(@"Add Remind", nil);
            break;
            
        case RemindTypeEdit:
            self.title = NSLocalizedString(@"Eidt Remind", nil);
            break;
    }
    [self dataSetup];
    [self configureTableView];
}

- (void)configureRightBarButtonItem
{
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveRemind:)];
    }
}

#pragma mark - SaveRemind

- (IBAction)saveRemind:(id)sender
{
    [self.view endEditing:YES];
    
    NSMutableArray *drugsList = [NSMutableArray array];
    NSArray *allDrugs = @[self.insulinArray,self.drugsArray,self.othersArray];
    
    [allDrugs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *drugs = (NSMutableArray *)obj;
        [drugs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Medicine *medicine = (Medicine *)obj;
            if (![medicine.dose boolValue] || !medicine.drug || !medicine.unit || !medicine.usage || !medicine.sort) {
                return;
            }
            NSString *aMedicine = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",medicine.sort,medicine.drug,medicine.usage,medicine.dose,medicine.unit];
            [drugsList addObject:aMedicine];
        }];
    }];

    if ([drugsList count] == 0) {
        MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:aHud];
        aHud.delegate = self;
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"Medication cannot be empty", nil);
        [aHud show:YES];
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    
    switch (self.remindType) {
        case RemindTypeAdd:
        {
            RemindItem *remindItem = [[RemindItem alloc] init];
            remindItem.title = NSLocalizedString(@"Remember to take drugs!", nil);
            remindItem.notes = [self configureToDoItemNotes:drugsList];
            remindItem.startDateComponents = [self dateComponentsForStartDate];
            remindItem.dueDateComponents = [self dateComponentsForDueDate];
            remindItem.days = [self configureDays:self.days];
            
            if (![self configureTimeIsAvailable:remindItem.startDateComponents]) {
                hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:hud];
                hud.delegate = self;
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Not to Add reminder in the same time before", nil);
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                return;
            }
            
            [[CalendarStack shareCalendarStack] addReminderItem:remindItem forCalendarType:EKTypeDrug];
            
            break;
        }
        case RemindTypeEdit:
        {
            if (![self configureTimeIsAvailable:[self dateComponentsForStartDate]]) {
                hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:hud];
                hud.delegate = self;
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Not to Add reminder in the same time before", nil);
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                return;
            }
            
            self.reminder.notes = [self configureToDoItemNotes:drugsList];
            self.reminder.startDateComponents = [self dateComponentsForStartDate];
            self.reminder.dueDateComponents = [self dateComponentsForDueDate];
            ;
            [self.reminder.recurrenceRules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                EKRecurrenceRule *rule = (EKRecurrenceRule *)obj;
                [self.reminder removeRecurrenceRule:rule];
            }];
            EKRecurrenceRule *rule = [[CalendarStack shareCalendarStack] reminderRecurrenceRuleWithDays:[self configureDays:self.days]];
            [self.reminder addRecurrenceRule:rule];
            
            [[CalendarStack shareCalendarStack] saveReminder:self.reminder];
            break;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)configureTimeIsAvailable:(NSDateComponents *)itemDateComponents
{
    __block BOOL isAvailable = YES;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [self.reminders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EKReminder *reminder  = (EKReminder *)obj;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setHour:reminder.startDateComponents.hour];
        [comps setMinute:reminder.startDateComponents.minute];
        NSDate *date = [gregorian dateFromComponents:comps];
        
        NSDateComponents *newComps = [[NSDateComponents alloc] init];
        [newComps setHour:itemDateComponents.hour];
        [newComps setMinute:itemDateComponents.minute];
        
        NSDate *newDate = [gregorian dateFromComponents:newComps];
        
        if ([newDate compare:date] == NSOrderedSame) {
            isAvailable = NO;
            return ;
        }
        
    }];
    return isAvailable;
}

- (NSArray *)configureDays:(NSArray *)planDays
{
    NSMutableArray *rules = [@[@0,@0,@0,@0,@0,@0,@0] mutableCopy];
    [rules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        switch (idx) {
            case 0:
                if ([planDays containsObject:NSLocalizedString(@"Sunday", nil)]) {
                    [rules replaceObjectAtIndex:0 withObject:@1];
                }
                break;
            case 1:
                if ([planDays containsObject:NSLocalizedString(@"Monday", nil)]) {
                    [rules replaceObjectAtIndex:1 withObject:@1];
                }
                break;
            case 2:
                if ([planDays containsObject:NSLocalizedString(@"Tuesday", nil)]) {
                    [rules replaceObjectAtIndex:2 withObject:@1];
                }
                break;
            case 3:
                if ([planDays containsObject:NSLocalizedString(@"Wednesday", nil)]) {
                    [rules replaceObjectAtIndex:3 withObject:@1];
                }
                break;
            case 4:
                if ([planDays containsObject:NSLocalizedString(@"Thursday", nil)]) {
                    [rules replaceObjectAtIndex:4 withObject:@1];
                }
                break;
            case 5:
                if ([planDays containsObject:NSLocalizedString(@"Friday", nil)]) {
                    [rules replaceObjectAtIndex:5 withObject:@1];
                }
                break;
            case 6:
                if ([planDays containsObject:NSLocalizedString(@"Saturday", nil)]) {
                    [rules replaceObjectAtIndex:6 withObject:@1];
                }
                break;
            default:
                break;
        }
    }];
    return rules;
}

- (NSString *)configureToDoItemNotes:(NSMutableArray *)drugsList
{
    NSString *notes = [drugsList componentsJoinedByString:@"\n"];
    return notes;
    
}

#pragma mark - TodoItem dateComponents
                                 
- (NSDate *)completionDate
{
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *startDate = [dateFormatter dateFromString:dateTime];
    NSDate *completionDate = [startDate dateByAddingTimeInterval:10];
    return completionDate;
}

- (NSDateComponents *)dateComponentsForStartDate
{
    NSCalendar *aCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *startDate = [dateFormatter dateFromString:dateTime];
    

    NSUInteger unitFlags = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [aCalendar components:unitFlags fromDate:startDate];
    return dateComponents;

}

- (NSDateComponents *)dateComponentsForDueDate
{
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *startDate = [dateFormatter dateFromString:dateTime];
    NSDate *dueDate = [startDate dateByAddingTimeInterval:2];
    
    NSCalendar *aCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [aCalendar components:unitFlags fromDate:dueDate];
    return dateComponents;
}

- (void)configureTableView
{
    [self.medicalTableView registerNib:[UINib nibWithNibName:@"BasicCell" bundle:nil] forCellReuseIdentifier:BasicCellIdentifier];
    [self.medicalTableView registerNib:[UINib nibWithNibName:@"MedicateCell" bundle:nil] forCellReuseIdentifier:MediacteCellIdentifier];
    [self.medicalTableView registerNib:[UINib nibWithNibName:@"LogSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
}


#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
            
    switch (section)
    {
        case 0:
            rows = 2;
            break;
        case 1:
            rows = self.insulinArray.count+1;
            break;
        case 2:
            rows = self.drugsArray.count+1;
            break;
        case 3:
            rows = self.othersArray.count+1;
            break;
    }
    

    return rows;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    
    LogSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    [self configureTableview:tableView withSectionHeaderView:headerView inSection:section];
    return headerView;
}

- (void)configureTableview:(UITableView *)tableView withSectionHeaderView:(LogSectionHeaderView *)headerView inSection:(NSInteger)section
{
    headerView.tableView = tableView;
    headerView.delegate = self;
    headerView.section = section;
    if (section == 1)
    {
        headerView.titleLabel.text = NSLocalizedString(@"Glucose", nil);
    }
    if (section == 2)
    {
        headerView.titleLabel.text = NSLocalizedString(@"Hemoglobin", nil);
    }
    if (section == 3)
    {
        headerView.titleLabel.text = NSLocalizedString(@"Others", nil);
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 10;
    }
    else return HEADER_HEIGHT;

}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
            if (indexPath.section == 0)
            {
                BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
                [self configureTableView:tableView withBasicCell:cell atIndexPath:indexPath];
                return cell;
            }
            else
            {
                MedicateCell *cell = [tableView dequeueReusableCellWithIdentifier:MediacteCellIdentifier forIndexPath:indexPath];
                [self configureTableView:tableView withMedicateCell:cell atIndexPath:indexPath];
                return cell;
            }
    
    
}

- (void)configureTableView:(UITableView *)tableView withBasicCell:(BasicCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString;
    NSString *timeString;
    NSDate *theDate;
    cell.detailText.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    
    switch (self.remindType) {
        case RemindTypeAdd:
        {
            theDate = [NSDate date];
            break;
        }
            
        case RemindTypeEdit:
        {
            if (self.reminder) {
                NSCalendar *aCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                theDate = [aCalendar dateFromComponents:self.reminder.startDateComponents];
            }
            
            break;
        }
    }
    
    dateString = [NSString formattingDate:theDate to:@"yyyy-MM-dd"];
    timeString =  [NSString formattingDate:theDate to:@"HH:mm"];
    
    if (!self.date) {
        self.date = dateString;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.title.text = NSLocalizedString(@"Medication Time", nil);
            cell.detailText.placeholder = NSLocalizedString(@"Select Time",nil);
            if (self.time) {
                cell.detailText.text = self.time;
            }else{
                cell.detailText.text = timeString;
                self.time = timeString;
            }
            break;
        case 1:
        {
            cell.title.text = NSLocalizedString(@"RecurrenceRule", nil);
            NSString *days = [self.days componentsJoinedByString:@" "];
            if (days) {
                cell.detailText.text = days;
            }else cell.detailText.text = NSLocalizedString(@"Never", nil);
            cell.detailText.font = [UIFont systemFontOfSize:12];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
}


- (void)configureTableView:(UITableView *)tableView withMedicateCell:(MedicateCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row == 0)
    {
        cell.drugField.placeholder = NSLocalizedString(@"Medication Name", nil);
        cell.usageField.placeholder = NSLocalizedString(@"Usage", nil);
        cell.dosageField.placeholder = NSLocalizedString(@"Dosage", nil);
        cell.unitField.placeholder = NSLocalizedString(@"Unit", nil);
        
        cell.dosageField.userInteractionEnabled = YES;
        cell.dosageField.delegate = self;
        cell.dosageField.logIndexPath = indexPath;
        cell.dosageField.logFieldIdentify = @"dosage";
        
        Medicine *medicine;
        
        switch (indexPath.section)
        {
            case 1:
                medicine = self.insulinArray[indexPath.row-1];
                cell.drugField.userInteractionEnabled = NO;
                break;
            case 2:
                medicine = self.drugsArray[indexPath.row-1];
                cell.drugField.userInteractionEnabled = NO;
                break;
            case 3:
                medicine = self.othersArray[indexPath.row-1];
                cell.drugField.userInteractionEnabled = YES;
                cell.drugField.delegate = self;
                cell.drugField.logIndexPath = indexPath;
                cell.drugField.logFieldIdentify = @"drug";
                break;
        }
        
        if ([medicine isKindOfClass:[Medicine class]])
        {
            cell.drugField.text = medicine.drug;
            cell.usageField.text = medicine.usage;
            cell.dosageField.text = medicine.dose;
            cell.unitField.text = medicine.unit;
        }
        
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.drugField.text = NSLocalizedString(@"Medication Name", nil);
        cell.usageField.text = NSLocalizedString(@"Usage", nil);
        cell.dosageField.text = NSLocalizedString(@"Dosage", nil);
        cell.unitField.text = NSLocalizedString(@"Unit", nil);
    }
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 44;
    return heightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    switch (indexPath.section)
    {
            
        case 0:
            switch (indexPath.row)
            {
                case 0:
                    [self showDatePickerHUDWithMode:UIDatePickerModeTime];
                    break;
                case 1:
                {
                    [self performSegueWithIdentifier:@"Recurrence" sender:indexPath];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:
        case 2:
        case 3:
            if (indexPath.row == 0)
            {
                return;
            }
            
            [self showMedicalPickerViewHUD];
            [self.medicalPicker reloadAllComponents];
            break;
            
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[MedicateCell class]]) {
            switch (indexPath.section) {
                case 1:
                    [self.insulinArray removeObjectAtIndex:indexPath.row-1];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                case 2:
                    [self.drugsArray removeObjectAtIndex:indexPath.row-1];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                    break;
                case 3:
                    [self.othersArray removeObjectAtIndex:indexPath.row-1];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark - DatePickerHUD

- (void)showDatePickerHUDWithMode:(UIDatePickerMode )mode
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.margin = 0;
    hud.delegate = self;
    self.datePicker.datePickerMode = mode;
    hud.customView = self.datePickerView;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
}

- (IBAction)datePickerViewAction:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1000:
        {
            break;
        }
        case 1001:
        {
            
            NSString *dateString;
            if (self.datePicker.datePickerMode == UIDatePickerModeDate) {
                dateString = [NSString formattingDate:self.datePicker.date to:@"yyyy-MM-dd"];
                self.date = dateString;
                
            }else if (self.datePicker.datePickerMode == UIDatePickerModeTime){
                dateString = [NSString formattingDate:self.datePicker.date to:@"HH:mm"];
                self.time = dateString;
            }
            
            
            
            BasicCell *cell = (BasicCell *)[self.medicalTableView cellForRowAtIndexPath:self.selectedIndexPath];
            
            cell.detailText.text = dateString;
            
            [self configureRightBarButtonItem];
            
            break;
        }
    }
    
    [hud hide:YES afterDelay:0.25];
}


#pragma mark - Medical PickerViewHud


- (void)showMedicalPickerViewHUD
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.margin = 0;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = self.medicalPickerView;
    [hud show:YES];
}

- (IBAction)pickerViewAction:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case 1001:
        {
            
            if (self.selectedIndexPath.section == 3)
            {
                UILabel *usage = (UILabel *)[self.medicalPicker viewForRow:[self.medicalPicker selectedRowInComponent:0] forComponent:0];
                UILabel *unit = (UILabel *)[self.medicalPicker viewForRow:[self.medicalPicker selectedRowInComponent:1] forComponent:1];
                Medicine *medicine = self.othersArray[self.selectedIndexPath.row-1];
                medicine.sort = @"其他";
                medicine.unit = unit.text;
                medicine.usage = usage.text;
            }
            else
            {
                UILabel *drug = (UILabel*)[self.medicalPicker viewForRow:[self.medicalPicker selectedRowInComponent:0] forComponent:0];
                UILabel *usage = (UILabel *)[self.medicalPicker viewForRow:[self.medicalPicker selectedRowInComponent:1] forComponent:1];
                UILabel *unit = (UILabel *)[self.medicalPicker viewForRow:[self.medicalPicker selectedRowInComponent:2] forComponent:2];
                
                
                Medicine *medicine;
                if (self.selectedIndexPath.section == 1)
                {
                    medicine = self.insulinArray[self.selectedIndexPath.row-1];
                    medicine.sort = @"胰岛素";
                }
                if (self.selectedIndexPath.section == 2)
                {
                    medicine = self.drugsArray[self.selectedIndexPath.row-1];
                    medicine.sort = @"降糖药";
                }
                
                medicine.unit = unit.text;
                medicine.drug = drug.text;
                medicine.usage = usage.text;
                
                
                if ([medicine.drug isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Medication Name", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    
                    UITextField *tf = [alertView textFieldAtIndex:0];
                    tf.keyboardType = UIKeyboardTypeDefault;
                    
                    [alertView show];
                    [hud hide:YES];
                    return;
                }
            }
            
            [self.medicalTableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    
    [hud hide:YES afterDelay:0.25];
}



#pragma mark - UIPickerViewDelegate & DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
        NSInteger components = 0;
        
        
        switch (self.selectedIndexPath.section) {
            case 1:
            case 2:
                components = self.medicationData.count;
                break;
            case 3:
                components = 2;
                break;
        }
        
        
        return components;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
        NSInteger rows = 0;
        
        
        switch (self.selectedIndexPath.section)
        {
            case 1:
                if (component == 0)
                {
                    rows = [self.medicationData[component][@"01"] count];
                }
                else rows = [self.medicationData[component] count];
                
                break;
            case 2:
                if (component == 0)
                {
                    rows = [self.medicationData[component][@"02"] count];
                }
                else rows = [self.medicationData[component] count];
                break;
            case 3:
                rows = [self.medicationData[component+1] count];
                break;
        }
        
        return rows;
        
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:[DeviceHelper biggerFontSize]];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        
        view = titleLabel;
    
    
        switch (self.selectedIndexPath.section) {
            case 1:
                if (component == 0) {
                    titleLabel.text = self.medicationData[component][@"01"][row];
                    if ([titleLabel.text isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                        titleLabel.textColor = [UIColor orangeColor];
                    }
                }
                else titleLabel.text = self.medicationData[component][row];
                break;
            case 2:
                if (component == 0) {
                    titleLabel.text = self.medicationData[component][@"02"][row];
                    if ([titleLabel.text isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                        titleLabel.textColor = [UIColor orangeColor];
                    }
                }
                else titleLabel.text = self.medicationData[component][row];
                break;
            case 3:
                titleLabel.text = self.medicationData[component+1][row];
                break;
        }
        
        return titleLabel;
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat widthForComponent;
    if (component == 0)
    {
        widthForComponent = 140;
    }
    else widthForComponent = 70;
    
    return widthForComponent;
}


#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >0)
    {
        
        UITextField *tf = [alertView textFieldAtIndex:0];
        if ([tf.text isEqualToString:@""])
        {
            MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:aHud];
            aHud.delegate = self;
            aHud.mode = MBProgressHUDModeText;
            aHud.labelText = NSLocalizedString(@"Please enter medicine name", nil);
            [aHud show:YES];
            [aHud hide:YES afterDelay:HUD_TIME_DELAY];
            return;
        }
        
        switch (self.selectedIndexPath.section)
        {
            case 1:
            {
                Medicine *medicine = [self.insulinArray objectAtIndex:self.selectedIndexPath.row-1];
                medicine.drug = tf.text;
                
                [self.insulinData addObject:tf.text];
                [self.insulinData writeToFile:INSULIN_PATH atomically:YES];
                break;
            }
            case 2:
            {
                Medicine *medicine = [self.drugsArray objectAtIndex:self.selectedIndexPath.row-1];
                medicine.drug = tf.text;
                
                [self.drugData addObject:tf.text];
                [self.drugData writeToFile:DRUGS_PATH atomically:YES];
                break;
            }
            case 3:
            {
                break;
            }
            default:
                break;
        }
        
        [self.medicalTableView reloadRowsAtIndexPaths:@[self.selectedIndexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - LogSectionHeaderViewDelegate

- (void)LogSectionHeaderView:(LogSectionHeaderView *)headerView sectionToggleAdd:(NSInteger)section
{
    
    switch (headerView.section)
    {
        case 1:
        {
            NSInteger insertRow = self.insulinArray.count + 1;
            if ([self allowToAdd:insertRow]) {
                NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:headerView.section];
                
                Medicine *insertMedicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                insertMedicine.sort = @"胰岛素";
                
                [self.insulinArray addObject:insertMedicine];
                [self.medicalTableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            break;
        }
        case 2:
        {
            NSInteger insertRow = self.drugsArray.count + 1;
            
            if ([self allowToAdd:insertRow]) {
                NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:headerView.section];
                
                Medicine *insertMedicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                insertMedicine.sort = @"降糖药";
                
                [self.drugsArray addObject:insertMedicine];
                [self.medicalTableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            break;
        }
        case 3:
        {
            NSInteger insertRow = self.othersArray.count + 1;
            if ([self allowToAdd:insertRow]) {
                NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:headerView.section];
                
                Medicine *insertMedicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                insertMedicine.sort = @"其他";
                
                [self.othersArray addObject:insertMedicine];
                [self.medicalTableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            break;
        }
            
    }
    
    [self configureRightBarButtonItem];
}

- (BOOL)allowToAdd:(NSInteger)insertRow
{
    if (insertRow-1 > 10)
    {
        MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:aHud];
        aHud.delegate = self;
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"Not to Add More", nil);
        [aHud show:YES];
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL fieldInput = YES;
    LogTextField *logField = (LogTextField *)textField;
    
    if ([logField.logFieldIdentify isEqualToString:@"drug"]) {
        if ([self numberPredicateString:string]) {
            if ([string isEqualToString:@""]) {
                fieldInput = YES;
            }else fieldInput = NO;
            
        }else fieldInput = YES;
    }
    if ([logField.logFieldIdentify isEqualToString:@"dosage"]) {
        if ([self numberPredicateString:string]) {
            fieldInput = YES;
        }else fieldInput = NO;
    }
    
    return fieldInput;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    LogTextField *logField = (LogTextField *)textField;
    switch (logField.logIndexPath.section) {
        case 1:
        {
            Medicine *medicine = self.insulinArray[logField.logIndexPath.row-1];
            if ([logField.logFieldIdentify isEqualToString:@"dosage"]) {
                medicine.dose = logField.text ? logField.text : @"";
            }
            break;
        }
        case 2:
        {
            if ([logField.logFieldIdentify isEqualToString:@"dosage"]) {
                Medicine *medicine = self.drugsArray[logField.logIndexPath.row-1];
                medicine.dose = logField.text ? logField.text : @"";
            }
            
            break;
        }
        case 3:
        {
            Medicine *medicine = self.othersArray[logField.logIndexPath.row-1];
            if ([logField.logFieldIdentify isEqualToString:@"dosage"]) {
                medicine.dose = logField.text ? logField.text : @"";
            }
            if ([logField.logFieldIdentify isEqualToString:@"drug"]) {
                medicine.drug = logField.text ? logField.text : @"";
            }
            
            break;
        }
    }
}


- (BOOL)numberPredicateString:(NSString *)string
{
    
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filter = [[string componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
    if ([string isEqualToString:filter] ) {
        return YES;
    }else{
        return NO;
    }
}



@end
