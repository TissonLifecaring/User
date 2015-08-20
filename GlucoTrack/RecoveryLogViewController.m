//
//  RecoveryLogViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RecoveryLogViewController.h"
#import "TimelineCell.h"
#import "NSString+Attribute.h"
#import <RMDateSelectionViewController.h>
#import "RecoveryLogHeaderView.h"
#import "RecoveryLogDetailViewController.h"
#import "TimelineTableView.h"
#import "UtilsMacro.h"
#import "NSString+Formatting.h"
#import "ShareHelper.h"


static NSString * const TimelineCellIdentifier = @"TimelineCell";

@interface RecoveryLogViewController ()<UITableViewDataSource,UITableViewDelegate,RMDateSelectionViewControllerDelegate,NSFetchedResultsControllerDelegate,SSPullToRefreshViewDelegate,MBProgressHUDDelegate,UMSocialUIDelegate>{
    MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet TimelineTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *popOverView;
@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) UserSetting *setting;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSMutableArray *logTypeArray;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;

@property (weak, nonatomic) IBOutlet UIButton *detectCheckbox;
@property (weak, nonatomic) IBOutlet UIButton *drugCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *dietCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *exerciseCheckBox;

@end

@implementation RecoveryLogViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddLog"]) {
        RecoveryLogDetailViewController *addVC = [segue destinationViewController];
        addVC.recoveryLogStatus = RecoveryLogStatusAdd;
    }
    
    if ([segue.identifier isEqualToString:@"EditLog"]) {
        RecoveryLogDetailViewController *editVC = [segue destinationViewController];
        RecordLog *recordLog = [self.fetchController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        editVC.recordLog = recordLog;
        editVC.recoveryLogStatus = RecoveryLogStatusEdit;

        if ([recordLog.logType isEqualToString:@"detect"]) {
            editVC.recoveryLogType = RecoveryLogTypeDetect;
        }
        if ([recordLog.logType isEqualToString:@"drug"]) {
            editVC.recoveryLogType = RecoveryLogTypeDrug;
        }
        if ([recordLog.logType isEqualToString:@"diet"]) {
            editVC.recoveryLogType = RecoveryLogTypeDiet;
        }
        if ([recordLog.logType isEqualToString:@"exercise"]) {
            editVC.recoveryLogType = RecoveryLogTypeExercise;
        }
    }
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedDate = [NSDate date];
    [self.dateButton setTitle:[NSString formattingDate:self.selectedDate to:@"YYYY-MM-dd"] forState:UIControlStateNormal];
    [self configureUserSetting];
    [self configureTableView];
    [self configureFetchController:NO];
    [self configureBarItems];
}

//- (void)configureRefreshView
//{
//    self.refreshView = [YALSunnyRefreshControl attachToScrollView:self.tableView];
//    self.refreshView.delegate = self;
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self.refreshView startRefreshing];
//
//}
//
//- (void)YALRefreshViewDidStartLoading:(YALSunnyRefreshControl *)view
//{
//    [self getRecoveryLog];
//}

- (void)configureBarItems
{
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonTapInsideEvent)];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonTapInsideEvent)];
    self.navigationItem.rightBarButtonItems = @[addItem,shareItem];
}
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self getRecoveryLog];
}

- (void)configureUserSetting
{
    self.logTypeArray = [@[] mutableCopy];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    NSArray *userSetting = [UserSetting findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];

    if (userSetting.count == 0) {
        self.setting = [UserSetting createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        userID.userId = [NSString userID];
        userID.linkManId = [NSString linkmanID];
        self.setting.userid = userID;
        [[CoreDataStack sharedCoreDataStack] saveContext];
    }else{
        self.setting = [UserSetting findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context][0];
    }
    
    if ([self.setting.detect boolValue] == YES) {
        [self.detectCheckbox setImage:[UIImage imageNamed:@"CheckboxY"] forState:UIControlStateNormal];
        [self.logTypeArray addObject:@"detect"];
    }else [self.detectCheckbox setImage:[UIImage imageNamed:@"CheckboxN"] forState:UIControlStateNormal];
    
    if ([self.setting.drug boolValue] == YES) {
        [self.drugCheckBox setImage:[UIImage imageNamed:@"CheckboxY"] forState:UIControlStateNormal];
        [self.logTypeArray addObject:@"drug"];
    }else [self.drugCheckBox setImage:[UIImage imageNamed:@"CheckboxN"] forState:UIControlStateNormal];
    
    if ([self.setting.diet boolValue] == YES) {
        [self.dietCheckBox setImage:[UIImage imageNamed:@"CheckboxY"] forState:UIControlStateNormal];
        [self.logTypeArray addObject:@"diet"];
    }else [self.dietCheckBox setImage:[UIImage imageNamed:@"CheckboxN"] forState:UIControlStateNormal];
    
    if ([self.setting.exercise boolValue] == YES) {
        [self.exerciseCheckBox setImage:[UIImage imageNamed:@"CheckboxY"] forState:UIControlStateNormal];
        [self.logTypeArray addObject:@"exercise"];
    }else [self.exerciseCheckBox setImage:[UIImage imageNamed:@"CheckboxN"] forState:UIControlStateNormal];
    
}


- (void)configureFetchController:(BOOL)refresh
{
    NSDate *formerDate;
    NSDate *laterDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd000000"];
    NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self.selectedDate]];
    formerDate = aDate;
    
    laterDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:formerDate];
    
    NSPredicate *predicate;
    if (refresh) {
        predicate = [NSPredicate predicateWithFormat:
                                  @"userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && logType in %@",
                                  [NSString userID],
                                  [NSString linkmanID],
                                  formerDate,
                                  laterDate,
                                  @[@"detect",@"exercise",@"drug",@"diet"]];
    }else{
        predicate = [NSPredicate predicateWithFormat:
                                @"userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && logType in %@",
                                [NSString userID],
                                [NSString linkmanID],
                                formerDate,
                                laterDate,
                                self.logTypeArray];
    }
    
    self.fetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    [self.tableView reloadData];

}

- (void)configureTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}

- (void)getRecoveryLog
{
    [self configureFetchController:YES];
    
    NSString *queryDay = [NSString formattingDate:self.selectedDate to:@"yyyyMMdd"];
    
    NSDictionary *parameters = @{@"method":@"queryCureLogTimeLine2",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],
                                 @"queryDay":queryDay};
    [GCRequest userGetRecoveryRecordWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                for (RecordLog *recordLog in self.fetchController.fetchedObjects)
                {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
            
                NSArray *detectLogArr = [responseData objectForKey:@"detectLogList"];
                NSArray *dietLogArr = [responseData objectForKey:@"dietLogList"];
                NSArray *drugLogArr = [responseData objectForKey:@"drugLogList"];
                NSArray *exerciseLogArr = [responseData objectForKey:@"exerciseLogList"];
            
                
                for (NSDictionary *detectLogDic in detectLogArr) {
                
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *detectLogDic_ = [detectLogDic mutableCopy];
                    [detectLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:detectLogDic_ withKeyPath:nil];
                    
                    DetectLog *detect = [DetectLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *detectDic = [[detectLogDic objectForKey:@"detectLog"] mutableCopy];
                    [detectDic feelingFormattingToUserForKey:@"selfSense"];
                    [detectDic dataSourceFormattingToUserForKey:@"dataSource"];
                    [detectDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"detectTime"];
                    [detectDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [detect updateCoreDataForData:detectDic withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    recordLog.detectLog = detect;
                    recordLog.userid = userID;
                }
                
                for (NSDictionary *dietLogDic in dietLogArr) {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *dietLogDic_ = [dietLogDic mutableCopy];
                    [dietLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:dietLogDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    DietLog *diet = [DietLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *dietDic = [[dietLogDic objectForKey:@"dietLog"] mutableCopy];
                    [dietDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"eatTime"];
                    [dietDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [dietDic eatPeriodFormattingToUserForKey:@"eatPeriod"];
                    [diet updateCoreDataForData:dietDic withKeyPath:nil];
                    
                    NSMutableOrderedSet *foodList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    for (NSDictionary *foodDic in [dietDic objectForKey:@"foodList"]) {
                        
                        NSMutableDictionary *fooDic_ = [foodDic mutableCopy];
                        [fooDic_ eatUnitsFormattingToUserForKey:@"unit"];
                        
                        Food *food = [Food createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [food updateCoreDataForData:fooDic_ withKeyPath:nil];
                        [foodList addObject:food];
                    }
                    
                    recordLog.userid = userID;
                    recordLog.dietLog = diet;
                    diet.foodList = foodList;

                }
                
                for (NSDictionary *drugLogDic in drugLogArr) {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *drugLogDic_ = [drugLogDic mutableCopy];
                    [drugLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:drugLogDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    DrugLog *drug = [DrugLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    
                    NSMutableDictionary *drugDic_ = [[drugLogDic objectForKey:@"drugLog"] mutableCopy];
                    [drugDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"medicineTime"];
                    [drugDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [drug updateCoreDataForData:drugDic_ withKeyPath:nil];
                    
                    NSMutableOrderedSet *medicineList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    
                    for (NSDictionary *medicineDic in [[drugLogDic objectForKey:@"drugLog"] objectForKey:@"medicineList"]) {
                        
                        NSMutableDictionary *medicineDic_ = [medicineDic mutableCopy];
                        [medicineDic_ medicineUnitsFormattingToUserForKey:@"unit"];
                        [medicineDic_ medicineUsageFormattingToUserForKey:@"usage"];
                        
                        Medicine *medicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [medicine updateCoreDataForData:medicineDic_ withKeyPath:nil];
                        [medicineList addObject:medicine];
                    }
                    
                    recordLog.userid = userID;
                    drug.medicineList = medicineList;
                    recordLog.drugLog = drug;

                }
                
                for (NSDictionary *exerciseLogDic in exerciseLogArr) {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *exerciseLogDic_ = [exerciseLogDic mutableCopy];
                    [exerciseLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    
                    [recordLog updateCoreDataForData:exerciseLogDic_ withKeyPath:nil];
                    
                    ExerciseLog *exercise = [ExerciseLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *exerciseDic_ = [[exerciseLogDic objectForKey:@"exerciseLog"] mutableCopy];
                    [exerciseDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"sportTime"];
                    [exerciseDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [exercise updateCoreDataForData:exerciseDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    recordLog.exerciseLog = exercise;
                    recordLog.userid = userID;

                }
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
            }
            else
            {
                if (!HUD)
                {
                    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD.mode = MBProgressHUDModeText;
                    HUD.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
                    [HUD hide:YES afterDelay:HUD_TIME_DELAY];
                }
            }
        }
        
        
        // 无论是请求成功或者失败，都要再重新fetch一次，以过滤用户对日期和选项的筛选
        
        [self configureFetchController:NO];
        if (self.refreshView) {
            [self.refreshView finishLoading];
        }

    }];
}

#pragma mark - NSFectchedResultController

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}


//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    switch (type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case NSFetchedResultsChangeMove:
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case NSFetchedResultsChangeUpdate:
//        {
//            TimelineCell *cell = (TimelineCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//            [self configureTimelineCell:cell atIndexPath:indexPath];
//            
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections;
    if (self.fetchController.fetchedObjects.count == 0) {
        sections = 0;
    }else sections = [self.fetchController.sections count];
    return sections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchController.sections[section] numberOfObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RecoveryLogHeaderView *headerView = [[RecoveryLogHeaderView alloc] init];
    [self configureHeaderSectionView:headerView inSection:section];
    return headerView;
}

- (void)configureHeaderSectionView:(RecoveryLogHeaderView *)headerView inSection:(NSInteger)section
{
    headerView.day = self.selectedDate;
    headerView.currentDay = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self timelineCellAtIndexPath:indexPath];
}


- (TimelineCell *)timelineCellAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TimelineCellIdentifier forIndexPath:indexPath];
    [self configureTimelineCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)setupConstrainsWithTimelineCell:(TimelineCell *)cell
{
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
}

- (void)configureTimelineCell:(TimelineCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    RecordLog *recordLog = [self.fetchController objectAtIndexPath:indexPath];
    
    // Configure Time
    
    cell.timeLabel.text = [NSString formattingDate:recordLog.time to:@"HH:mm"];

    // Configure Icon
    cell.timelineImageView.image = [self configureImageForTimelineCell:recordLog.logType];
    
    // Configure Title
    NSString *key = recordLog.logType;
    cell.titleLabel.text = NSLocalizedString(key, nil);
    
    // Configure Detail content
    cell.detailLabel.text = [self configureDetailInfoForRecordLog:recordLog];
    
    
//    NSAttributedString *detailContentAttr = [[NSAttributedString alloc] initWithString:detailContent attributes:[NSString attributeCommonInit]];
//    cell.detailLabel.attributedText = detailContentAttr;
    
    [self setupConstrainsWithTimelineCell:cell];

    
}

- (UIImage *)configureImageForTimelineCell:(NSString *)type
{
    UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",type]];
    return iconImage;
}

- (NSString *)configureDetailInfoForRecordLog:(RecordLog *)recordLog
{
    NSString *detailContent = @"";
    if ([recordLog.logType isEqualToString:@"detect"]) {
        DetectLog *detect = recordLog.detectLog;

        if (detect.glucose && ![detect.glucose isEqualToString:@""]) {
            detailContent = [NSString stringWithFormat:@"%@  %.1fmmol/L  %@",NSLocalizedString(@"glucose", nil), detect.glucose.floatValue,detect.dataSource ];
        }
        if (detect.hemoglobinef && ![detect.hemoglobinef isEqualToString:@""]) {
            detailContent = [detailContent stringByAppendingFormat:@"\n%@  %.1f%%  %@",NSLocalizedString(@"hemoglobin", nil), detect.hemoglobinef.floatValue, detect.dataSource];
        }
        
        if ([detailContent hasPrefix:@"\n"]) {
            detailContent = [detailContent substringFromIndex:1];
        }
        
    }
    
    if ([recordLog.logType isEqualToString:@"diet"]) {
        DietLog *diet = recordLog.dietLog;
        NSMutableArray *foodArr = [NSMutableArray arrayWithCapacity:10];
        for (Food *food in diet.foodList) {
            NSString *aFood = [NSString stringWithFormat:@"%@  %@  %@%@  %.f%@",food.sort,food.food,food.weight,food.unit,food.calorie.floatValue,NSLocalizedString(@"calorie", nil)];
            [foodArr addObject:aFood];
        }
        
        detailContent = [foodArr componentsJoinedByString:@"\n"];
        
        if (diet.calorie.floatValue != 0) {
             detailContent = [detailContent stringByAppendingFormat:@"\n%@ %.f%@",NSLocalizedString(@"共摄入", nil),diet.calorie.floatValue,NSLocalizedString(@"calorie", nil)];
        }
    }
    
    if ([recordLog.logType isEqualToString:@"drug"]) {
        DrugLog *drug = recordLog.drugLog;
        NSMutableArray *medicineArr = [NSMutableArray arrayWithCapacity:10];
        for (Medicine *medicine in drug.medicineList) {
            NSString *aMedicine = [NSString stringWithFormat:@"%@  %@  %@  %@%@",medicine.sort,medicine.usage,medicine.drug,medicine.dose,medicine.unit];
            [medicineArr addObject:aMedicine];
        }
        detailContent = [medicineArr componentsJoinedByString:@"\n"];
    }
    
    if ([recordLog.logType isEqualToString:@"exercise"]) {
        ExerciseLog *exercise = recordLog.exerciseLog;
        detailContent = [NSString stringWithFormat:@"%@  %@%@  %.f%@",exercise.sportName,exercise.duration,NSLocalizedString(@"minutes", nil),exercise.calorie.floatValue,NSLocalizedString(@"calorie", nil)];
    }
    
    return detailContent;
}

#pragma mark - TableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static TimelineCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:TimelineCellIdentifier];
    });
    [self configureTimelineCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:aHud];
        aHud.delegate = self;
        aHud.labelText = NSLocalizedString(@"Saving Data", nil);
        [aHud show:YES];
    
        RecordLog *deleteLog = [self.fetchController objectAtIndexPath:indexPath];
        
        if ([deleteLog.logType isEqualToString:@"detect"]) {
            
            NSDictionary *parameters = @{@"method":@"detectLogDelete",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         @"detectId":deleteLog.id};
            [GCRequest userDeleteDetectLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
                aHud.mode = MBProgressHUDModeText;
                if (!error) {
                    NSString *ret_code = [responseData valueForKey:@"ret_code"];
                    if ([ret_code isEqualToString:@"0"]) {
                        [deleteLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                    }else{
                        aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    }
                }else{
                    aHud.labelText = NSLocalizedString(@"Server is busy", nil);
                }
                
                [aHud hide:YES afterDelay:HUD_TIME_DELAY];
            }];
        }
        
        if ([deleteLog.logType isEqualToString:@"drug"]) {
            
            NSDictionary *parameters = @{@"method":@"drugLogDelete",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         @"medicineId":deleteLog.id};
            [GCRequest userDeleteDrugLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
                aHud.mode = MBProgressHUDModeText;
                if (!error) {
                    NSString *ret_code = [responseData valueForKey:@"ret_code"];
                    if ([ret_code isEqualToString:@"0"]) {
                        [deleteLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                    }else{
                        aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    }
                }else{
                    aHud.labelText = NSLocalizedString(@"Server is busy", nil);
                }
                [aHud hide:YES afterDelay:HUD_TIME_DELAY];

            }];
        }
        
        if ([deleteLog.logType isEqualToString:@"diet"]) {
            NSDictionary *parameters = @{@"method":@"dietLogDelete",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         @"eatId":deleteLog.id};
            [GCRequest userDeleteDietLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
                aHud.mode = MBProgressHUDModeText;
                if (!error) {
                    NSString *ret_code = [responseData valueForKey:@"ret_code"];
                    if ([ret_code isEqualToString:@"0"]) {
                        [deleteLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                    }else{
                        aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    }
                }else{
                    aHud.labelText = NSLocalizedString(@"Server is busy", nil);
                }
                [aHud hide:YES afterDelay:HUD_TIME_DELAY];

            }];
        }
        
        if ([deleteLog.logType isEqualToString:@"exercise"]) {
            NSDictionary *parameters = @{@"method":@"exerciseLogDelete",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         @"sportId":deleteLog.id};
            [GCRequest userDeleteExerciseLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
                aHud.mode = MBProgressHUDModeText;
                if (!error) {
                    NSString *ret_code = [responseData valueForKey:@"ret_code"];
                    if ([ret_code isEqualToString:@"0"]) {
                        [deleteLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                    }else{
                        aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    }
                }else{
                    aHud.labelText = NSLocalizedString(@"Server is busy", nil);
                }
                [aHud hide:YES afterDelay:HUD_TIME_DELAY];

            }];
        }
    }
}

#pragma mark - userAction

- (IBAction)topButtonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 0) {
        [self.tableView reloadData];
    } else if (btn.tag == 1) {
        
        [RMDateSelectionViewController setLocalizedTitleForCancelButton:NSLocalizedString(@"Cancel", nil)];
        [RMDateSelectionViewController setLocalizedTitleForNowButton:NSLocalizedString(@"30 days recently", nil)];
        [RMDateSelectionViewController setLocalizedTitleForSelectButton:NSLocalizedString(@"Select By Day", nil)];
        
        RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
        dateSelectionVC.delegate = self;
        dateSelectionVC.hideNowButton = YES;
        dateSelectionVC.disableBlurEffects = YES;
        dateSelectionVC.disableBouncingWhenShowing = NO;
        dateSelectionVC.disableMotionEffects = NO;
        dateSelectionVC.blurEffectStyle = UIBlurEffectStyleExtraLight;
        dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
        [dateSelectionVC show];
        
    } else if (btn.tag == 2) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        HUD.margin = 0;
        HUD.customView = self.popOverView;
        HUD.mode = MBProgressHUDModeCustomView;
        [HUD show:YES];
    }
}

- (IBAction)optionTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 100:
        {
            // Cancel
            break;
        }
        case 101:
        {
            [self configureFetchController:NO];
            break;
        }
        default:
            break;
    }

    [HUD hide:YES afterDelay:0.2];
}

- (IBAction)checkboxSelected:(id)sender
{
    UIButton *selectBtn = (UIButton *)sender;

    if ([selectBtn.currentImage isEqual:[UIImage imageNamed:@"CheckboxN"]]) {
        [selectBtn setImage:[UIImage imageNamed:@"CheckboxY"] forState:UIControlStateNormal];
        
        NSString *type ;
        switch (selectBtn.tag) {
            case 1:
            {
                type = @"detect";
                self.setting.detect = @1;
                break;
            }
            case 2:
            {
                type = @"drug";
                self.setting.drug = @1;
                break;
            }
            case 3:
            {
                type = @"diet";
                self.setting.diet = @1;
                break;
            }
            case 4:
            {
                type = @"exercise";
                self.setting.exercise = @1;
                break;
            }
            default:
                break;
        }
        
        if (![self.logTypeArray containsObject:type]) {
            if (type) {
                [self.logTypeArray addObject:type];
            }
        }
        
    } else {
        [selectBtn setImage:[UIImage imageNamed:@"CheckboxN"] forState:UIControlStateNormal];
        
        NSString *type ;
        switch (selectBtn.tag) {
            case 1:
            {
                type = @"detect";
                self.setting.detect = @0;
                break;
            }
            case 2:
            {
                type = @"drug";
                self.setting.drug = @0;
                break;
            }
            case 3:
            {
                type = @"diet";
                self.setting.diet = @0;
                break;
            }
            case 4:
            {
                type = @"exercise";
                self.setting.exercise = @0;
                break;
            }
            default:
                break;
        }
        
        if ([self.logTypeArray containsObject:type]) {
            [self.logTypeArray removeObject:type];
        }
    }
    
    [[CoreDataStack sharedCoreDataStack] saveContext];
    
}


- (void)addButtonTapInsideEvent
{
    [self performSegueWithIdentifier:@"AddLog" sender:nil];
}


#pragma mark - Social Share
- (void)shareButtonTapInsideEvent
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




#pragma mark - RMDateSelectionViewControllerDelegate

- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    self.selectedDate = aDate;
    [self.dateButton setTitle:[NSString formattingDate:self.selectedDate to:@"YYYY-MM-dd"] forState:UIControlStateNormal];
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}

- (void)dateSelectionViewControllerNowButtonPressed:(RMDateSelectionViewController *)vc
{
    [vc dismiss];
}

#pragma mark - unwindSegue

- (IBAction)back:(UIStoryboardSegue *)segue
{
    
}


@end
