//
//  TestTrackerViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "TestTrackerViewController.h"
#import "UtilsMacro.h"
#import "DetectDataCell.h"
#import "VendorMacro.h"
#import "DataView.h"
#import "ShareHelper.h"

typedef NS_ENUM(NSInteger, GCType) {
    GCTypeTable = 0,
    GCTypeLine
};


typedef NS_ENUM(NSInteger, GCSearchMode)
{
    GCSearchModeByDay = 0,
    GCSearchModeByThreeDay,
    GCSearchModeByWeek,
    GCSearchModeByTwoWeek,
    GCSearchModeByMonth,
    GCSearchModeByTwoMonth,
    GCSearchModeByThreeMonth
};

typedef NS_ENUM(NSInteger, GCLineType) {
    GCLineTypeGlucose = 0,
    GCLineTypeHemo
};

@interface TestTrackerViewController ()<MBProgressHUDDelegate, NSFetchedResultsControllerDelegate, SSPullToRefreshViewDelegate,RMDateSelectionViewControllerDelegate,UMSocialUIDelegate,MBProgressHUDDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    MBProgressHUD *hud;
    BOOL timeAscending;
}


@property (strong, nonatomic) IBOutlet UIView *datePeriodSelectionView;
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;


@property (strong, nonatomic) SSPullToRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoTime;
@property (weak, nonatomic) IBOutlet UILabel *infoType;
@property (weak, nonatomic) IBOutlet UITextView *infoText;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoUnitLabel;



@property (strong, nonatomic) NSFetchedResultsController *GfetchController;
@property (strong, nonatomic) NSFetchedResultsController *HfetchController;
@property (strong, nonatomic) NSFetchedResultsController *dietFetchController;
@property (strong, nonatomic) NSFetchedResultsController *drugFetchController;

@property (strong, nonatomic) NSMutableArray *glucoseArray;
@property (strong, nonatomic) NSArray *trackPeriodArray;


@property (assign) GCLineType lineType;
@property (assign) GCSearchMode searchMode;
@property (assign) GCType viewType;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@property (assign, nonatomic) CGFloat minValueG;
@property (assign, nonatomic) CGFloat maxValueG;
@property (assign, nonatomic) CGFloat minValueH;
@property (assign, nonatomic) CGFloat maxValueH;

@end

@implementation TestTrackerViewController

- (void)awakeFromNib
{
    //预置数据
    self.trackPeriodArray = @[NSLocalizedString(@"Select By Three Days", nil),
                              NSLocalizedString(@"Select By Week", nil),
                              NSLocalizedString(@"Select By Two Weeks", nil),
                              NSLocalizedString(@"Select By Month", nil),
                              NSLocalizedString(@"Select By Two Months", nil),
                              NSLocalizedString(@"Select By Three Months", nil)];
    
    
    self.lineType = GCLineTypeGlucose;
    self.viewType = GCTypeLine;
    self.glucoseArray = [NSMutableArray arrayWithCapacity:20];
    
    
    self.searchMode = GCSearchModeByMonth;
    self.selectedDate = [NSDate date];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureDefaultSetting];
    [self configureGraph];
    [self configureRefreshView];
    [self configureGraphAndTableView];
    [self configureFetchController];
    [self reloadAllViews];
}


- (void)configureDefaultSetting
{
    self.unitLabel.text = @"mmol/L";
    [self.dateButton setTitle:NSLocalizedString(@"Select By Month", nil)
                     forState:UIControlStateNormal];
    
    
    [self setBarRightItems];
    [self.tabBar setSelectedItem:[self.tabBar items][0]];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)configureGraphAndTableView
{
    switch (self.viewType)
    {
        case GCTypeLine:
            self.trackerChart.hidden = NO;
            self.tableView.hidden = YES;
            break;
        case GCTypeTable:
            self.trackerChart.hidden = YES;
            self.tableView.hidden = NO;
    }
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UIView *iconActionSheet = [self.navigationController.view viewWithTag:kTagSocialIconActionSheet];
    [iconActionSheet setNeedsDisplay];
}


#pragma mark - FetchController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self reloadAllViews];
}

- (void)configureGluoseArray;
{
    if (self.glucoseArray)
    {
        [self.glucoseArray removeAllObjects];
    }
    
    [self.glucoseArray addObjectsFromArray:self.GfetchController.fetchedObjects];
    [self.glucoseArray addObjectsFromArray:self.dietFetchController.fetchedObjects];
    [self.glucoseArray addObjectsFromArray:self.drugFetchController.fetchedObjects];
    
    NSSortDescriptor *timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:timeAscending];
    [self.glucoseArray sortUsingDescriptors:@[timeSort]];
}

- (void)configureFetchController
{
    NSPredicate *Gpredicate;
    NSPredicate *Hpredicate;
    NSPredicate *dietPredicate;
    NSPredicate *drugPredicate;
    
    NSDate *formerDate;
    NSDate *laterDate;
    
    switch (self.searchMode) {
        case GCSearchModeByDay:
        {
            timeAscending = YES;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd000000"];
            NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self.selectedDate]];
            formerDate = aDate;
            
            laterDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:formerDate];
            
            
            Gpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && detectLog.glucose != %@ && detectLog.glucose != %@" ,@"detect",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",@"",nil];
            
            Hpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && detectLog.hemoglobinef != %@ && detectLog.hemoglobinef != %@" ,@"detect",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",@"",nil];
            
            drugPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && drugLog.glucose != %@",@"changeDrug",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",nil];
            dietPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && dietLog.glucose != %@",@"dietPoint",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",nil];
            
            break;
        }
        default:
        {
            
            NSInteger days = 0;
            
            switch (self.searchMode)
            {
                case GCSearchModeByThreeDay:    days = 3;
                    break;
                case GCSearchModeByWeek:        days = 7;
                    break;
                case GCSearchModeByTwoWeek:     days = 14;
                    break;
                case GCSearchModeByMonth:       days = 30;
                    break;
                case GCSearchModeByTwoMonth:    days = 60;
                    break;
                case GCSearchModeByThreeMonth:  days = 90;
                    break;
                default:
                    days = 0;
                    break;
            }
            
            timeAscending = NO;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd000000"];
            NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self.selectedDate]];
            laterDate = aDate;
            
            laterDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:laterDate];
            
            
            NSTimeInterval timeInterVal = -1 *days * 24 * 60 * 60;
            formerDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:laterDate];
            
            Gpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && detectLog.glucose != %@ && detectLog.glucose != %@" ,@"detect",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",@"",nil];
            
            Hpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && detectLog.hemoglobinef != %@ && detectLog.hemoglobinef != %@" ,@"detect",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",@"",nil];
            
            drugPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && drugLog.glucose != %@",@"changeDrug",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",nil];
            dietPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && userid.userId = %@ && userid.linkManId = %@ && time > %@ && time < %@ && dietLog.glucose != %@",@"dietPoint",[NSString userID],[NSString linkmanID],formerDate,laterDate,@"",nil];
            
            break;
        }
    }
    
    
    self.GfetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:Gpredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    self.HfetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:Hpredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    self.dietFetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:dietPredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    self.drugFetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:drugPredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    [self configureGluoseArray];
    
}

- (void)reloadAllViews
{
    [self calculateMaxAndMinValue];
    [self.trackerChart reloadGraph];
    [self.tableView reloadData];
}

- (void)getDetectionData
{
    MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:aHud];
    
    aHud.delegate = self;
    [aHud show:YES];
    
    
    [self configureFetchController];
    
    NSString *lineType;
    switch (self.lineType) {
        case GCLineTypeGlucose:
            lineType = @"1";
            break;
        case GCLineTypeHemo:
            lineType= @"2";
            break;
    }
    
    NSMutableDictionary *parameters = [@{@"method":@"queryDetectDetailLine2",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         } mutableCopy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    
    switch (self.searchMode)
    {
        case GCSearchModeByDay:
        {
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            NSString *dateString = [dateFormatter stringFromDate:self.selectedDate];
            [parameters setValue:dateString forKey:@"queryDay"];
        }
            break;
        case GCSearchModeByThreeDay:
        {
            [parameters setValue:@"3" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByWeek:
        {
            [parameters setValue:@"7" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByTwoWeek:
        {
            [parameters setValue:@"14" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByMonth:
        {
            [parameters setValue:@"30" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByTwoMonth:
        {
            [parameters setValue:@"60" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByThreeMonth:
        {
            [parameters setValue:@"90" forKey:@"countDay"];
        }
            break;
        default:
            break;
    }
    
    
    [GCRequest userGetDetectionDataWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                // 清除缓存
                for (RecordLog *recordLog in self.GfetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                for (RecordLog *recordLog in self.HfetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                for (RecordLog *recordLog in self.dietFetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                for (RecordLog *recordLog in self.drugFetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                NSArray *detectLogArr = [responseData objectForKey:@"detectLogList"];
                
                for (NSDictionary *detectLogDic in detectLogArr) {
                    
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *detectLogDic_ = [detectLogDic mutableCopy];
                    [detectLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:detectLogDic_ withKeyPath:nil];
                    
                    DetectLog *detect = [DetectLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *detectDic_ = [[detectLogDic objectForKey:@"detectLog"] mutableCopy];
                    [detectDic_ feelingFormattingToUserForKey:@"selfSense"];
                    [detectDic_ dataSourceFormattingToUserForKey:@"dataSource"];
                    [detectDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"detectTime"];
                    [detectDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [detect updateCoreDataForData:detectDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    recordLog.detectLog = detect;
                    recordLog.userid = userID;
                }
                
                NSArray *dietLogArr = [responseData objectForKey:@"dietPointList"];
                for (NSDictionary *dietLogDic in dietLogArr) {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *dietLogDic_ = [dietLogDic mutableCopy];
                    [dietLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:dietLogDic_ withKeyPath:nil];
                    
                    DietLog *diet = [DietLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *dietDic_ = [[dietLogDic objectForKey:@"dietPoint"] mutableCopy];
                    [dietDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"eatTime"];
                    [dietDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [dietDic_ eatPeriodFormattingToUserForKey:@"eatPeriod"];
                    [diet updateCoreDataForData:dietDic_ withKeyPath:nil];
                    
                    NSMutableOrderedSet *foodList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    for (NSDictionary *foodDic in [dietDic_ objectForKey:@"foodList"]) {
                        NSMutableDictionary *fooDic_ = [foodDic mutableCopy];
                        [fooDic_ eatUnitsFormattingToUserForKey:@"unit"];
                        Food *food = [Food createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [food updateCoreDataForData:fooDic_ withKeyPath:nil];
                        [foodList addObject:food];
                    }
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    recordLog.dietLog = diet;
                    recordLog.userid = userID;
                    diet.foodList = foodList;
                }
                
                NSArray *drugLogArr = [responseData objectForKey:@"changeDrugPointList"];
                for (NSDictionary *drugLogDic in drugLogArr)
                {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *drugLogDic_ = [drugLogDic mutableCopy];
                    [drugLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:drugLogDic_ withKeyPath:nil];
                    
                    DrugLog *drug = [DrugLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *drugDic_ = [[drugLogDic objectForKey:@"changeDrugPoint"] mutableCopy];
                
                    [drugDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"medicineTime"];
                    [drugDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [drug updateCoreDataForData:drugDic_ withKeyPath:nil];
                    
                    NSMutableOrderedSet *newMedicineList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    NSMutableOrderedSet *oldMedicineList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    for (NSDictionary *newMedicineDic in [[drugLogDic objectForKey:@"changeDrugPoint"] objectForKey:@"newMedicineList"]) {
                        
                        NSMutableDictionary *newMedicineDic_ = [newMedicineDic mutableCopy];
                        [newMedicineDic_ medicineUnitsFormattingToUserForKey:@"unit"];
                        [newMedicineDic_ medicineUsageFormattingToUserForKey:@"usage"];
                        
                        Medicine *medicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [medicine updateCoreDataForData:newMedicineDic_ withKeyPath:nil];
                        [newMedicineList addObject:medicine];
                    }
                    
                    
                    for (NSDictionary *oldMedicineDic in [[drugLogDic objectForKey:@"changeDrugPoint"] objectForKey:@"oldMedicineList"]) {
                        
                        NSMutableDictionary *oldMedicineDic_ = [oldMedicineDic mutableCopy];
                        [oldMedicineDic_ medicineUnitsFormattingToUserForKey:@"unit"];
                        [oldMedicineDic_ medicineUsageFormattingToUserForKey:@"usage"];
                        
                        Medicine *medicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [medicine updateCoreDataForData:oldMedicineDic_ withKeyPath:nil];
                        [oldMedicineList addObject:medicine];
                    }
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    
                    recordLog.userid = userID;
                    drug.nowMedicineList = newMedicineList;
                    drug.beforeMedicineList = oldMedicineList;
                    recordLog.drugLog = drug;
                    
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                
                if (self.refreshView)
                {
                    [self.refreshView finishLoading];
                }
                
                [self configureFetchController];
                [self reloadAllViews];
                
                [aHud hide:YES];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
    }];
}

#pragma mark - Configuration

- (void )setBarRightItems
{
    
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Table", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonAction:)];
    shareBtn.tag = 11;
    
    UIBarButtonItem *calenderBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonAction:)];
    calenderBtn.tag = 12;
    
    self.navigationItem.rightBarButtonItems = @[shareBtn,calenderBtn];
}

- (void)rightBarButtonAction:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    switch (btn.tag)
    {
        case 11:
        {
            if ([btn.title isEqualToString:NSLocalizedString(@"Line", nil)])
            {
                [btn setTitle:NSLocalizedString(@"Table", nil)];
                self.viewType = GCTypeLine;
            }
            else
            {
                [btn setTitle:NSLocalizedString(@"Line", nil)];
                self.viewType = GCTypeTable;
            }
            [self configureGraphAndTableView];
            break;
        }
        case 12:
        {
            [self socailShare];
            break;
        }
        default:
            break;
    }
    
}

- (void)configureGraph
{
    self.trackerChart.labelFont = [UIFont systemFontOfSize:10.];
    self.trackerChart.colorTop = [UIColor clearColor];
    self.trackerChart.colorBottom = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    self.trackerChart.colorXaxisLabel = [UIColor darkGrayColor];
    self.trackerChart.colorYaxisLabel = [UIColor darkGrayColor];
    self.trackerChart.colorLine = [UIColor colorWithRed:0/255.0 green:116/255.0 blue:217/255.0 alpha:1];
    self.trackerChart.colorPoint = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1];
    self.trackerChart.colorBackgroundPopUplabel = [UIColor clearColor];
    self.trackerChart.widthLine = 1.0;
    self.trackerChart.enableTouchReport = YES;
    self.trackerChart.enablePopUpReport = YES;
    self.trackerChart.enableBezierCurve = NO;
    self.trackerChart.enableYAxisLabel = YES;
    self.trackerChart.enableXAxisLabel = YES;
    self.trackerChart.autoScaleYAxis = YES;
    self.trackerChart.alwaysDisplayDots = YES;
    self.trackerChart.sizePoint = 20;
    //    self.trackerChart.alwaysDisplayPopUpLabels = YES;
    self.trackerChart.enableReferenceXAxisLines = YES;
    self.trackerChart.enableReferenceYAxisLines = YES;
    self.trackerChart.enableReferenceAxisFrame = YES;
    self.trackerChart.animationGraphStyle = BEMLineAnimationDraw;
}

- (void)configureRefreshView
{
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}

#pragma mark - refreshViewDelegate

//- (void)YALRefreshViewDidStartLoading:(YALSunnyRefreshControl *)view
//{
//    [self getDetectionData];
//}.

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self getDetectionData];
}

#pragma mark - trackerChart Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    NSInteger count;
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            count = self.glucoseArray.count;
            break;
        case GCLineTypeHemo:
            count = self.HfetchController.fetchedObjects.count;
            break;
    }
    return count;
}

- (NSDictionary *)lineGraph:(BEMSimpleLineGraphView *)graph valueAndDotTypeForPointAtIndex:(NSInteger)index
{
    RecordLog *recordLog;
    CGFloat pointValue = 0.0;
    GraphDotType dotType = GraphDotTypeDetect;
    
    switch (self.lineType) {
        case GCLineTypeGlucose:
        {
            recordLog = [self.glucoseArray objectAtIndex:index];
            if ([recordLog.logType isEqualToString:@"detect"]) {
                pointValue = recordLog.detectLog.glucose.floatValue;
                dotType = GraphDotTypeDetect;
            }
            if ([recordLog.logType isEqualToString:@"changeDrug"]) {
                pointValue = recordLog.drugLog.glucose.floatValue;
                dotType = GraphDotTypeDrug;
            }
            if ([recordLog.logType isEqualToString:@"dietPoint"]) {
                pointValue = recordLog.dietLog.glucose.floatValue;
                dotType = GraphDotTypeDiet;
            }
            break;
        }
        case GCLineTypeHemo:
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:index];
            pointValue = recordLog.detectLog.hemoglobinef.floatValue;
            dotType = GraphDotTypeDetect;
            break;
    }
    
    NSDictionary *valueAndType = @{@"value":[NSNumber numberWithFloat:pointValue],
                                   @"type":[NSNumber numberWithInteger:dotType]};
    
    return valueAndType;
}

- (GraphSearchMode)searchModeInLineGraph:(BEMSimpleLineGraphView *)graph
{
    
    switch (self.searchMode)
    {
        case GCSearchModeByDay:
            return GraphSearchModeByDay;
        case GCSearchModeByThreeDay:
            return GraphSearchModeByThreeDay;
        case GCSearchModeByWeek:
            return GraphSearchModeByWeek;
        case GCSearchModeByTwoWeek:
            return GraphSearchModeByTwoWeek;
        case GCSearchModeByMonth:
            return GraphSearchModeByMonth;
        case GCSearchModeByTwoMonth:
            return GraphSearchModeByTwoMonth;
        case GCSearchModeByThreeMonth:
            return GraphSearchModeByThreeMonth;
    }
}

- (CGFloat)intervalForSecondInLineGraph:(BEMSimpleLineGraphView *)graph
{
    switch (self.searchMode)
    {
        case GCSearchModeByDay:
            return 1.0/60;
        default:
            return 0.001;
    }
}

- (CGFloat)intervalForDayInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 30;
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            return self.maxValueG;
            break;
        case GCLineTypeHemo:
            return self.maxValueH;
            break;
        default:
            return 10.0;
    }
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
                return self.minValueG;
            break;
        case GCLineTypeHemo:
                return self.minValueH;
            break;
        default:
            return 0.0;
    }
}

#pragma mark - trackerChart Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 0;
}

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    
    CGFloat max = 0.0;
    CGFloat min = 0.0;
    
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
        {
            max = self.maxValueG;
            min = self.minValueG;
        }
            break;
        case GCLineTypeHemo:
        {
            max = self.maxValueH;
            min = self.minValueH;
        }
            break;
    }
    
    NSInteger count;
    if (max == min)
    {
        count = 1;
    }
    else
    {
        count = max - min + 2;
    }
    return count;
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTapPointAtIndex:(NSInteger)index
{
    
    self.infoLabel.text = @"";
    self.infoText.text = @"";
    self.infoUnitLabel.hidden = YES;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];

    RecordLog *recordLog;
    NSString *detailContent = @"";
    
    switch (self.lineType) {
        case GCLineTypeGlucose:
            recordLog = [self.glucoseArray objectAtIndex:index];
            break;
        case GCLineTypeHemo:
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:index];
            break;
    }
    
    if ([recordLog.logType isEqualToString:@"detect"])
    {
        self.infoUnitLabel.hidden = NO;
        self.infoTime.textAlignment = NSTextAlignmentCenter;
        self.infoType.text = NSLocalizedString(@"detect", nil);
        NSString *time = [NSString formattingDate:recordLog.time to:@"yyyy-MM-dd HH:mm"];
        DetectLog *detect = recordLog.detectLog;
        self.infoTime.text = [NSString stringWithFormat:@"%@   %@",time,detect.dataSource];
        
        switch (self.lineType)
        {
            case GCLineTypeGlucose:
                detailContent = [NSString stringWithFormat:@"%.1f",detect.glucose.floatValue];
                self.infoUnitLabel.text = @"mmol/L";
                self.infoLabel.text = detailContent;
                break;
            case GCLineTypeHemo:
                detailContent = [NSString stringWithFormat:@"%.1f", detect.hemoglobinef.floatValue];
                self.infoUnitLabel.text = @"%";
                self.infoLabel.text = detailContent;
            default:
                break;
        }
    }
    if ([recordLog.logType isEqualToString:@"changeDrug"])
    {
        self.infoTime.textAlignment = NSTextAlignmentLeft;
        
        self.infoType.text = NSLocalizedString(@"drug", nil);
        self.infoTime.text = [NSString formattingDate:recordLog.time to:@"yyyy-MM-dd HH:mm"];
        
        DrugLog *drug = recordLog.drugLog;
        NSMutableArray *nowMedicineArr = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *beforeMedicineArr = [NSMutableArray arrayWithCapacity:10];
        
        for (Medicine *medicine in drug.nowMedicineList)
        {
            NSString *aMedicine = [NSString stringWithFormat:@"%@  %@  %@%@",medicine.drug,medicine.usage,medicine.dose,medicine.unit];
            [nowMedicineArr addObject:aMedicine];
        }
        NSString *nowMedicines =[nowMedicineArr componentsJoinedByString:@"\n"];
        NSString *nowMedicineString = [NSString stringWithFormat:@"%@：\n%@\n",NSLocalizedString(@"现用药",nil),nowMedicines];
        
        for (Medicine *medicine in drug.beforeMedicineList)
        {
            NSString *aMedicine = [NSString stringWithFormat:@"%@  %@  %@%@",medicine.drug,medicine.usage,medicine.dose,medicine.unit];
            [beforeMedicineArr addObject:aMedicine];
        }
        NSString *beforeMedicines = [beforeMedicineArr componentsJoinedByString:@"\n"];
        NSString *beforeMedicineString = [NSString stringWithFormat:@"%@：\n%@",NSLocalizedString(@"曾用药",nil),beforeMedicines];
        detailContent = [NSString stringWithFormat:@"%@\n%@",nowMedicineString,beforeMedicineString];
        
        
        
        if (nowMedicines && nowMedicines.length>0)
        {
            
            UIColor *color = [UIColor colorWithRed:18/255.0 green:103/255.0 blue:193/255.0 alpha:1];
            NSAttributedString *attString;
            NSRange nowMedicaineRange = [detailContent rangeOfString:nowMedicines];
            attString = [self configureAttributedString:detailContent range:NSMakeRange(0, detailContent.length) font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]];
            attString = [self configureAttributedString:attString range:nowMedicaineRange font:[UIFont systemFontOfSize:18] color:color];
            
            if (beforeMedicines && beforeMedicines.length>0)
            {
                NSRange beforeMedicaineRange = [detailContent rangeOfString:beforeMedicines];
                attString = [self configureAttributedString:attString range:beforeMedicaineRange font:[UIFont systemFontOfSize:18] color:color];
            }
            
            [self.infoText setAttributedText:attString];
        }
    }
    
    if ([recordLog.logType isEqualToString:@"dietPoint"])
    {
        self.infoTime.textAlignment = NSTextAlignmentLeft;
        
        DietLog *dietLog = recordLog.dietLog;
        self.infoType.text = NSLocalizedString(@"diet", nil);
        NSString *time = [NSString formattingDate:recordLog.time to:@"yyyy-MM-dd HH:mm"];
        self.infoTime.text = [NSString stringWithFormat:@"%@   %@",time,dietLog.eatPeriod];
        
        DietLog *diet = recordLog.dietLog;
        NSMutableArray *foodArr = [NSMutableArray arrayWithCapacity:10];
        for (Food *food in diet.foodList) {
            NSString *aFood = [NSString stringWithFormat:@"%@  %@  %@%@  %.f%@",food.sort,food.food,food.weight,food.unit,food.calorie.floatValue,NSLocalizedString(@"calorie", nil)];
            [foodArr addObject:aFood];
        }
        
        NSString *dietString =[foodArr componentsJoinedByString:@"\n"];
        detailContent = dietString;
        
        
        NSString *calorie = [NSString stringWithFormat:@"%.f",dietLog.calorie.floatValue];
        if (diet.calorie.floatValue != 0)
        {
            detailContent = [detailContent stringByAppendingFormat:@"\n%@%@%@",NSLocalizedString(@"共摄入", nil),calorie,NSLocalizedString(@"calorie", nil)];
        }
        
        if (dietString && dietString.length>0)
        {
            
            UIColor *color = [UIColor colorWithRed:18/255.0 green:103/255.0 blue:193/255.0 alpha:1];
            NSAttributedString *attString;
            NSRange dietStringRange = [detailContent rangeOfString:dietString];
            attString = [self configureAttributedString:detailContent range:NSMakeRange(0, detailContent.length) font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]];
            attString = [self configureAttributedString:attString range:dietStringRange font:[UIFont systemFontOfSize:18] color:color];
            
            NSRange range = [detailContent rangeOfString:NSLocalizedString(@"共摄入", nil)];
            attString = [self configureAttributedString:attString range:NSMakeRange(range.location+range.length, calorie.length) font:[UIFont systemFontOfSize:18] color:color];
            
            [self.infoText setAttributedText:attString];
        }
        
    }
    
    hud.delegate = self;
    hud.customView = self.infoView;
    hud.margin = 0;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
    
}

- (IBAction)confirmBtn:(id)sender
{
    [hud hide:YES];
}

- (NSDate *)currentDateInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.selectedDate;
}

- (NSDate *)lineGraph:(BEMSimpleLineGraphView *)graph dateOnXAxisForIndex:(NSInteger)index
{
    RecordLog *recordLog;
    switch (self.lineType) {
        case GCLineTypeGlucose:
            if (self.GfetchController.fetchedObjects.count == 0) {
                return nil;
            }
            recordLog = [self.glucoseArray objectAtIndex:index];
            break;
        case GCLineTypeHemo:
            if (self.HfetchController.fetchedObjects.count == 0) {
                return nil;
            }
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:index];
            break;
            
    }
    
    return recordLog.time;
}

//- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index
//{
//    if (self.fetchController.fetchedObjects.count == 0) {
//        return @"";
//    }
//
//    RecordLog *recordLog = [self.fetchController.fetchedObjects objectAtIndex:index];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSDate *date = [dateFormatter dateFromString:recordLog.time];
//    [dateFormatter setDateFormat:@"MM/dd HH:mm"];
//    NSString *dateString = [dateFormatter stringFromDate:date] ? [dateFormatter stringFromDate:date] : @"";
//
//    return [dateString stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
//}

- (BOOL)noDataLabelEnableForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return YES;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections;
    switch (self.lineType) {
        case GCLineTypeGlucose:
            if (self.GfetchController.fetchedObjects.count > 0 ) {
                sections = [self.GfetchController.sections count];
            }else{
                sections = 0;
            }
            break;
            
        case GCLineTypeHemo:
            if (self.HfetchController.fetchedObjects.count > 0 ) {
                sections = [self.GfetchController.sections count];
                
            }else{
                sections = 0;
            }
            break;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    switch (self.lineType) {
        case GCLineTypeGlucose:
            rows = self.GfetchController.fetchedObjects.count;
            break;
        case GCLineTypeHemo:
            rows = self.HfetchController.fetchedObjects.count;
            break;
            
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetectCell";
    DetectDataCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureTableView:tableView withCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableView:(UITableView *)tableView withCell:(DetectDataCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RecordLog *recordLog;
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            recordLog = [self.GfetchController.fetchedObjects objectAtIndex:indexPath.row];
            cell.detectValue.text = [NSString stringWithFormat:@"%.1f",recordLog.detectLog.glucose.floatValue];
            break;
        case GCLineTypeHemo:
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:indexPath.row];
            cell.detectValue.text = [NSString stringWithFormat:@"%.1f",recordLog.detectLog.hemoglobinef.floatValue];
            break;
    }
    
    cell.detectDate.text = [NSString formattingDate:recordLog.time to:@"yyyy-MM-dd, EEEE"];
    cell.detectTime.text = [NSString formattingDate:recordLog.time to:@"HH:mm"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




#pragma mark - pickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.trackPeriodArray.count;
}

#pragma mark - pickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.trackPeriodArray objectAtIndex:row];
}

- (IBAction)cancelAndConfirm:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1001:
        {
            [hud hide:YES];
        }
            break;
        case 1002:
        {
            
            switch ([self.myPickerView selectedRowInComponent:0])
            {
                case 0:
                {
                    self.searchMode = GCSearchModeByThreeDay;
                }
                    break;
                case 1:
                {
                    self.searchMode = GCSearchModeByWeek;
                }
                    break;
                case 2:
                {
                    self.searchMode = GCSearchModeByTwoWeek;
                }
                    break;
                case 3:
                {
                    self.searchMode = GCSearchModeByMonth;
                }
                    break;
                case 4:
                {
                    self.searchMode = GCSearchModeByTwoMonth;
                }
                    break;
                case 5:
                {
                    self.searchMode = GCSearchModeByThreeMonth;
                }
                    break;
                default:
                    break;
            }
            
            
            self.selectedDate = [NSDate date];
            
            NSString *title = self.trackPeriodArray[[self.myPickerView selectedRowInComponent:0]];
            [self.dateButton setTitle:title
                             forState:UIControlStateNormal];
            
            [hud hide:NO];
            [self getDetectionData];
        }
    }
}


#pragma mark - Social Share
- (void)socailShare
{
//    CGRect rect = self.navigationController.view.bounds;
//    rect.origin.y += [self statusBarHeight] + 10;
//    
//    UIImage *currentScreen = [self getScreenImage];
//    UIImage *shareImage = [self cutImage:currentScreen rect:rect];
    
    [ShareHelper socailShareWithViewController:self shareText:@"" shareType:SocialShareTypeImage photographView:self.navigationController.view shareToSnsNames:@[UMShareToQQ,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail]];
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
    //    else if (platformName == UMShareToQzone)
    //    {
    //        socialData.extConfig.qzoneData.title = [self configureShareString];
    //        socialData.extConfig.qzoneData.shareText = @"";
    //    }
    else
    {
        socialData.title = @"";
        socialData.shareText = [self configureShareString];
        
        if (platformName == UMShareToSms || platformName == UMShareToEmail)
        {
            socialData.shareText = [[self configureShareString] stringByAppendingString:[NSString stringWithFormat:@"\n%@",UM_REDIRECT_URL]];
        }
    }
}


- (NSString *)configureShareString
{
    
    NSString *dateString = self.dateButton.currentTitle;
    
    if (![dateString isEqualToString:NSLocalizedString(@"Select By Month", nil)])
    {
        dateString = [NSString formattingDateString:dateString From:@"YYYY-MM-dd" to:@"YYYY年MM月dd日"];
    }
    
    NSString *shareString = [NSString stringWithFormat:@"这是我%@的血糖检测结果",dateString];
    
    return shareString;
}


#pragma mark - Others

- (void)calculateMaxAndMinValue
{
    CGFloat minValueG = 10.0;
    CGFloat maxValueG = 0.0;
    CGFloat minValueH = 10.0;
    CGFloat maxValueH = 0.0;
    
    for (RecordLog *recordLog in self.glucoseArray)
    {
        CGFloat gluValue= recordLog.detectLog.glucose.floatValue;
        if (gluValue && gluValue > 0)
        {
            if (gluValue > maxValueG)
            {
                maxValueG = gluValue;
            }
            if (gluValue < minValueG)
            {
                minValueG = gluValue;
            }
        }
    }
    
    
    for (RecordLog *recordLog in self.HfetchController.fetchedObjects)
    {
        CGFloat gluValue = recordLog.detectLog.hemoglobinef.floatValue;
        if (gluValue && gluValue >0)
        {
            
            if (gluValue > maxValueH)
            {
                maxValueH = gluValue;
            }
            if (gluValue < minValueH)
            {
                minValueH = gluValue;
            }
        }
    }
    
    if (maxValueG >(NSInteger)maxValueG) maxValueG++;
    if (maxValueH > (NSInteger)maxValueH) maxValueH++;
    
    self.minValueG = (NSInteger)minValueG;
    self.minValueH = (NSInteger)minValueH;
    self.maxValueG = (NSInteger)maxValueG;
    self.maxValueH = (NSInteger)maxValueH;
}

- (IBAction)detailBtn:(id)sender
{
    [hud hide:YES afterDelay:0.1];
}

- (IBAction)dateButtonEvent:(id)sender {
    [self showDateSelectionVC];
}

- (NSMutableAttributedString *)configureAttributedString:(id)string range:(NSRange)range font:(UIFont *)font color:(UIColor *)color
{
    
    if ([string isKindOfClass:[NSAttributedString class]])
    {
        NSAttributedString *attString = (NSAttributedString *)string;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font} range:range];
        return attributedString;
    }
    else if ([string isKindOfClass:[NSString class]])
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:(NSString *)string];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font} range:range];
        return attributedString;
    }
    else
    {
        return nil;
    }
}




- (void)showDateSelectionVC
{
    [RMDateSelectionViewController setLocalizedTitleForCancelButton:NSLocalizedString(@"Cancel", nil)];
    [RMDateSelectionViewController setLocalizedTitleForNowButton:NSLocalizedString(@"Select Time Span", nil)];
    [RMDateSelectionViewController setLocalizedTitleForSelectButton:NSLocalizedString(@"Select By Day", nil)];
//    [RMDateSelectionViewController setLocalizedTitleForDetailButton:NSLocalizedString(@"Select By Week", nil)];
    
    
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    dateSelectionVC.disableBlurEffects = YES;
    dateSelectionVC.disableBouncingWhenShowing = NO;
    dateSelectionVC.disableMotionEffects = NO;
    dateSelectionVC.blurEffectStyle = UIBlurEffectStyleExtraLight;
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    
    
    if ([DeviceHelper phone])
    {
        [dateSelectionVC show];
    }
    else if ([DeviceHelper pad])
    {
        [dateSelectionVC showFromViewController:self];
    }
}

- (void)dateSelectionViewControllerNowButtonPressed:(RMDateSelectionViewController *)vc
{
//    [vc dismiss];
//    self.searchMode = GCSearchModeByMonth;
//    self.selectedDate = [NSDate date];
//    [self.dateButton setTitle:NSLocalizedString(@"A month earlier", nil)
//                     forState:UIControlStateNormal];
//    
//    [self getDetectionData];
    
    
    
    [vc dismiss];
    
    [self.myPickerView reloadAllComponents];
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.margin = 0;
    hud.customView = self.datePeriodSelectionView;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];

}

- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    
    self.searchMode = GCSearchModeByDay;
    self.selectedDate = aDate;
    [self.dateButton setTitle:[NSString formattingDate:self.selectedDate to:@"yyyy-MM-dd"]
                     forState:UIControlStateNormal];
    
    [self getDetectionData];
}


- (void)dateSelectionViewControllerDetailButtonPressed:(RMDateSelectionViewController *)vc
{
    
    [vc dismiss];
    self.searchMode = GCSearchModeByWeek;
    self.selectedDate = [NSDate date];
    [self.dateButton setTitle:NSLocalizedString(@"Select By Week", nil)
                     forState:UIControlStateNormal];
    
    [self getDetectionData];
}



- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
    if ([item isEqual:[tabBar.items objectAtIndex:0]] ) {
        self.lineType = GCLineTypeGlucose;
        self.unitLabel.text = @"mmol/L";
    }else{
        self.lineType = GCLineTypeHemo;
        self.unitLabel.text = @"%";
    }
    [self reloadAllViews];
    
}

@end
