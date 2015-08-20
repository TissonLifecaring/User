//
//  WarningViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RemindViewController.h"
#import "RemindCell.h"
#import "ControlHeaderView.h"
#import <MBProgressHUD.h>
#import "BasicCell.h"
#import "MedicateCell.h"
#import "Medicine.h"
#import "LogSectionHeaderView.h"
#import "UtilsMacro.h"
#import "UIButton+GCBlock.h"
#import "CalendarStack.h"
#import "AddRemindViewController.h"
#import "RemindItem.h"
#import "RemindTimeViewController.h"
#import "ShareHelper.h"

#define NUMBERS @"1234567890."


#define HEADER_HEIGHT 30

typedef NS_ENUM(NSInteger, GCPickerType)
{
    GCPickerTypePlanMode = 1,
    GCPickerTypeMedical = 2
};



static NSString *ControlHeaderViewIdentifier = @"ControlHeaderViewIdentifier";

static NSString *BasicCellIdentifier = @"BasicCell";
static NSString *MediacteCellIdentifier = @"MedicateCell";

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";



@interface RemindViewController ()<UITextFieldDelegate,MBProgressHUDDelegate,UMSocialUIDelegate>
{
    MBProgressHUD *hud;
    NSInteger _currentPlan;
    BOOL _remindChange;
}

@property (strong, nonatomic) UITableView *detectionTableView;
@property (strong, nonatomic) GCTableView *drugRemindTableView;

@property (strong, nonatomic) UIButton *controlPlanButton;
@property (strong, nonatomic) UISwitch *controlPlanSwitch;

@property (strong, nonatomic) NSMutableArray *drugReminders;

@property (strong, nonatomic) NSMutableArray *timeArray;
@property (strong, nonatomic) NSMutableArray *planModeArray;
@property (strong, nonatomic) NSMutableArray *planDataArray;
@property (strong, nonatomic) NSMutableArray *planArray;


@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *time;

@property (strong, nonatomic) UIImage *clock;

@property (nonatomic) BOOL reloadTableView;

@end

@implementation RemindViewController

- (void)setUpDetectionReminderData
{
    if (!self.planModeArray) {
        self.planModeArray = [NSMutableArray array];
        NSArray *planMode = @[NSLocalizedString(@"17 times", nil),
                              NSLocalizedString(@"7 times", nil),
                              NSLocalizedString(@"5 times", nil),
                              NSLocalizedString(@"FBG", nil),
                              NSLocalizedString(@"3 Meals", nil),
                              NSLocalizedString(@"Trregular", nil),
                              NSLocalizedString(@"Customize", nil)];
        [self.planModeArray addObjectsFromArray:planMode];
        
    }
    
    if (!self.timeArray) {
        self.timeArray = [NSMutableArray array];
    }
    
    [self.timeArray removeAllObjects];
    
    
    //提醒时间段
    //时间段用NSUserDefault储存,时间名称用plist文件储存
    NSArray *remindTimeLine = [[NSUserDefaults standardUserDefaults] objectForKey:@"RemindTimeLine"];
    if (!remindTimeLine || remindTimeLine.count<=0)
    {
        remindTimeLine = @[@"3:00",@"7:30",@"8:00",@"8:30",@"9:00",@"10:00",@"11:00",@"12:00",@"12:30",@"13:00",@"14:00",@"15:00",@"19:00",@"19:30",@"20:00",@"21:00",@"22:00",@"23:00",];
        [[NSUserDefaults standardUserDefaults] setObject:remindTimeLine forKey:@"RemindTimeLine"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RemindStageName" ofType:@"plist"];
    NSArray *remindTimeName = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *remindTimeArray = [[NSMutableArray alloc] init];
    for (int i=0; i<remindTimeLine.count; i++)
    {
        [remindTimeArray addObject:[NSString stringWithFormat:@"%@\n%@",remindTimeName[i],remindTimeLine[i]]];
    }
    
    [self.timeArray addObjectsFromArray:remindTimeArray];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddRemind"]) {
        AddRemindViewController *addVC = [segue destinationViewController];
        addVC.reminders = self.drugReminders;
        addVC.remindType = RemindTypeAdd;
    }
    
    if ([segue.identifier isEqualToString:@"EditRemind"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        AddRemindViewController *editVC = [segue destinationViewController];
        editVC.reminders = self.drugReminders;
        editVC.remindType = RemindTypeEdit;
        editVC.reminder = [self.drugReminders objectAtIndex:indexPath.row];
        
    }
    if ([segue.identifier isEqualToString:@"EditTime"]) {
        RemindTimeViewController *editTimeVC = [segue destinationViewController];
        editTimeVC.reminderTimeChangedBlock  = ^{
            
            [self setUpDetectionReminderData];
            [self.detectionTableView reloadData];
        
        };
    }
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.swipeView.scrollEnabled = NO;
    self.reloadTableView = YES;
    [self.tabBar setSelectedItem:[self.tabBar items][0]];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addRemind:)];
    [self configureRightBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged) name:EKEventStoreChangedNotification object:nil];
    
    [self configureDrugReminders];
    [self configureDetectionReminders];
    
}

- (void)configureDrugReminders
{
    [self setupDrugRemindersData];
}

- (void)configureDetectionReminders
{
    [self setUpDetectionReminderData];
    [self initControlPlanData];
    _currentPlan = [[NSUserDefaults standardUserDefaults] integerForKey:@"GCUserRemindPlan"];
    self.planArray = [self.planDataArray[_currentPlan] mutableCopy];
    [self.detectionTableView reloadData];
}

- (void)storeChanged
{
    [[CalendarStack shareCalendarStack] fetchDrugRemindersWithCompletion:^(NSArray *reminders) {
        self.drugReminders = [NSMutableArray arrayWithArray:reminders];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.reloadTableView) {
                [self.drugRemindTableView reloadData];
            }
        });
    }];
}

- (void)setupDrugRemindersData
{
    [[CalendarStack shareCalendarStack] fetchDrugRemindersWithCompletion:^(NSArray *reminders) {
        self.drugReminders = [NSMutableArray arrayWithArray:reminders];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.drugRemindTableView reloadData];
        });
    }];
}



#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)aHud {
    // Remove HUD from screen when the HUD was hidded
    [aHud removeFromSuperview];
    aHud = nil;
}




#pragma mark - ControlPlan

- (void)planModeSelect
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = self.pickerView;
    hud.margin = 0;
    [hud show:YES];
}
- (IBAction)planModeBtn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag == 1001) {
        
        self.planArray = nil;
        NSInteger selectRow = [self.planPickerView selectedRowInComponent:0];
        self.planArray = [self.planDataArray[selectRow] mutableCopy];
        _currentPlan = selectRow;
        [self.detectionTableView reloadData];
        _remindChange = YES;
        [self configureRightBarButtonItem];
        
        [hud hide:YES];
    }
    
    [hud hide:YES afterDelay:0];
}

#pragma mark 闹钟按钮点击
- (void)controlPlanCell:(ControlPlanCell *)cell didClickButton:(UIButton *)button
{
    if (![self.controlPlanButton.currentTitle isEqualToString:NSLocalizedString(@"Customize", nil)])
    {
        [self.controlPlanButton setTitle:NSLocalizedString(@"Customize", nil)
                                forState:UIControlStateNormal];
    }
    
    
    NSIndexPath *indexPath = [self.detectionTableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    NSMutableArray *rowArray = [self.planArray[row] mutableCopy];
    
    if ([rowArray[button.tag-1] boolValue])
    {
        
        [button setImage:nil forState:UIControlStateNormal];
        
        [rowArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:button.tag-1];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        
        [rowArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:button.tag-1];
    }
    
    [self.planArray setObject:rowArray atIndexedSubscript:row];
    
    
    
    //每次点击保存当前状态进"自定义"模式
    [self.planDataArray setObject:self.planArray atIndexedSubscript:6];
    _currentPlan = 6;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.planArray forKey:@"RemindCustomPlan"];
    [user synchronize];
    
    _remindChange = YES;
    [self configureRightBarButtonItem];
}

#pragma mark - SwipeViewDataSource/Delegate
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 2;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UITableView *itemView;
    switch (index)
    {
        case 0:
            if (!self.drugRemindTableView) {
                self.drugRemindTableView = [[NSBundle mainBundle] loadNibNamed:@"Remind" owner:self options:nil][0];
                [self.drugRemindTableView registerNib:[UINib nibWithNibName:@"RemindCell" bundle:nil] forCellReuseIdentifier:@"RemindCell"];
                self.drugRemindTableView.tag  = 0;
                
            }
            itemView = self.drugRemindTableView;
            break;
        case 1:
            if (!self.detectionTableView) {
                self.detectionTableView = [[NSBundle mainBundle] loadNibNamed:@"ControlPlan" owner:self options:nil][0];
                self.detectionTableView.tag = 1;
                [self.detectionTableView registerNib:[UINib nibWithNibName:@"ControlSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:ControlHeaderViewIdentifier];
                [self.detectionTableView registerNib:[UINib nibWithNibName:@"ControlPlanCell" bundle:nil] forCellReuseIdentifier:@"ControlPlanCell"];
                
            }
            itemView = self.detectionTableView;
            break;
            
    }
    
    return itemView;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:swipeView.currentItemIndex];
    
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self configureRightBarButtonItem];
}

- (void)configureRightBarButtonItem
{
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(socialShare)];
    
    if (self.swipeView.currentItemIndex == 0)
    {
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addRemind:)];
        
        self.navigationItem.rightBarButtonItems = @[addItem,shareItem];
    }
    else
    {
        if (_remindChange)
        {
            UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveReminderChange:)];
            self.navigationItem.rightBarButtonItems = @[saveItem,shareItem];
        }
        else
        {
            self.navigationItem.rightBarButtonItems = @[shareItem];
        }
    }
}

#pragma mark - Saving/Deleting Reminders

- (void)saveReminderChange:(id)sender
{
    [self saveDetectionReminders];
    
}

- (void)addRemind:(id)sender
{
    if ([self.drugReminders count] >= 10) {
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.delegate = self;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Not to add more than 10 reminders.", nil);;
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    [self performSegueWithIdentifier:@"AddRemind" sender:nil];
}

- (void)colockBtnAction:(UISwitch *)sender
{
    if (sender.on) {
        [self saveDetectionReminders];
    }else{
        [self deleteDetectionReminders];
    }

}

- (void)saveDetectionReminders
{
    self.controlPlanSwitch.on = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self deleteDetectionRemindersWithCompletionBlock:^{
            [self setUpDetectionReminder];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GCUserIsReminded"];
            [[NSUserDefaults standardUserDefaults] setInteger:_currentPlan forKey:@"GCUserRemindPlan"];
            _remindChange = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configureRightBarButtonItem];
            });
            
        }];
    });
}

- (void)deleteDetectionReminders
{
    self.controlPlanSwitch.on = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self deleteDetectionRemindersWithCompletionBlock:^{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GCUserIsReminded"];
            [[NSUserDefaults standardUserDefaults] setInteger:_currentPlan forKey:@"GCUserRemindPlan"];
            _remindChange = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configureRightBarButtonItem];
            });
        }];
    });
}

- (void)deleteDetectionRemindersWithCompletionBlock:(void(^)())completion
{
    [[CalendarStack shareCalendarStack] deleteAllReminderForCalendarType:EKTypeDetection completionBlock:completion];
}

- (void)setUpDetectionReminder
{
    NSArray *remindTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"RemindTimeLine"];
    
    @autoreleasepool {
        
        [remindTime enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RemindItem *item = [[RemindItem alloc] init];
            item.title = NSLocalizedString(@"Remember to make a detection", nil);
            item.startDateComponents = [self dateComponentsForStartDate:remindTime[idx]];
            item.dueDateComponents = [self datecomponentsForDueDate:item.startDateComponents];
            item.completionComponents = item.dueDateComponents;
            item.days = [self configureDays:self.planArray[idx]];
            
            [[CalendarStack shareCalendarStack] addReminderItem:item forCalendarType:EKTypeDetection];
            
        }];
    }
    
}

- (NSDateComponents *)dateComponentsForStartDate:(NSString *)time
{
    NSRange range = [time rangeOfString:@":"];
    NSString *hours = [time substringToIndex:range.location];
    NSString *minute = [time substringFromIndex:range.location+1];
    
    NSDate *date = [NSDate date];
    NSCalendar *aCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    
    NSDateComponents *startDateComponents = [aCalendar components:unitFlags fromDate:date];
    startDateComponents.hour = [hours integerValue];
    startDateComponents.minute = [minute integerValue];
    startDateComponents.second = 0;
    
    return startDateComponents;
}

- (NSDateComponents *)datecomponentsForDueDate:(NSDateComponents *)start
{
    NSDateComponents *dueDateComponents = [[NSDateComponents alloc] init];
    dueDateComponents.era = start.era;
    dueDateComponents.year = start.year;
    dueDateComponents.month = start.month;
    dueDateComponents.day = start.day;
    dueDateComponents.hour = start.hour;
    dueDateComponents.minute = start.minute;
    dueDateComponents.second = 2;
    return dueDateComponents;
}

- (NSArray *)configureDays:(NSArray *)planDays
{
    NSMutableArray *days = [NSMutableArray arrayWithCapacity:7];
    [days addObject:[planDays lastObject]];
    [planDays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 6) {
            return ;
        }
        [days addObject:obj];
    }];
    
    return days;
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    switch (tableView.tag) {
        case 0:
            if (self.drugReminders.count > 0) {
                sections = 1;
            }else sections = 0;
            break;
        case 1:
            sections = 1;
            break;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (tableView.tag) {
        case 0:
            rows = [self.drugReminders count];
            break;
        case 1:
            rows = [self.timeArray count];
            break;
    }
    return rows;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 0)
        return nil;
    
    ControlHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ControlHeaderViewIdentifier];
    [headerView.controlPlanButton setTitle:self.planModeArray[_currentPlan] forState:UIControlStateNormal];
    [headerView.controlPlanButton addActionBlock:^(UIButton *sender) {
        [self planModeSelect];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.controlPlanButton = headerView.controlPlanButton;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GCUserIsReminded"])
    {
        headerView.controlPlanSwitch.on = YES;
    }
    else headerView.controlPlanSwitch.on = NO;

    [headerView.controlPlanSwitch addActionBlock:^(UISwitch *sender) {
        [self colockBtnAction:sender];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.controlPlanSwitch = headerView.controlPlanSwitch;
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 0) return 0;
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag)
    {
        case 0:
        {
            RemindCell *cell = [self.drugRemindTableView dequeueReusableCellWithIdentifier:@"RemindCell" forIndexPath:indexPath];
            [self configureDrugRemindCell:cell indexPath:indexPath];
            return cell;
        }
        case 1:
        {
            ControlPlanCell *cell = [self.detectionTableView dequeueReusableCellWithIdentifier:@"ControlPlanCell" forIndexPath:indexPath];
            
            [self configureControlPlanCell:cell indexPath:indexPath];
            return cell;
        }
            break;
    }
    return nil;
}

- (void)configureDrugRemindCell:(RemindCell *)cell indexPath:(NSIndexPath *)indexPath
{
    EKReminder *aReminder = self.drugReminders[indexPath.row];
    
    cell.remindTime.text = [self configureRemindTimeWithComponents:aReminder.startDateComponents];
    if (aReminder.hasRecurrenceRules) {
        cell.remindRules.text = [self configureRemindRules:aReminder.recurrenceRules[0]];
    }else cell.remindRules.text = @"";
    
    cell.remindLabel.text = aReminder.notes;
    
    //!important to update the cell when tableView refresh.
    if (aReminder.hasAlarms) {
        cell.remindView.backgroundColor = [UIColor whiteColor];
        cell.remindSwitch.on = YES;
    }else{
        cell.remindView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.remindSwitch.on = NO;
    }
    
    [cell.remindSwitch addActionBlock:^(UISwitch *sender) {
        self.reloadTableView = NO;
        if (sender.on) {
            cell.remindView.backgroundColor = [UIColor whiteColor];
            if (!aReminder.hasAlarms) {
                EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:0];
                [aReminder addAlarm:alarm];
            }
        
        }else{
            cell.remindView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            
            if (aReminder.hasAlarms) {
                [aReminder.alarms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [aReminder removeAlarm:obj];
                }];
            }
        }
        
        [[CalendarStack shareCalendarStack] saveReminder:aReminder];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)configureRemindRules:(EKRecurrenceRule *)rules
{
    NSMutableArray *days = [@[] mutableCopy];
    [rules.daysOfTheWeek enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EKRecurrenceDayOfWeek *recurrence = (EKRecurrenceDayOfWeek *)obj;
        switch (recurrence.dayOfTheWeek-1) {
            case 0:
                [days addObject:NSLocalizedString(@"Sunday", nil)];
                break;
            case 1:
                [days addObject:NSLocalizedString(@"Monday", nil)];
                break;
            case 2:
                [days addObject:NSLocalizedString(@"Tuesday", nil)];
                break;
            case 3:
                [days addObject:NSLocalizedString(@"Wednesday", nil)];
                break;
            case 4:
                [days addObject:NSLocalizedString(@"Thursday", nil)];
                break;
            case 5:
                [days addObject:NSLocalizedString(@"Friday", nil)];
                break;
            case 6:
                [days addObject:NSLocalizedString(@"Saturday", nil)];
                break;
            default:
                break;
        }
    }];
    
    NSString *remindRules = [days componentsJoinedByString:@" "];
    
    if ([remindRules isEqualToString:@""]) {
        remindRules = NSLocalizedString(@"Never", nil);
    }
    return remindRules;
}

- (NSString *)configureRemindTimeWithComponents:(NSDateComponents *)components
{
    NSCalendar *aCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [aCalendar dateFromComponents:components];
    return [NSString formattingDate:date to:@"HH:mm"];
}

- (void)configureControlPlanCell:(ControlPlanCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    cell.timeLabel.text = self.timeArray[indexPath.row];
    cell.timeLabel.font = [UIFont systemFontOfSize:12.0f];
    
    NSArray *rowArray = self.planArray[indexPath.row];
    if (!self.clock) {
        self.clock = [UIImage imageNamed:@"clock"];
    }
    
    [cell.controlPlanView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            __weak UIButton *btn = (UIButton *)obj;
            
            [btn addActionBlock:^(UIButton *sender) {
                [self controlPlanCell:cell didClickButton:btn];
            } forControlEvents:UIControlEventTouchUpInside];
            
            BOOL select = [rowArray[btn.tag-1] boolValue];
            
            select ? [btn setImage:self.clock forState:UIControlStateNormal] : [btn setImage:nil forState:UIControlStateNormal];

        }
    }];
}



#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow;
    heightForRow = [self tableView:tableView heightForBasicCellAtIndexPath:indexPath];
    return heightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == self.drugRemindTableView) {
        static RemindCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.drugRemindTableView dequeueReusableCellWithIdentifier:@"RemindCell"];
        });
        [self configureDrugRemindCell:sizingCell indexPath:indexPath];
        return [self tableView:tableView calculateHeightForConfiguredSizingCell:sizingCell];

    }
    
    if (tableView == self.detectionTableView) {
        static ControlPlanCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.detectionTableView dequeueReusableCellWithIdentifier:@"ControlPlanCell"];
        });
        [self configureControlPlanCell:sizingCell indexPath:indexPath];
        return [self tableView:tableView calculateHeightForConfiguredSizingCell:sizingCell];

    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    if (tableView == self.drugRemindTableView) {
         sizingCell.bounds = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.drugRemindTableView.bounds), 0.0f);
    }
    if (tableView == self.detectionTableView) {
         sizingCell.bounds = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.detectionTableView.bounds), 0.0f);
    }

    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView isEqual:self.drugRemindTableView])
    {
        self.reloadTableView = YES;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"EditRemind" sender:indexPath];
    }
    else
    {
        _remindChange = YES;
        [self configureRightBarButtonItem];
        [self performSegueWithIdentifier:@"EditTime" sender:nil];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EKReminder *deleteReminder = self.drugReminders[indexPath.row];
        [[CalendarStack shareCalendarStack] deleteReminder:deleteReminder];
    }
}



#pragma mark - Plan PickerViewHUD

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
        return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
        return self.planModeArray.count;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = self.planModeArray[row];
    
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



#pragma mark - TabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self.swipeView scrollToItemAtIndex:[self.tabBar.items indexOfObject:item] duration:0];
}

- (IBAction)back:(UIStoryboardSegue *)segue
{
    [self.detectionTableView reloadData];
}

- (IBAction)trash:(UIStoryboardSegue *)segue
{
    [self.detectionTableView reloadData];
}


#pragma mark - Social Share
- (void)socialShare
{
    [ShareHelper socailShareWithViewController:self shareText:@"" shareType:SocialShareTypeImage photographView:self.navigationController.view shareToSnsNames:@[UMShareToQQ,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail,UMShareToQzone]];
}


- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    
    if (platformName == UMShareToWechatTimeline || platformName == UMShareToWechatSession ||
        platformName == UMShareToQQ)
    {
        
        socialData.extConfig.qqData.title = @"";
        socialData.extConfig.qzoneData.title = @"";
        socialData.extConfig.wechatSessionData.title = @"";
        
        socialData.extConfig.qqData.shareText = @"";
        socialData.extConfig.qzoneData.shareText = @"";
        socialData.extConfig.wechatSessionData.shareText = @"";
        
        socialData.extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
        socialData.extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeImage;
        socialData.extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeImage;
    }
    else
    {
        socialData.title = @"";
    }
}

#pragma mark - 初始化预设方案数据
- (void)initControlPlanData
{
    self.planDataArray = [NSMutableArray array];
    
    NSNumber *o = [NSNumber numberWithBool:YES];
    NSNumber *x = [NSNumber numberWithBool:NO];
    
    
    //17点法
    NSArray *plan_seventeen = @[@[x,x,x,x,x,x,x],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o],
                                @[o,o,o,o,o,o,o]];
    [self.planDataArray addObject:plan_seventeen];
    
    //7点法
    NSArray *plan_seven = @[@[x,x,x,x,x,x,x],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o],
                            @[x,x,x,x,x,x,x],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o],
                            @[x,x,x,x,x,x,x],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o],
                            @[x,x,x,x,x,x,x],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o],
                            @[x,x,x,x,x,x,x],
                            @[o,o,o,o,o,o,o]];
    [self.planDataArray addObject:plan_seven];
    
    //5点法
    NSArray *plan_five = @[@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[o,o,o,o,o,o,o],
                           @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[o,o,o,o,o,o,o],
                           @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                           @[x,x,x,x,x,x,x],@[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],
                           @[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                           @[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x]];
    [self.planDataArray addObject:plan_five];
    
    //空腹高血糖监控
    NSArray *plan_heightGlu = @[@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],
                                @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                @[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[o,o,o,o,o,o,o]];
    [self.planDataArray addObject:plan_heightGlu];
    
    //三餐影响监测法
    NSArray *plan_threeMeals = @[@[x,x,x,x,x,x,x],
                                 @[o,o,o,o,o,o,o],
                                 @[x,o,x,x,o,x,o],
                                 @[x,o,x,x,o,x,o],
                                 @[x,o,x,x,o,x,o],
                                 @[x,o,x,x,o,x,o],
                                 @[x,o,x,x,o,x,o],
                                 @[x,x,o,x,x,o,o],
                                 @[x,x,o,x,x,o,o],
                                 @[x,x,o,x,x,o,o],
                                 @[x,x,o,x,x,o,o],
                                 @[x,x,o,x,x,o,o],
                                 @[o,x,x,o,x,x,o],
                                 @[o,x,x,o,x,x,o],
                                 @[o,x,x,o,x,x,o],
                                 @[o,x,x,o,x,x,o],
                                 @[o,x,x,o,x,x,o],
                                 @[o,o,o,o,o,o,o]];
    [self.planDataArray addObject:plan_threeMeals];
    
    //无症状监测
    NSArray *plan_asymptomatic = @[@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[o,o,o,o,o,o,o],
                                   @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[o,o,o,o,o,o,o],
                                   @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                   @[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                   @[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x],
                                   @[o,o,o,o,o,o,o],@[x,x,x,x,x,x,x],@[x,x,x,x,x,x,x]];
    [self.planDataArray addObject:plan_asymptomatic];
    
    
    //自定义
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *customArray = [user objectForKey:@"RemindCustomPlan"];
    
    if (!customArray || customArray.count<=0)
    {
        NSArray *plan_custom = @[@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],
                                 @[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],
                                 @[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],
                                 @[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],
                                 @[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],
                                 @[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o],@[o,o,o,o,o,o,o]];
        [self.planDataArray addObject:plan_custom];
    }
    else
    {
        [self.planDataArray addObject:customArray];
    }
    
}


@end
