//
//  RecoveryLogDetailViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-20.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RecoveryLogDetailViewController.h"
#import "BasicCell.h"
#import "FeelingCell.h"
#import "DetectCell.h"
#import "MedicateCell.h"
#import "DietCell.h"
#import "ExerciseCell.h"
#import "LogSectionHeaderView.h"
#import "SwipeView.h"
#import "UtilsMacro.h"
#import "VendorMacro.h"
#import "AppMacro.h"
#import "DeviceHelper.h"

#define NUMBERS @"1234567890."
#define DIET_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"diet.plist"]
#define DIET_RATE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"diet_rate.plist"]
#define EXERCISE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"exercise.plist"]
#define EXERCISE_RATE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"exercise_rate.plist"]
#define INSULIN_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"insulin.plist"]
#define DRUGS_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"drugs.plist"]

static NSString *BasicCellIdentifier = @"BasicCell";
static NSString *FeelingCellIdentifier = @"FeelingCell";
static NSString *DetectCellIdentifier = @"DetectCell";
static NSString *MediacteCellIdentifier = @"MedicateCell";
static NSString *DietCellIdentifier = @"DietCell";
static NSString *ExerciseCellIndentifier = @"ExerciseCell";

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";


#define HEADER_HEIGHT 30



@interface RecoveryLogDetailViewController ()<UITextFieldDelegate,SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, LogSectionHeaderViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate,UIAlertViewDelegate,UMSocialUIDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarVerticalSpace;

@property (strong, nonatomic) UITableView *detectView;
@property (strong, nonatomic) UITableView *drugView;
@property (strong, nonatomic) UITableView *dietView;
@property (strong, nonatomic) UITableView *exerciseView;

@property (strong, nonatomic) UIActionSheet *sheet;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (strong, nonatomic) IBOutlet UIView *pickerViewWrapper;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *fieldLabel;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
//detect
@property (strong, nonatomic) NSMutableArray *feelingArray;
//drug
@property (strong, nonatomic) NSMutableArray *insulinArray;
@property (strong, nonatomic) NSMutableArray *drugsArray;
@property (strong, nonatomic) NSMutableArray *othersArray;
@property (strong, nonatomic) NSMutableArray *medicationData;
@property (strong, nonatomic) NSMutableArray *drugData;
@property (strong, nonatomic) NSMutableArray *insulinData;
//diet
@property (strong, nonatomic) NSMutableArray *dietArray;
@property (strong, nonatomic) NSMutableArray *dietData;
@property (strong, nonatomic) NSDictionary *dietRate;
//exercise
@property (strong, nonatomic) NSMutableArray *exerciseData;
@property (strong, nonatomic) NSMutableArray *exercisePickerData;
@property (strong, nonatomic) NSDictionary *exerciseRate;


@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *remark;
@property (strong, nonatomic) NSString *period;
@property (strong, nonatomic) NSString *gluco;
@property (strong, nonatomic) NSString *hemo;

@property (strong, nonatomic) UIPopoverController *popoverController;

@end

@implementation RecoveryLogDetailViewController
@synthesize popoverController;

- (void)dealloc
{
    [hud removeFromSuperview];
    hud = nil;
}

- (void)dataSetup
{
    self.selectedIndexPath = nil;
    
    switch (self.recoveryLogType) {
        case RecoveryLogTypeDetect:
        {
            if (!self.feelingArray) {
                self.feelingArray = [[NSMutableArray alloc] initWithCapacity:10];
            }
            
            if (self.recoveryLogStatus == RecoveryLogStatusEdit) {
                self.gluco = self.recordLog.detectLog.glucose;
                self.hemo = self.recordLog.detectLog.hemoglobinef;
                NSArray *feeling = [self.recordLog.detectLog.selfSense componentsSeparatedByString:@","];
                [self.feelingArray addObjectsFromArray:feeling];
            }
            
            break;
        }
        case RecoveryLogTypeDrug:
        {
            if (!self.insulinArray) {
                self.insulinArray = [[NSMutableArray alloc] initWithCapacity:10];
            }
            if (!self.drugsArray) {
                self.drugsArray = [[NSMutableArray alloc] initWithCapacity:10];
            }
            if (!self.othersArray) {
                self.othersArray = [[NSMutableArray alloc] initWithCapacity:10];
            }
            
            if (self.recoveryLogStatus == RecoveryLogStatusEdit)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"drugLog = %@ && sort = %@",self.recordLog.drugLog, @"降糖药"];
                [self.drugsArray addObjectsFromArray:[Medicine findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context]];
                
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"drugLog = %@ && sort = %@",self.recordLog.drugLog, @"胰岛素"];
                [self.insulinArray addObjectsFromArray:[Medicine findAllWithPredicate:predicate1 inContext:[CoreDataStack sharedCoreDataStack].context]];
                
                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"drugLog = %@ && sort = %@",self.recordLog.drugLog, @"其他"];
                [self.othersArray addObjectsFromArray:[Medicine findAllWithPredicate:predicate2 inContext:[CoreDataStack sharedCoreDataStack].context]];
            }
            
            [self loadDrugDataSource];
            break;
        }
        case RecoveryLogTypeDiet:
        {
            if (!self.dietArray) {
                self.dietArray = [[NSMutableArray alloc] initWithCapacity:10];
            }
            
            if (self.recoveryLogStatus == RecoveryLogStatusEdit)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dietLog = %@",self.recordLog.dietLog];
                [self.dietArray addObjectsFromArray:[Food findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context]];
            }
            [self loadDietDataSource];
            break;
        }
        case RecoveryLogTypeExercise:
            [self loadExerciseDataSource];
            break;
    }
    
    
}

- (void)loadDrugDataSource
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:INSULIN_PATH]) {
        NSString *insulinPath = [[NSBundle mainBundle] pathForResource:@"Insulin" ofType:@"plist"];
        self.insulinData= [[NSMutableArray alloc] initWithContentsOfFile:insulinPath];
        [self.insulinData writeToFile:INSULIN_PATH atomically:YES];
    }else self.insulinData = [NSMutableArray arrayWithContentsOfFile:INSULIN_PATH];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:DRUGS_PATH]) {
        NSString *drugsPath = [[NSBundle mainBundle] pathForResource:@"Drugs" ofType:@"plist"];
        self.drugData = [[NSMutableArray alloc] initWithContentsOfFile:drugsPath];
        [self.drugData writeToFile:DRUGS_PATH atomically:YES];
    }else self.drugData = [NSMutableArray arrayWithContentsOfFile:DRUGS_PATH];
    
    NSArray *usageArr = @[NSLocalizedString(@"Oral", nil),
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

- (void)loadDietDataSource
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:DIET_PATH]) {
        NSString *foodPath = [[NSBundle mainBundle] pathForResource:@"food" ofType:@"plist"];
        self.dietData = [NSMutableArray arrayWithContentsOfFile:foodPath];
        [self.dietData writeToFile:DIET_PATH atomically:YES];
    }else self.dietData = [NSMutableArray arrayWithContentsOfFile:DIET_PATH];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:DIET_RATE_PATH]) {
        NSString *foodRate = [[NSBundle mainBundle] pathForResource:@"foodRate" ofType:@"plist"];
        self.dietRate = [NSDictionary dictionaryWithContentsOfFile:foodRate];
        [self.dietRate writeToFile:DIET_RATE_PATH atomically:YES];
        
    }else self.dietRate = [NSDictionary dictionaryWithContentsOfFile:DIET_RATE_PATH];
    
}

- (void)loadExerciseDataSource
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:EXERCISE_PATH]) {
        NSString *exercisePath = [[NSBundle mainBundle] pathForResource:@"exercise" ofType:@"plist"];
        self.exerciseData = [NSMutableArray arrayWithContentsOfFile:exercisePath];
        [self.exerciseData writeToFile:EXERCISE_PATH atomically:YES];
    }else self.exerciseData  = [NSMutableArray arrayWithContentsOfFile:EXERCISE_PATH];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:EXERCISE_RATE_PATH]) {
        NSString *ratePath = [[NSBundle mainBundle] pathForResource:@"exerciseRate" ofType:@"plist"];
        self.exerciseRate = [NSDictionary dictionaryWithContentsOfFile:ratePath];
        [self.exerciseRate writeToFile:EXERCISE_RATE_PATH atomically:YES];
    }else self.exerciseRate = [NSDictionary dictionaryWithContentsOfFile:EXERCISE_RATE_PATH];
    
    NSArray *exerciseDefault =@[
                                self.exerciseData,
                                @[@"10",@"15",@"20",@"25",@"30",@"35",@"40",@"45",@"50",@"55",@"60",],
                                @[NSLocalizedString(@"minutes",nil)]];
    
    self.exercisePickerData = [NSMutableArray arrayWithArray:exerciseDefault];
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.recoveryLogStatus)
    {
        case RecoveryLogStatusAdd:
        {
            self.title = NSLocalizedString(@"Add New Recovery Record", nil);
            self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
            [self configureNavigationRightBtnInAddMode];
            break;
        }
        case RecoveryLogStatusEdit:
        {
            self.title = NSLocalizedString(@"Edit Recovery Record", nil);
            self.tabBarVerticalSpace.constant = -49;
            [self configureNavigationRightBtnInEditMode];
            break;
        }
    }
    
    self.swipeView.scrollEnabled = NO;
    
}

- (void)configureNavigationRightBtnInAddMode
{
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
}

- (void)configureNavigationRightBtnInEditMode
{
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    
    
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(socialShare)];
    
    self.navigationItem.rightBarButtonItems = @[saveBtn,shareBtn];
}

- (void)save:(id)sender
{
    [self.view endEditing:YES];
    switch (self.recoveryLogType)
    {
        case RecoveryLogTypeDetect:
        {
            [self editDetectLog];
            break;
        }
        case RecoveryLogTypeDrug:
        {
            [self editDrugLog];
            break;
        }
        case RecoveryLogTypeDiet:
        {
            [self editDietLog];
            break;
        }
            
        case RecoveryLogTypeExercise:
        {
            [self editExerciseLog];
            break;
        }
        default:
            break;
    }
    
}


- (NSDate *)dateFormattingWithString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormatter dateFromString:dateString];
}

- (void)editDetectLog
{
    MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:aHud];
    aHud.delegate = self;
    aHud.labelText = NSLocalizedString(@"Saving Data", nil);
    [aHud show:YES];
    
    if ([self.gluco isEqualToString:@""] && [self.hemo isEqualToString:@""]) {
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"Value cannot be empty", nil);
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    if (![self.gluco isEqualToString:@""] && (self.gluco.floatValue < 3.5f || self.gluco.floatValue > 40.0f))
    {
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"Glucose Value is invalid", nil);
        [aHud show:YES];
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    if (![self.hemo isEqualToString:@""] && (self.hemo.floatValue < 4.0f || self.hemo.floatValue > 30.0f)) {
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"Hemo Value is invalid", nil);
        [aHud show:YES];
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return ;
    }
    
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    dateTime = [NSString formattingDateString:dateTime From:@"yyyy-MM-dd HH:mm" to:@"yyyyMMddHHmmss"];
    
    NSMutableArray *feelingArray_ = [self.feelingArray mutableCopy];
    [feelingArray_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *formattingFeel = [NSString formattingFeeling:(NSString *)obj];
        if (formattingFeel) {
            [feelingArray_ replaceObjectAtIndex:idx withObject:formattingFeel];
        }
        
    }];
    
    NSString *feeling = [feelingArray_ componentsJoinedByString:@","];
    
    __block NSMutableDictionary *parameters = [@{@"method":@"detectLogEdit",
                                                 @"sign":@"sign",
                                                 @"sessionId":[NSString sessionID],
                                                 @"linkManId":[NSString linkmanID],
                                                 @"detectTime":dateTime ? dateTime : @"",
                                                 @"selfSense":feeling ? feeling :@"",
                                                 @"remar":self.remark ? self.remark :@"",
                                                 } mutableCopy];
    
    if (![self.gluco isEqualToString:@""]) {
        [parameters setValue:self.gluco forKey:@"glucose"];
    }
    if (![self.hemo isEqualToString:@""]) {
        [parameters setValue:self.hemo forKey:@"hemoglobinef"];
    }
    
    switch (self.recoveryLogStatus) {
        case RecoveryLogStatusAdd:
        {
            break;
        }
        case RecoveryLogStatusEdit:
        {
            [parameters setValue:self.recordLog.detectLog.detectId forKey:@"detectId"];
            break;
        }
    }
    
    [GCRequest userEditDetectLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        aHud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                
                // CoreData 中数据的更新通知只有对其属性的修改有效，如果是其属性的属性进行修改，则通知会无效化
                [parameters dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"detectTime"];
                DetectLog *detectLog;
                switch (self.recoveryLogStatus) {
                    case RecoveryLogStatusEdit:
                        
                        detectLog = self.recordLog.detectLog;
                        
                        [detectLog updateCoreDataForData:parameters withKeyPath:nil];
                        detectLog.selfSense = [self.feelingArray componentsJoinedByString:@","];
                        
                        
                        self.recordLog.time = parameters[@"detectTime"];
                        self.recordLog.detectLog = detectLog;
                        break;
                    case RecoveryLogStatusAdd:
                    {
                        RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        recordLog.logType = @"detect";
                        recordLog.time = parameters[@"detectTime"] ;
                        recordLog.id = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"detectId"]];
                        
                        UserID *userId = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        userId.userId = [NSString userID];
                        userId.linkManId = [NSString linkmanID];
                        
                        detectLog = [DetectLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [detectLog updateCoreDataForData:parameters withKeyPath:nil];
                        detectLog.selfSense = [self.feelingArray componentsJoinedByString:@","];
                        detectLog.detectId = recordLog.id;
                        detectLog.dataSource = NSLocalizedString(@"others", nil);
                        
                        recordLog.userid = userId;
                        recordLog.detectLog = detectLog;
                        break;
                    }
                        
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                double delayInSeconds = 1.35;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else{
            aHud.labelText = NSLocalizedString(@"Server is busy", nil);
        }
        
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        
    }];
}

- (void)editDrugLog
{
    MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:aHud];
    aHud.delegate = self;
    aHud.labelText = NSLocalizedString(@"Saving Data", nil);
    [aHud show:YES];
    
    if (self.insulinArray.count == 0 && self.drugsArray.count == 0 && self.othersArray.count == 0) {
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"Medication cannot be empty", nil);
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    dateTime = [NSString formattingDateString:dateTime From:@"yyyy-MM-dd HH:mm" to:@"yyyyMMddHHmmss"];
    
    NSMutableArray *medicineList = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableOrderedSet *medicineSet = [[NSMutableOrderedSet alloc] initWithCapacity:10];
    
    [self.insulinArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Medicine *medicine = (Medicine *)obj;
        if ((![medicine.dose boolValue] || !medicine.drug || !medicine.unit || !medicine.usage) || !medicine.sort) {
            return;
        }
        NSString *unit = [NSString formattingUnit:medicine.unit];
        NSString *usage = [NSString formattingUsage:medicine.usage];
        NSNumber *dose = [NSNumber numberWithFloat:medicine.dose.floatValue];
        NSDictionary *medicineDic = @{@"dose":dose,
                                      @"drug":medicine.drug,
                                      @"sort":medicine.sort,
                                      @"unit":unit,
                                      @"usage":usage};
        
        
        if (![medicineList containsObject:medicineDic]) {
            [medicineList addObject:medicineDic];
            [medicineSet addObject:medicine];
        }
    }];
    
    
    
    
    [self.drugsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Medicine *medicine = (Medicine *)obj;
        if (!medicine.dose || !medicine.drug || !medicine.unit || !medicine.usage || !medicine.sort) {
            return;
        }
        NSString *unit = [NSString formattingUnit:medicine.unit];
        NSString *usage = [NSString formattingUsage:medicine.usage];
        NSNumber *dose = [NSNumber numberWithFloat:medicine.dose.floatValue];
        NSDictionary *medicineDic = @{@"dose":dose,
                                      @"drug":medicine.drug,
                                      @"sort":medicine.sort,
                                      @"unit":unit,
                                      @"usage":usage};
        if (![medicineList containsObject:medicineDic]) {
            [medicineList addObject:medicineDic];
            [medicineSet addObject:medicine];
        }
    }];
    
    [self.othersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Medicine *medicine = (Medicine *)obj;
        if (!medicine.dose || !medicine.drug || !medicine.unit || !medicine.usage || !medicine.sort) {
            return;
        }
        NSString *unit = [NSString formattingUnit:medicine.unit];
        NSString *usage = [NSString formattingUsage:medicine.usage];
        NSNumber *dose = [NSNumber numberWithFloat:medicine.dose.floatValue];
        NSDictionary *medicineDic = @{@"dose":dose,
                                      @"drug":medicine.drug,
                                      @"sort":medicine.sort,
                                      @"unit":unit,
                                      @"usage":usage};
        
        if (![medicineList containsObject:medicineDic]) {
            [medicineList addObject:medicineDic];
            [medicineSet addObject:medicine];
        }
    }];
    
    if (medicineList.count == 0) {
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = NSLocalizedString(@"请至少输入一条完整的用药记录", nil);
        [aHud show:YES];
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    NSString *jsonString = [medicineList JSONString];
    
    __block NSMutableDictionary *parameters = [@{@"method":@"drugLogEdit",
                                                 @"sign":@"sign",
                                                 @"sessionId":[NSString sessionID],
                                                 @"linkManId":[NSString linkmanID],
                                                 @"medicineTime":dateTime ? dateTime : @"",
                                                 @"medicineList":jsonString,
                                                 } mutableCopy];
    
    switch (self.recoveryLogStatus) {
        case RecoveryLogStatusEdit:
            [parameters setValue:self.recordLog.drugLog.medicineId forKey:@"medicineId"];
            break;
        case RecoveryLogStatusAdd:
            break;
    }
    
    [GCRequest userEditDrugLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        aHud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                
                switch (self.recoveryLogStatus) {
                    case RecoveryLogStatusEdit:
                    {
                        DrugLog *drugLog;
                        drugLog = self.recordLog.drugLog;
                        drugLog.medicineTime = [self dateFormattingWithString:dateTime];
                        drugLog.medicineList = medicineSet;
                        self.recordLog.drugLog = drugLog;
                        
                        break;
                    }
                    case RecoveryLogStatusAdd:
                    {
                        RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        recordLog.id = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"medicineId"]];
                        recordLog.logType = @"drug";
                        recordLog.time = [self dateFormattingWithString:dateTime];
                        
                        UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        userID.userId = [NSString userID];
                        userID.linkManId = [NSString linkmanID];
                        
                        DrugLog *drugLog = [DrugLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        drugLog.medicineTime = [self dateFormattingWithString:dateTime];
                        drugLog.medicineId = recordLog.id;
                        
                        recordLog.userid = userID;
                        drugLog.medicineList = medicineSet;
                        recordLog.drugLog = drugLog;
                        
                        break;
                    }
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                double delayInSeconds = 1.35;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else{
            aHud.labelText = NSLocalizedString(@"Server is busy", nil);
        }
        
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
    }];
}

- (void)editDietLog
{
    MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:aHud];
    aHud.delegate = self;
    aHud.labelText = NSLocalizedString(@"Saving Data", nil);
    [aHud show:YES];
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    dateTime = [NSString formattingDateString:dateTime From:@"yyyy-MM-dd HH:mm" to:@"yyyyMMddHHmmss"];
    NSString *eatPeriod = [NSString formattingDietPeriod:self.period];
    
    NSMutableArray *foodList = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableOrderedSet *foodSet = [[NSMutableOrderedSet alloc] initWithCapacity:10];
    __block CGFloat calorie;
    [self.dietArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Food *food = (Food *)obj;
        if (!food.calorie || !food.food || !food.sort || !food.unit || !food.weight) {
            return ;
        }
        
        NSString *foodUnit = [NSString formattingFoodUnit:food.unit];
        NSDictionary *foodDic = @{@"calorie":[NSNumber numberWithFloat:food.calorie.floatValue],
                                  @"food":food.food,
                                  @"sort":food.sort,
                                  @"unit":foodUnit,
                                  @"weight":food.weight};
        
        calorie += food.calorie.floatValue;
        if (![foodList containsObject:foodDic]) {
            [foodList addObject:foodDic];
            [foodSet addObject:food];
        }
        
        
    }];
    NSString *sumCalorie = [NSString stringWithFormat:@"%.f",calorie];
    NSString *jsonString = [foodList JSONString];
    
    __block NSMutableDictionary *parameters = [@{@"method":@"dietLogEdit",
                                                 @"sign":@"sign",
                                                 @"sessionId":[NSString sessionID],
                                                 @"linkManId":[NSString linkmanID],
                                                 @"calorie":sumCalorie?sumCalorie :@"",
                                                 @"eatPeriod":eatPeriod ? eatPeriod :@"",
                                                 @"eatTime":dateTime ? dateTime : @"",
                                                 @"foodList":jsonString ? jsonString : @"",
                                                 } mutableCopy];
    
    switch (self.recoveryLogStatus) {
        case RecoveryLogStatusEdit:
        {
            [parameters setValue:self.recordLog.dietLog.eatId forKey:@"eatId"];
            break;
        }
        case RecoveryLogStatusAdd:
            break;
    }
    
    [GCRequest userEditDietLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        aHud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                
                switch (self.recoveryLogStatus) {
                    case RecoveryLogStatusEdit:
                    {
                        DietLog *dietLog = self.recordLog.dietLog;
                        dietLog.calorie = [NSString stringWithFormat:@"%.1f",calorie];
                        dietLog.eatPeriod = self.period;
                        dietLog.eatTime = [self dateFormattingWithString:dateTime];
                        dietLog.foodList = foodSet;
                        
                        
                        self.recordLog.time = [self dateFormattingWithString:dateTime];
                        self.recordLog.dietLog = dietLog;
                        
                        break;
                    }
                    case RecoveryLogStatusAdd:
                    {
                        RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        
                        UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        userID.userId = [NSString userID];
                        userID.linkManId = [NSString linkmanID];
                        
                        DietLog *dietLog = [DietLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        dietLog.eatId = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"eatId"]];
                        dietLog.calorie = [NSString stringWithFormat:@"%.1f",calorie];
                        dietLog.eatPeriod = self.period;
                        dietLog.eatTime = [self dateFormattingWithString:dateTime];
                        dietLog.foodList = foodSet;;
                        
                        
                        recordLog.userid = userID;
                        recordLog.dietLog = dietLog;
                        recordLog.logType = @"diet";
                        recordLog.time = [self dateFormattingWithString:dateTime];
                        recordLog.id = dietLog.eatId;
                        
                        break;
                    }
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                double delayInSeconds = 1.35;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else{
            aHud.labelText = NSLocalizedString(@"Server is busy", nil);
        }
        
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
    }];
    
}

- (void)editExerciseLog
{
    MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:aHud];
    aHud.delegate = self;
    aHud.labelText = NSLocalizedString(@"Saving Data", nil);
    [aHud show:YES];
    
    ExerciseCell *exerciseCell = (ExerciseCell *)[self.exerciseView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    dateTime = [NSString formattingDateString:dateTime From:@"yyyy-MM-dd HH:mm" to:@"yyyyMMddHHmmss"];
    
    NSMutableDictionary *parameters = [@{@"method":@"exerciseLogEdit",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         @"calorie":exerciseCell.calorie.text,
                                         @"duration":exerciseCell.time.text,
                                         @"sportName":exerciseCell.exerciseName.text,
                                         @"sportTime":dateTime ? dateTime : @"",
                                         } mutableCopy];
    
    switch (self.recoveryLogStatus) {
        case RecoveryLogStatusEdit:
        {
            [parameters setValue:self.recordLog.exerciseLog.sportId forKey:@"sportId"];
            break;
        }
        case RecoveryLogStatusAdd:
            break;
    }
    
    [GCRequest userEditExerciseLogWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        aHud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                aHud.labelText = NSLocalizedString(@"Data Updated", nil);
                
                [parameters dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"sportTime"];
                
                switch (self.recoveryLogStatus) {
                    case RecoveryLogStatusEdit:
                    {
                        ExerciseLog *exerciseLog;
                        exerciseLog = self.recordLog.exerciseLog;
                        
                        [exerciseLog updateCoreDataForData:parameters withKeyPath:nil];
                        
                        self.recordLog.time = [self dateFormattingWithString:dateTime];
                        self.recordLog.exerciseLog = exerciseLog;
                        break;
                    }
                    case RecoveryLogStatusAdd:
                    {
                        RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        recordLog.logType = @"exercise";
                        recordLog.time = [self dateFormattingWithString:dateTime] ;
                        recordLog.id = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"sportId"]];
                        
                        UserID *userId = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        userId.userId = [NSString userID];
                        userId.linkManId = [NSString linkmanID];
                        
                        ExerciseLog *exerciseLog = [ExerciseLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [exerciseLog updateCoreDataForData:parameters withKeyPath:nil];
                        exerciseLog.sportId = recordLog.id;
                        
                        recordLog.userid = userId;
                        recordLog.exerciseLog = exerciseLog;
                        break;
                    }
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                double delayInSeconds = 1.35;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                aHud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else{
            aHud.labelText = NSLocalizedString(@"Server is busy", nil);
        }
        [aHud hide:YES afterDelay:HUD_TIME_DELAY];
    }];
    
}
- (void)registerCellAndSectionHeaderViewForTableView
{
    // Cell Registeration
    
    if (self.detectView) {
        [self.detectView registerNib:[UINib nibWithNibName:@"BasicCell" bundle:nil] forCellReuseIdentifier:BasicCellIdentifier];
        [self.detectView registerNib:[UINib nibWithNibName:@"FeelingCell" bundle:nil] forCellReuseIdentifier:FeelingCellIdentifier];
        [self.detectView registerNib:[UINib nibWithNibName:@"DetectCell" bundle:nil] forCellReuseIdentifier:DetectCellIdentifier];
        [self.detectView registerNib:[UINib nibWithNibName:@"LogSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
        
    }
    
    if (self.drugView) {
        [self.drugView registerNib:[UINib nibWithNibName:@"BasicCell" bundle:nil] forCellReuseIdentifier:BasicCellIdentifier];
        [self.drugView registerNib:[UINib nibWithNibName:@"MedicateCell" bundle:nil] forCellReuseIdentifier:MediacteCellIdentifier];
        [self.drugView registerNib:[UINib nibWithNibName:@"LogSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
        
    }
    
    if (self.dietView) {
        [self.dietView registerNib:[UINib nibWithNibName:@"BasicCell" bundle:nil] forCellReuseIdentifier:BasicCellIdentifier];
        [self.dietView registerNib:[UINib nibWithNibName:@"DietCell" bundle:nil] forCellReuseIdentifier:DietCellIdentifier];
        [self.dietView registerNib:[UINib nibWithNibName:@"LogSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
        
    }
    
    if (self.exerciseView) {
        [self.exerciseView registerNib:[UINib nibWithNibName:@"BasicCell" bundle:nil] forCellReuseIdentifier:BasicCellIdentifier];
        [self.exerciseView registerNib:[UINib nibWithNibName:@"ExerciseCell" bundle:nil] forCellReuseIdentifier:ExerciseCellIndentifier];
        [self.exerciseView registerNib:[UINib nibWithNibName:@"LogSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
        
    }
    
}


#pragma mark - Share

- (void)socialShare
{
    [UMSocialSnsService presentSnsIconSheetView:self appKey:nil shareText:nil shareImage:[UIImage imageNamed:@"aboutUs"] shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToTencent,UMShareToQQ,UMShareToQzone,UMShareToSms,UMShareToEmail] delegate:self];
}

//根据用户选择的平台设置标题和内容(部分平台无标题只有内容)
- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    
    NSString *shareString = [self configureShareStringWithType:self.recoveryLogType];
    NSString *title = [self shareTitleStringWithType:self.recoveryLogType];
    NSString *shareURL = [self shareURLStringWithType:self.recoveryLogType];
    
    socialData.shareText = shareString;
    
    
    //有标题和内容
    if (platformName == UMShareToQQ || platformName == UMShareToWechatSession || platformName == UMShareToQzone)
    {
        
        socialData.extConfig.qqData.title = title;
        socialData.extConfig.qzoneData.title = title;
        socialData.extConfig.wechatSessionData.title = title;
        
        socialData.extConfig.qqData.shareText = shareString;
        socialData.extConfig.qzoneData.shareText = shareString;
        socialData.extConfig.wechatSessionData.shareText = shareString;
        
        socialData.extConfig.qqData.url = shareURL;
        socialData.extConfig.qzoneData.url = shareURL;
        socialData.extConfig.wechatSessionData.url = shareURL;
        
        socialData.extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        socialData.extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeNone;
    }
    else if (platformName == UMShareToWechatTimeline)  //只有标题
    {
        
        socialData.extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeNone;
        
        socialData.extConfig.wechatTimelineData.shareText = @"";
        
        title = [title stringByAppendingString:[NSString stringWithFormat:@",%@",shareString]];
        socialData.extConfig.wechatTimelineData.title = title;
        
        socialData.extConfig.wechatTimelineData.url = shareURL;
    }
    else  //只有内容
    {
        
        NSString *shareText = [title stringByAppendingString:[NSString stringWithFormat:@"\n%@",shareString]];
        
        socialData.shareText = shareText;
        
        if (platformName == UMShareToSms || platformName == UMShareToEmail)
        {
            
            socialData.shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"\n%@",UM_REDIRECT_URL]];
        }
    }
    
}

- (NSString *)shareTitleStringWithType:(RecoveryLogType)type
{
    
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",self.date,self.time];
    dateTime = [NSString formattingDateString:dateTime From:@"yyyy-MM-dd HH:mm" to:@"MM-dd HH:mm"];
    
    
    switch (type)
    {
        case RecoveryLogTypeDetect:
        {
            
            
            NSString *title = [NSString stringWithFormat:@"%@的%@%@",
                               dateTime,
                               NSLocalizedString(@"glucose", nil),
                               NSLocalizedString(@"detect", nil),
                               NSLocalizedString(@"Log", nil)];
            
            return title;
        }
            break;
        case RecoveryLogTypeDiet:
        {
            
            DietLog *dietLog = self.recordLog.dietLog;
            
            NSString *eatPeriod = dietLog.eatPeriod;
            if (!eatPeriod || eatPeriod.length<=0)
            {
                eatPeriod = NSLocalizedString(@"eat", nil);
            }
            
            NSString *title = [NSString stringWithFormat:@"我%@的%@%@",
                               dateTime,
                               eatPeriod,
                               NSLocalizedString(@"Log", nil)];
            
            return title;
        }
            break;
        case RecoveryLogTypeDrug:
        {
            
            
            NSString *title = [NSString stringWithFormat:@"我%@的%@%@",
                               dateTime,
                               NSLocalizedString(@"drug", nil),
                               NSLocalizedString(@"Log", nil)];
            
            return title;
        }
            break;
        case RecoveryLogTypeExercise:
        {
            
            
            NSString *title = [NSString stringWithFormat:@"我%@的%@%@",
                               dateTime,
                               NSLocalizedString(@"exercise", nil),
                               NSLocalizedString(@"Log", nil)];
            
            return title;
        }
            break;
        default:
            return @"";
    }
    
}

- (NSString *)configureShareStringWithType:(RecoveryLogType)type
{
    
    switch (type)
    {
        case RecoveryLogTypeDetect:
            return [self detectShareString];
            break;
        case RecoveryLogTypeDiet:
            return [self dietShareString];
            break;
        case RecoveryLogTypeDrug:
            return [self drugShareString];
            break;
        case RecoveryLogTypeExercise:
            return [self exerciseShareString];
            break;
        default:
            return @"";
    }
}

- (NSString *)shareURLStringWithType:(RecoveryLogType)type
{
    NSString *url = [GCSHARE_TEST_URL stringByAppendingFormat:@"getLogDetail?logtype=%@&id=%@&linkManId=%@",self.recordLog.logType,self.recordLog.id,[NSString linkmanID]];
    return url;
}


- (NSString *)detectShareString
{
    
    NSString *shareString;
    
    
    if ( (self.gluco != nil && self.gluco.length>0) && (self.hemo != nil && self.hemo.length>0) )
    {
        shareString = [NSString stringWithFormat:@"%@%@mmol/L,%@%@%%【糖无忌】",
                       NSLocalizedString(@"glucose", nil),
                       self.gluco,
                       NSLocalizedString(@"hemoglobin", nil),
                       self.hemo
                       ];
    }
    else if (self.gluco != nil && self.gluco.length>0)
    {
        shareString = [NSString stringWithFormat:@"%@%@mmol/L【糖无忌】",
                       NSLocalizedString(@"glucose", nil),
                       self.gluco
                       ];
    }
    else if (self.hemo != nil && self.hemo.length>0)
    {
        shareString = [NSString stringWithFormat:@"%@%@mmol/L【糖无忌】",
                       NSLocalizedString(@"hemoglobin", nil),
                       self.hemo
                       ];
    }
    else
    {
        return @"";
    }
    
    return shareString;
}

- (NSString *)dietShareString
{
    
    NSString *shareString = @"";
    
    BOOL haveFood = NO;
    DietLog *dietLog = self.recordLog.dietLog;
    NSDate *eatTime = self.recordLog.time;
    
//    NSString *eatPeriod = dietLog.eatPeriod;
    
    NSMutableArray *foodName = [[NSMutableArray alloc] init];
    for (Food *food in self.dietArray)
    {
        if (food.food && food.food.length>0)
        {
            haveFood = YES;
            [foodName addObject:food.food];
        }
    }
    
    if (eatTime && haveFood)  //时间+餐别+食物
    {
        
        NSString *foodList = [foodName componentsJoinedByString:@"、"];
        
        shareString = [NSString stringWithFormat:@"吃了%@,共%@%@大卡 【糖无忌】",
                       foodList,
                       NSLocalizedString(@"Intaked", nil),
                       dietLog.calorie];
    }
    else  //只有时间
    {
        shareString = [NSString stringWithFormat:@" 【糖无忌】"];
    }
    
    
    
    return shareString;
}

- (NSString *)drugShareString
{
    
    NSString *shareString = @"";
    
    
    
    NSMutableArray *medicineArray = [[NSMutableArray alloc] init];
    
    for (Medicine *medicine in self.insulinArray)
    {
        [medicineArray addObject:medicine];
    }
    for (Medicine *medicine in self.drugsArray)
    {
        [medicineArray addObject:medicine];
    }
    for (Medicine *medicine in self.othersArray)
    {
        [medicineArray addObject:medicine];
    }
    
    
    if (medicineArray && medicineArray.count>0)
    {
        
        NSMutableArray *drugStringArray = [[NSMutableArray alloc] init];
        for (Medicine *medicine in medicineArray)
        {
            
            NSString *usage = medicine.usage;
            
            //胰岛素泵和注射都显示为注射，口服/不服药显示为口服
            if ([usage isEqualToString:NSLocalizedString(@"Oral", nil)])
            {
                usage = @"口服";
            }
            else if ([usage isEqualToString:NSLocalizedString(@"Insulin", nil)])
            {
                usage = NSLocalizedString(@"Injection", nil);
            }
            
            NSString *drugString = [NSString stringWithFormat:@"%@%@%@%@",medicine.drug,usage,medicine.dose,medicine.unit];
            [drugStringArray addObject:drugString];
        }
        
        shareString = [NSString stringWithFormat:@"%@ 【糖无忌】",[drugStringArray componentsJoinedByString:@","]];
    }
    
    
    return shareString;
}

- (NSString *)exerciseShareString
{
    NSString *shareString = @"";
    
    
    ExerciseLog *exerciseLog = self.recordLog.exerciseLog;
    
    if (exerciseLog)
    {
        
        NSString *duration = exerciseLog.duration;
        NSString *exerciseName = exerciseLog.sportName;
        NSString *calorie = exerciseLog.calorie;
        
        shareString = [NSString stringWithFormat:@"%@%@%@,消耗%@大卡 【糖无忌】",
                       exerciseName,
                       duration,
                       NSLocalizedString(@"minutes", nil),
                       calorie];
    }
    
    
    return shareString;
}


#pragma mark - TabbarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self.swipeView scrollToItemAtIndex:[self.tabBar.items indexOfObject:item] duration:0];
}

#pragma mark - SwipeViewDataSource/Delegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.recoveryLogStatus == RecoveryLogStatusAdd ? 4 : 1;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UITableView *itemView;
    NSInteger statusExpression;
    if (self.recoveryLogStatus == RecoveryLogStatusAdd) {
        statusExpression = index;
    }else{
        statusExpression = self.recoveryLogType;
    }
    
    switch (statusExpression)
    {
        case RecoveryLogTypeDetect:
            self.recoveryLogType = RecoveryLogTypeDetect;
            
            if (!self.detectView) {
                self.detectView = [[NSBundle mainBundle] loadNibNamed:@"detect" owner:self options:nil][0];
                self.detectView.tag = RecoveryLogTypeDetect;
                self.detectView.delegate = self;
                self.detectView.dataSource = self;
                [self dataSetup];
                
                
            }
            itemView = self.detectView;
            break;
            
        case RecoveryLogTypeDrug:
            self.recoveryLogType = RecoveryLogTypeDrug;
            
            if (!self.drugView) {
                self.drugView = [[NSBundle mainBundle] loadNibNamed:@"drug" owner:self options:nil][0];
                self.drugView.tag = RecoveryLogTypeDrug;
                self.drugView.delegate = self;
                self.drugView.dataSource = self;
                [self dataSetup];
            }
            itemView  = self.drugView;
            break;
            
        case RecoveryLogTypeDiet:
            self.recoveryLogType = RecoveryLogTypeDiet;
            
            if (!self.dietView) {
                self.dietView = [[NSBundle mainBundle] loadNibNamed:@"diet" owner:self options:nil][0];
                self.dietView.tag = RecoveryLogTypeDiet;
                self.dietView.delegate = self;
                self.dietView.dataSource = self;
                [self dataSetup];
                
            }
            itemView = self.dietView;
            break;
        case RecoveryLogTypeExercise:
            self.recoveryLogType = RecoveryLogTypeExercise;
            
            if (!self.exerciseView) {
                self.exerciseView = [[NSBundle mainBundle] loadNibNamed:@"exercise" owner:self options:nil][0];
                self.exerciseView.tag = RecoveryLogTypeExercise;
                self.exerciseView.delegate = self;
                self.exerciseView.dataSource = self;
                [self dataSetup];
                
            }
            itemView = self.exerciseView;
            break;
    }
    
    
    [self registerCellAndSectionHeaderViewForTableView];
    
    UIView *helperView = [UIView new];
    helperView.backgroundColor = [UIColor clearColor];
    [itemView setTableFooterView:helperView];
    
    
    
    return itemView;
    
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return swipeView.bounds.size;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:swipeView.currentItemIndex];
    self.recoveryLogType = swipeView.currentItemIndex;
}

#pragma mark - TableViewDelegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (tableView.tag) {
        case RecoveryLogTypeDetect:
            return 2;
        case RecoveryLogTypeDrug:
            return 4;
        case RecoveryLogTypeDiet:
            return 2;
        case RecoveryLogTypeExercise:
            return 2;
            
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (tableView.tag) {
        case RecoveryLogTypeDetect:
            switch (section) {
                case 0:
                    count = 5;
                    break;
                case 1:
                    count = 3;
                    break;
                default:
                    break;
            }
            break;
        case RecoveryLogTypeDrug:
            switch (section) {
                case 0:
                    count = 2;
                    break;
                case 1:
                    count = self.insulinArray.count+1;
                    break;
                case 2:
                    count = self.drugsArray.count+1;
                    break;
                case 3:
                    count = self.othersArray.count+1;
                    break;
            }
            break;
        case RecoveryLogTypeDiet:
            if (section == 0) {
                count =  3;
            } else {
                count = self.dietArray.count+1;
            };
            break;
        case RecoveryLogTypeExercise:
            if (section == 0) {
                count = 2;
            } else {
                count = 2;
            }
            break;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    else return HEADER_HEIGHT;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
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
    switch (tableView.tag) {
        case RecoveryLogTypeDetect:
            if (section == 1) {
                headerView.titleLabel.text = NSLocalizedString(@"Detection Result",nil);
                headerView.addBtn.hidden = YES;
            }
            break;
        case RecoveryLogTypeDrug:
            if (section == 1) {
                headerView.titleLabel.text = NSLocalizedString(@"Glucose", nil);
            }
            if (section == 2) {
                headerView.titleLabel.text = NSLocalizedString(@"Hemoglobin", nil);
            }
            if (section == 3) {
                headerView.titleLabel.text = NSLocalizedString(@"Others", nil);
            }
            break;
        case RecoveryLogTypeDiet:
            if (section == 1) {
                headerView.titleLabel.text = NSLocalizedString(@"Food Intaked", nil);
            }
            break;
        case RecoveryLogTypeExercise:
            if (section == 1) {
                headerView.titleLabel.text = NSLocalizedString(@"Exercise Data", nil);
                headerView.addBtn.hidden = YES;
            }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    cellHeight = 44;
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (tableView.tag) {
            
        case RecoveryLogTypeDetect:
        {
            if (indexPath.section == 0) {
                
                if (indexPath.row == 3) {
                    FeelingCell *cell = [tableView dequeueReusableCellWithIdentifier:FeelingCellIdentifier forIndexPath:indexPath];
                    [self configureTableView:tableView withFeelingCell:cell atIndexPath:indexPath];
                    return cell;
                }
                BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
                [self configureTableView:tableView withBasicCell:cell atIndexPath:indexPath];
                return cell;
                
            }
            else{
                DetectCell *cell = [tableView dequeueReusableCellWithIdentifier:DetectCellIdentifier forIndexPath:indexPath];
                [self configureTableView:tableView withDetectCell:cell atIndexPath:indexPath];
                return cell;
            }
            
            break;
        }
            
        case RecoveryLogTypeDrug:
        {
            if (indexPath.section == 0) {
                BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
                [self configureTableView:tableView withBasicCell:cell atIndexPath:indexPath];
                return cell;
            }
            else {
                MedicateCell *cell = [tableView dequeueReusableCellWithIdentifier:MediacteCellIdentifier forIndexPath:indexPath];
                [self configureTableView:tableView withMedicateCell:cell atIndexPath:indexPath];
                return cell;
                
            }
            
            break;
        }
            
        case RecoveryLogTypeDiet:
        {
            switch (indexPath.section) {
                case 0:
                {
                    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
                    [self configureTableView:tableView withBasicCell:cell atIndexPath:indexPath];
                    return cell;
                    break;
                }
                    
                case 1:
                {
                    DietCell *cell = [tableView dequeueReusableCellWithIdentifier:DietCellIdentifier forIndexPath:indexPath];
                    [self configureTableView:tableView withDietCell:cell atIndexPath:indexPath];
                    return cell;
                    break;
                }
            }
            
            break;
        }
            
        case RecoveryLogTypeExercise:
        {
            switch (indexPath.section) {
                    
                case 0:
                {
                    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
                    [self configureTableView:tableView withBasicCell:cell atIndexPath:indexPath];
                    return cell;
                    break;
                }
                case 1:
                {
                    ExerciseCell *cell = [tableView dequeueReusableCellWithIdentifier:ExerciseCellIndentifier forIndexPath:indexPath];
                    [self configureTableView:tableView withExerciseCell:cell atIndexPath:indexPath];
                    return cell;
                    break;
                }
            }
            
        }
    }
    
    return nil;
    
}

- (void)configureTableView:(UITableView *)tableView withFeelingCell:(FeelingCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.title.text = NSLocalizedString(@"Feeling", nil);
    cell.selectedArray = self.feelingArray;
    [cell initialSelectedBtn];
    cell.selectedFeelingBlock = ^void (NSMutableArray *selecteArray){
        self.feelingArray = selecteArray;
    };
}

- (void)configureTableView:(UITableView *)tableView withDetectCell:(DetectCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detectType.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectUnit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectType.text = NSLocalizedString(@"Detection Type", nil);
        cell.detectField.text = NSLocalizedString(@"Detection Value", nil);
        cell.detectUnit.text = NSLocalizedString(@"Unit", nil);
    }
    
    if (indexPath.row == 1) {
        
        cell.detectType.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectUnit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        
        if ([self.recordLog.detectLog.dataSource isEqualToString:@"GlucoTrack"]) {
            cell.detectField.userInteractionEnabled = NO;
        }else{
            cell.detectField.userInteractionEnabled = YES;
        }
        cell.detectField.logFieldIdentify = @"glucose";
        cell.detectField.logIndexPath = indexPath;
        cell.detectField.delegate = self;
        cell.detectType.text = NSLocalizedString(@"glucose", nil);
        cell.detectUnit.text = NSLocalizedString(@"mmol/L", nil);
        if (self.recordLog.detectLog.glucose) {
            cell.detectField.text = [NSString stringWithFormat:@"%.1f",self.recordLog.detectLog.glucose.floatValue];
        }
        self.gluco = cell.detectField.text;
        cell.detectField.placeholder = NSLocalizedString(@"Input Detect Value", nil);
    }
    if (indexPath.row == 2) {
        
        cell.detectType.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.detectUnit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        
        if ([self.recordLog.detectLog.dataSource isEqualToString:@"GlucoTrack"]) {
            cell.detectField.userInteractionEnabled = NO;
        }else{
            cell.detectField.userInteractionEnabled = YES;
        }
        cell.detectField.logFieldIdentify = @"hemoglobinef";
        cell.detectField.logIndexPath = indexPath;
        cell.detectField.delegate = self;
        cell.detectType.text = NSLocalizedString(@"hemoglobin", nil);
        cell.detectUnit.text = NSLocalizedString(@"%", nil);
        if (self.recordLog.detectLog.hemoglobinef) {
            cell.detectField.text = [NSString stringWithFormat:@"%.1f",self.recordLog.detectLog.hemoglobinef.floatValue];
        }
        self.hemo = cell.detectField.text;
        cell.detectField.placeholder = NSLocalizedString(@"Input Detect Value", nil);
    }
    
    
}

- (void)configureTableView:(UITableView *)tableView withMedicateCell:(MedicateCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.drugField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.usageField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.dosageField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.unitField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    
    
    if (!indexPath.row == 0) {
        cell.drugField.placeholder = NSLocalizedString(@"Medication Name", nil);
        cell.usageField.placeholder = NSLocalizedString(@"Usage", nil);
        cell.dosageField.placeholder = NSLocalizedString(@"Dosage", nil);
        cell.unitField.placeholder = NSLocalizedString(@"Unit", nil);
        
        cell.dosageField.userInteractionEnabled = YES;
        cell.dosageField.delegate = self;
        cell.dosageField.logIndexPath = indexPath;
        cell.dosageField.logFieldIdentify = @"dosage";
        
        Medicine *medicine;
        
        switch (indexPath.section) {
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
        
        if ([medicine isKindOfClass:[Medicine class]]) {
            cell.drugField.text = medicine.drug;
            cell.usageField.text = medicine.usage;
            cell.dosageField.text = medicine.dose;
            cell.unitField.text = medicine.unit;
        }
        
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.drugField.text = NSLocalizedString(@"Medication Name", nil);
        cell.usageField.text = NSLocalizedString(@"Usage", nil);
        cell.dosageField.text = NSLocalizedString(@"Dosage", nil);
        cell.unitField.text = NSLocalizedString(@"Unit", nil);
    }
    
    
}

- (void)configureTableView:(UITableView *)tableView withDietCell:(DietCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row == 0) {
        
        cell.food.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.weight.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.unit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.calorie.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        
        cell.food.placeholder = NSLocalizedString(@"Food Name", nil);
        cell.weight.placeholder = NSLocalizedString(@"Intaked Value", nil);
        cell.unit.placeholder = NSLocalizedString(@"Unit", nil);
        cell.calorie.placeholder = NSLocalizedString(@"Calorie Intaked", nil);
        
        cell.weight.delegate = self;
        cell.weight.logIndexPath = indexPath;
        cell.weight.logFieldIdentify = @"weight";
        cell.weight.userInteractionEnabled = YES;
        
        cell.calorie.delegate = self;
        cell.calorie.logIndexPath = indexPath;
        cell.calorie.logFieldIdentify = @"calorie";
        cell.calorie.userInteractionEnabled = YES;
        
        Food *food;
        food = self.dietArray[indexPath.row-1];
        
        if ([food isKindOfClass:[food class]]) {
            cell.food.text = food.food;
            cell.weight.text = food.weight;
            cell.unit.text = food.unit;
            cell.calorie.text = food.calorie ? [NSString stringWithFormat:@"%.f",food.calorie.floatValue]: food.calorie ;
        }
    }else{
        
        cell.food.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.weight.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.unit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.calorie.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.food.text = NSLocalizedString(@"Food Name", nil);
        cell.weight.text = NSLocalizedString(@"Intaked Value", nil);
        cell.unit.text = NSLocalizedString(@"Unit", nil);
        cell.calorie.text = NSLocalizedString(@"Calorie Intaked", nil);
    }
    
}

- (void)configureTableView:(UITableView *)tableView withExerciseCell:(ExerciseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        cell.exerciseName.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.time.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.unit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.calorie.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        
        
        cell.exerciseName.placeholder = NSLocalizedString(@"Sport Name", nil);
        cell.time.placeholder = NSLocalizedString(@"Sport Time", nil);
        cell.unit.placeholder = NSLocalizedString(@"Unit", nil);
        cell.calorie.placeholder = NSLocalizedString(@"Calorie Outtaked", nil);
        
        cell.time.delegate = self;
        cell.time.logIndexPath = indexPath;
        cell.time.logFieldIdentify = @"time";
        cell.time.userInteractionEnabled = YES;
        
        cell.calorie.delegate = self;
        cell.calorie.logIndexPath = indexPath;
        cell.calorie.logFieldIdentify = @"exerciseCalorie";
        cell.calorie.userInteractionEnabled = YES;
        
        
        if (self.recordLog) {
            cell.exerciseName.text = self.recordLog.exerciseLog.sportName;
            cell.time.text = self.recordLog.exerciseLog.duration;
            cell.unit.text = NSLocalizedString(@"min", nil);
            cell.calorie.text = self.recordLog.exerciseLog.calorie ? [NSString stringWithFormat:@"%.f",self.recordLog.exerciseLog.calorie.floatValue]: nil;
        }
        
    }else{
        
        cell.exerciseName.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.time.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.unit.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        cell.calorie.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.exerciseName.text = NSLocalizedString(@"Enter Name", nil);
        cell.time.text = NSLocalizedString(@"Enter Time", nil);
        cell.unit.text = NSLocalizedString(@"Unit", nil);
        cell.calorie.text = NSLocalizedString(@"Calorie Outtaked", nil);
    }
    
}

- (void)configureTableView:(UITableView *)tableView withBasicCell:(BasicCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString = [NSString formattingDate:self.recordLog.time to:@"yyyy-MM-dd"];
    NSString *timeString =  [NSString formattingDate:self.recordLog.time to:@"HH:mm"];
    
    
    if (!dateString || !timeString) {
        NSDate *nowDate = [NSDate date];
        dateString  = [NSString formattingDate:nowDate to:@"yyyy-MM-dd"];
        timeString = [NSString formattingDate:nowDate to:@"HH:mm"];
    }
   
    CGFloat fontSize = [DeviceHelper normalFontSize];
    cell.detailText.font = [UIFont systemFontOfSize:fontSize];
    
    switch (tableView.tag) {
            
        case RecoveryLogTypeDetect:
            
            if ([self.recordLog.detectLog.dataSource isEqualToString:@"GlucoTrack"]) {
                cell.userInteractionEnabled = NO;
            }
            
            switch (indexPath.row) {
                case 0:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.title.text = NSLocalizedString(@"Detection Equipment",nil);
                    cell.detailText.text = self.recordLog.detectLog.dataSource?self.recordLog.detectLog.dataSource:NSLocalizedString(@"others", nil);
                    break;
                case 1:
                {
                    cell.title.text = NSLocalizedString(@"Detection Date",nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Date", nil);
                    
                    if (self.date) {
                        cell.detailText.text = self.date;
                    }else{
                        cell.detailText.text = dateString;
                        self.date = dateString;
                    }
                    
                    break;
                }
                case 2:
                {
                    cell.title.text = NSLocalizedString(@"Detection Time", nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Time",nil);
                    if (self.time) {
                        cell.detailText.text = self.time;
                    }else{
                        cell.detailText.text = timeString;
                        self.time = timeString;
                    }
                
                    break;
                }
                case 4:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInteractionEnabled = YES;
                    cell.detailText.delegate = self;
                    cell.detailText.logIndexPath = indexPath;
                    cell.detailText.logFieldIdentify = @"remark";
                    cell.title.text = NSLocalizedString(@"Add Remark", nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Options", nil);
                    cell.detailText.text = self.recordLog.detectLog.remar;
                    self.remark = self.recordLog.detectLog.remar;
                    cell.detailText.enabled = YES;
                    break;
                default:
                    break;
            }
            break;
        case RecoveryLogTypeDrug:
            switch (indexPath.row) {
                case 0:
                    cell.title.text = NSLocalizedString(@"Medication Date",nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Date", nil);
                    if (self.date) {
                        cell.detailText.text = self.date;
                    }else{
                        cell.detailText.text = dateString;
                        self.date = dateString;
                    }
                    
                    break;
                case 1:
                    cell.title.text = NSLocalizedString(@"Medication Time", nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Time",nil);
                    if (self.time) {
                        cell.detailText.text = self.time;
                    }else{
                        cell.detailText.text = timeString;
                        self.time = timeString;
                    }
                    
                    break;
                default:
                    break;
            }
            break;
        case RecoveryLogTypeDiet:
            switch (indexPath.row) {
                case 0:
                    cell.title.text = NSLocalizedString(@"Diet Date",nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Date", nil);
                    if (self.date) {
                        cell.detailText.text = self.date;
                    }else{
                        cell.detailText.text = dateString;
                        self.date = dateString;
                    }
                    
                    break;
                case 1:
                    cell.title.text = NSLocalizedString(@"Diet Time", nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Time",nil);
                    if (self.time) {
                        cell.detailText.text = self.time;
                    }else{
                        cell.detailText.text = timeString;
                        self.time = timeString;
                    }
                    
                    break;
                case 2:
                    cell.title.text = NSLocalizedString(@"Diet Category", nil);
                    cell.detailText.text = self.recordLog.dietLog.eatPeriod;
                    self.period = self.recordLog.dietLog.eatPeriod;
                    cell.detailText.placeholder = NSLocalizedString(@"Select Diet Time", nil);
                    break;
                default:
                    break;
            }
            break;
        case RecoveryLogTypeExercise:
            switch (indexPath.row) {
                case 0:
                    cell.title.text = NSLocalizedString(@"Exercise Date",nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Date", nil);
                    if (self.date) {
                        cell.detailText.text = self.date;
                    }else{
                        cell.detailText.text = dateString;
                        self.date = dateString;
                    }
                    
                    break;
                case 1:
                    cell.title.text = NSLocalizedString(@"Start Time", nil);
                    cell.detailText.placeholder = NSLocalizedString(@"Select Time",nil);
                    if (self.time) {
                        cell.detailText.text = self.time;
                    }else{
                        cell.detailText.text = timeString;
                        self.time = timeString;
                    }
                    
                    break;
                default:
                    break;
            }
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // !important. Repoint to the current tableview
    self.selectedIndexPath = indexPath;
    
    switch (tableView.tag) {
        case RecoveryLogTypeDetect:
            switch (indexPath.section) {
                case 0:
                    switch (indexPath.row) {
                        case 0:
                            break;
                        case 1:
                            [self showDatePickerHUDWithMode:UIDatePickerModeDate];
                            break;
                        case 2:
                            [self showDatePickerHUDWithMode:UIDatePickerModeTime];
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                    if (indexPath.row == 0) {
                        return;
                    }
                    
                    
                default:
                    break;
            }
            
            break;
        case RecoveryLogTypeDrug:
            switch (indexPath.section) {
                case 0:
                    switch (indexPath.row) {
                        case 0:
                            [self showDatePickerHUDWithMode:UIDatePickerModeDate];
                            break;
                        case 1:
                            [self showDatePickerHUDWithMode:UIDatePickerModeTime];
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                case 2:
                case 3:
                    if (indexPath.row == 0) {
                        return;
                    }
                    
                    [self showPickerViewHUD];
                    [self.pickerView reloadAllComponents];
                    break;
                default:
                    break;
            }
            break;
            
        case RecoveryLogTypeDiet:
            switch (indexPath.section) {
                case 0:
                    switch (indexPath.row) {
                        case 0:
                            [self showDatePickerHUDWithMode:UIDatePickerModeDate];
                            break;
                        case 1:
                            [self showDatePickerHUDWithMode:UIDatePickerModeTime];
                            break;
                        case 2:
                            self.sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Diet Category",nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:
                                          NSLocalizedString(@"breakfast", nil) ,
                                          NSLocalizedString(@"lunch",nil),
                                          NSLocalizedString(@"dinner",nil),
                                          NSLocalizedString(@"snack",nil),nil];
                            [self.sheet showInView:self.view];
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                    if (indexPath.row == 0) {
                        return;
                    }
                    [self showPickerViewHUD];
                    [self.pickerView selectRow:0 inComponent:0 animated:NO];
                    [self.pickerView reloadAllComponents];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case RecoveryLogTypeExercise:
            switch (indexPath.section) {
                case 0:
                    switch (indexPath.row) {
                        case 0:
                            [self showDatePickerHUDWithMode:UIDatePickerModeDate];
                            break;
                        case 1:
                            [self showDatePickerHUDWithMode:UIDatePickerModeTime];
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                    if (indexPath.row == 0) {
                        return;
                    }
                    [self showPickerViewHUD];
                    [self.pickerView reloadAllComponents];
                    break;
                default:
                    break;
            }
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == RecoveryLogTypeDetect || tableView.tag == RecoveryLogTypeExercise || indexPath.section == 0 || indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[MedicateCell class]]){
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
        }else if ([cell isKindOfClass:[DietCell class]]) {
            switch (indexPath.section) {
                case 1:
                    [self.dietArray removeObjectAtIndex:indexPath.row-1];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    break;
                    
                default:
                    break;
            }
        }
    }
}



#pragma mark - LogSectionHeaderViewDelegate

- (void)LogSectionHeaderView:(LogSectionHeaderView *)headerView sectionToggleAdd:(NSInteger)section
{
    switch (self.recoveryLogType){
        case RecoveryLogTypeDrug:
            switch (headerView.section) {
                case 1:
                {
                    NSInteger insertRow = self.insulinArray.count + 1;
                    if ([self allowToAdd:insertRow]) {
                        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:headerView.section];
                        
                        Medicine *insertMedicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        insertMedicine.sort = @"胰岛素";
                        
                        [self.insulinArray addObject:insertMedicine];
                        [self.drugView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                        [self.drugView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                        [self.drugView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                    break;
                }
                    
            }
            
            break;
            
        case RecoveryLogTypeDiet:
            switch (headerView.section) {
                case 1:
                {
                    NSInteger insertRow = self.dietArray.count + 1;
                    if ([self allowToAdd:insertRow]) {
                        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:headerView.section];
                        Food *insertFood = [Food createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [self.dietArray addObject:insertFood];
                        [self.dietView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                    break;
                }
            }
            break;
        default:
            break;
    }
    
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

#pragma mark - DatePickerHUD

- (void)showDatePickerHUDWithMode:(UIDatePickerMode )mode
{
    
    self.datePicker.datePickerMode = mode;
    
    if ([DeviceHelper phone])
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.margin = 0;
        hud.delegate = self;
        hud.customView = self.datePickerView;
        hud.mode = MBProgressHUDModeCustomView;
        [hud show:YES];
    }
    else
    {
        NSInteger cellRow;
        if (mode == UIDatePickerModeDate) cellRow = 1;
        else cellRow = 2;
        if (self.swipeView.currentPage == 0)
        {
            cellRow ++;
        }
        
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:NO];
            self.popoverController = nil;
        }
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        popoverContent.view = self.datePickerView;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.popoverContentSize = self.datePickerView.bounds.size;
        [self.popoverController presentPopoverFromRect:CGRectMake(130,15+44* ++cellRow, 0, 0)
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
        
    }

}

#pragma mark - PickerViewHUD

- (void)showPickerViewHUD
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.margin = 0;
    hud.customView = self.pickerViewWrapper;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
    
}

- (IBAction)pickerViewAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1001:
        {
            
            switch (self.recoveryLogType) {
                case RecoveryLogTypeDetect:
                    break;
                case RecoveryLogTypeDrug:
                {
                    if (self.selectedIndexPath.section == 3) {
                        UILabel *usage = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
                        UILabel *unit = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1];
                        Medicine *medicine = self.othersArray[self.selectedIndexPath.row-1];
                        medicine.sort = @"其他";
                        medicine.unit = unit.text;
                        medicine.usage = usage.text;
                    }else{
                        
                        UILabel *drug = (UILabel*)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
                        UILabel *usage = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1];
                        UILabel *unit = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:2] forComponent:2];
                        
                        
                        Medicine *medicine;
                        if (self.selectedIndexPath.section == 1) {
                            medicine = self.insulinArray[self.selectedIndexPath.row-1];
                            medicine.sort = @"胰岛素";
                        }
                        if (self.selectedIndexPath.section == 2) {
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
                    
                    
                    [self.drugView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    break;
                }
                case RecoveryLogTypeDiet:
                {
                    UILabel *category = (UILabel*)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
                    UILabel *foodName = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1];
                    UILabel *unit = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:2] forComponent:2];
                    
                    Food *food = self.dietArray[self.selectedIndexPath.row-1];
                    food.sort = category.text;
                    food.food = foodName.text;
                    food.weight = @"100";
                    food.unit = unit.text;
                    
                    NSString *rate = [self.dietRate valueForKey:food.food];
                    food.calorie = [NSString stringWithFormat:@"%.1f",rate.floatValue * 100];
                    
                    if ([food.food isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Food Name", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        
                        UITextField *tf = [alertView textFieldAtIndex:0];
                        tf.keyboardType = UIKeyboardTypeDefault;
                        [alertView show];
                        [hud hide:YES];
                        return;
                    }
                    
                    [self.dietView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    break;
                }
                case RecoveryLogTypeExercise:
                {
                    UILabel *sportName = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
                    UILabel *time = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1];
                    UILabel *unit = (UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:2] forComponent:2];
                    
                    ExerciseCell *exerciseCell = (ExerciseCell *)[self.exerciseView cellForRowAtIndexPath:self.selectedIndexPath];
                    exerciseCell.exerciseName.text = sportName.text;
                    exerciseCell.time.text = time.text;
                    exerciseCell.unit.text = unit.text;
                    
                    NSString *rate = [self.exerciseRate valueForKey:sportName.text];
                    exerciseCell.calorie.text = [NSString stringWithFormat:@"%.f",rate.floatValue * time.text.integerValue];
                    
                    
                    
                    if ([sportName.text isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Exercise Name", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        
                        UITextField *tf = [alertView textFieldAtIndex:0];
                        tf.keyboardType = UIKeyboardTypeDefault;
                        
                        [alertView show];
                        [hud hide:YES];
                        return;
                        
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 1000:
            break;
    }
    
    [hud hide:YES afterDelay:0.25];
}

#pragma mark - PickerViewDataSource/Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger components = 0;
    
    switch (self.recoveryLogType) {
            
        case RecoveryLogTypeDrug:
            switch (self.selectedIndexPath.section) {
                case 1:
                case 2:
                    components = self.medicationData.count;
                    break;
                case 3:
                    components = 2;
                    break;
            }
            break;
        case RecoveryLogTypeDiet:
            switch (self.selectedIndexPath.section) {
                case 1:
                    components = 3;
                    break;
                    
                default:
                    break;
            }
            break;
        case RecoveryLogTypeExercise:
            switch (self.selectedIndexPath.section) {
                case 1:
                    components = self.exercisePickerData.count;
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return components;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    switch (self.recoveryLogType) {
            
        case RecoveryLogTypeDrug:
            switch (self.selectedIndexPath.section) {
                case 1:
                    if (component == 0) {
                        rows = [self.medicationData[component][@"01"] count];
                    }else rows = [self.medicationData[component] count];
                    break;
                case 2:
                    if (component == 0) {
                        rows = [self.medicationData[component][@"02"] count];
                    }else rows = [self.medicationData[component] count];
                    break;
                case 3:
                    rows = [self.medicationData[component+1] count];
                    break;
            }
            break;
        case RecoveryLogTypeDiet:
            switch (self.selectedIndexPath.section) {
                case 1:
                    if (component == 0) {
                        rows = [self.dietData count];
                    }
                    if (component == 1) {
                        NSInteger row = [pickerView selectedRowInComponent:0];
                        rows = [[self.dietData[row] allValues][0] count];
                        
                    }
                    if (component == 2) {
                        rows = 1;
                    }
                    
                    break;
                    
                default:
                    break;
            }
            break;
        case RecoveryLogTypeExercise:
            switch (self.selectedIndexPath.section) {
                case 1:
                    rows = [self.exercisePickerData[component] count];
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return rows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:[DeviceHelper biggestFontSize] +2];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    
    switch (self.recoveryLogType) {
            
        case RecoveryLogTypeDrug:
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
            break;
        case RecoveryLogTypeDiet:
            switch (self.selectedIndexPath.section) {
                case 1:
                {
                    if (component == 0) {
                        titleLabel.text = [self.dietData[row] allKeys][0];
                    }
                    if (component == 1) {
                        NSInteger selectedRow = [pickerView selectedRowInComponent:0];
                        NSArray *foods = [self.dietData[selectedRow] allValues][0];
                        titleLabel.text = foods[row];
                        if ([titleLabel.text isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                            titleLabel.textColor = [UIColor orangeColor];
                        }
                    }
                    
                    if (component == 2) {
                        if (row == 0) {
                            titleLabel.text = NSLocalizedString(@"g", nil);
                        }
                        
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        case RecoveryLogTypeExercise:
            switch (self.selectedIndexPath.section) {
                case 1:
                {
                    if (component == 0) {
                        titleLabel.text = self.exercisePickerData[component][row];
                        if ([titleLabel.text isEqualToString:NSLocalizedString(@"Custom", nil)]) {
                            titleLabel.textColor = [UIColor orangeColor];
                        }
                    }else{
                        titleLabel.text = self.exercisePickerData[component][row];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return titleLabel
    ;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.recoveryLogType)
    {
        case RecoveryLogTypeDiet:
        {
            switch (self.selectedIndexPath.section) {
                case 1:
                {
                    if (component == 0)
                    {
                        [pickerView reloadComponent:1];
//                        UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
//                        [label setTextColor:[UIColor orangeColor]];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat widthForComponent;
    if (component == 0)
    {
        widthForComponent = 110;
    }
    else widthForComponent = 90;
    
    return widthForComponent;
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0)
    {
        
        UITextField *tf = [alertView textFieldAtIndex:0];
        if ([tf.text isEqualToString:@""]) {
            MBProgressHUD *aHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:aHud];
            aHud.mode = MBProgressHUDModeText;
            aHud.delegate = self;
            aHud.labelText = NSLocalizedString(@"请输入药物名称", nil);
            [aHud show:YES];
            [aHud hide:YES afterDelay:HUD_TIME_DELAY];
            return;
        }
        
        switch (self.recoveryLogType) {
            case RecoveryLogTypeDetect:
                break;
            case RecoveryLogTypeDrug:
            {
                
                switch (self.selectedIndexPath.section) {
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
                [self.drugView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case RecoveryLogTypeDiet:
            {
                Food *food = [self.dietArray objectAtIndex:self.selectedIndexPath.row-1];
                food.food = tf.text;
                food.calorie = nil;
                
                [[[self.dietData lastObject] allValues][0] addObject:food.food];
                [self.dietData writeToFile:DIET_PATH atomically:YES];
                
                [self.dietView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case RecoveryLogTypeExercise:
            {
                ExerciseCell *exerciseCell = (ExerciseCell *)[self.exerciseView cellForRowAtIndexPath:self.selectedIndexPath];
                exerciseCell.exerciseName.text = tf.text;
                
                [self.exerciseData addObject:tf.text];
                [self.exerciseData writeToFile:EXERCISE_PATH atomically:YES];
                
                break;
            }
        }
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL fieldInput = YES;
    
    LogTextField *logField = (LogTextField *)textField;
    
    switch (self.recoveryLogType) {
        case RecoveryLogTypeDetect:
        {
            NSString *text = [[textField.text stringByAppendingString:string] substringWithRange:NSMakeRange(0, range.location+1-range.length)];
            
            if ([logField.logFieldIdentify isEqualToString:@"glucose"]) {
                fieldInput = [self filterTextField:logField withDetectValue:text];
                
            }
            if ([logField.logFieldIdentify isEqualToString:@"hemoglobinef"]) {
                fieldInput = [self filterTextField:logField withDetectValue:text];
            }
            break;
        }
        case RecoveryLogTypeDrug:
        {
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
            break;
        }
        case RecoveryLogTypeDiet:
        case RecoveryLogTypeExercise:
        {
            if ([self numberPredicateString:string]) {
                NSString *text = [[textField.text stringByAppendingString:string] substringWithRange:NSMakeRange(0, range.location+1-range.length)];
                text = [self filterZeroNumber:text];
                
                
                if ([logField.logFieldIdentify isEqualToString:@"weight"]) {
                    
                    Food *food = self.dietArray[logField.logIndexPath.row-1];
                    food.weight = text;
                    NSString *rate = [self.dietRate valueForKey:food.food];
                    if (!rate) {
                        return YES;
                    }
                    food.calorie = [NSString stringWithFormat:@"%.f",rate.floatValue * text.floatValue];
                    DietCell *foodCell = (DietCell *)[self.dietView cellForRowAtIndexPath:logField.logIndexPath];
                    foodCell.calorie.text = food.calorie;
                }
                
                if ([logField.logFieldIdentify isEqualToString:@"calorie"]) {
                    Food *food = self.dietArray[logField.logIndexPath.row-1];
                    food.calorie = text;
                    NSString *rate = [self.dietRate valueForKey:food.food];
                    if (!rate) {
                        return YES;
                    }
                    food.weight = [NSString stringWithFormat:@"%.f",text.floatValue/rate.floatValue];
                    DietCell *foodCell = (DietCell *)[self.dietView cellForRowAtIndexPath:logField.logIndexPath];
                    foodCell.weight.text = food.weight;
                }
                
                if ([logField.logFieldIdentify isEqualToString:@"time"]) {
                    
                    ExerciseCell *exerciseCell = (ExerciseCell *)[self.exerciseView cellForRowAtIndexPath:logField.logIndexPath];
                    NSString *rate = [self.exerciseRate valueForKey:exerciseCell.exerciseName.text];
                    if (!rate) {
                        return YES;
                    }
                    exerciseCell.calorie.text = [NSString stringWithFormat:@"%.f",rate.floatValue * text.floatValue];
                }
                
                if ([logField.logFieldIdentify isEqualToString:@"exerciseCalorie"]) {
                    ExerciseCell *exerciseCell = (ExerciseCell *)[self.exerciseView cellForRowAtIndexPath:logField.logIndexPath];
                    NSString *rate = [self.exerciseRate valueForKey:exerciseCell.exerciseName.text];
                    if (!rate) {
                        return YES;
                    }
                    exerciseCell.time.text = [NSString stringWithFormat:@"%.f",text.floatValue/rate.floatValue];
                }
                
                
                
                fieldInput = YES;
            }else{
                fieldInput = NO;
            }
        }
        default:
            break;
    }
    
    return fieldInput;
}

- (NSString *)filterZeroNumber:(NSString *)text
{
    while ([text hasPrefix:@"0"]) {
        text = [text substringFromIndex:1];
    }
    return text;
}

- (NSString *)filterDot:(NSString *)text
{
    while ([text hasSuffix:@"."]) {
        text = [text substringToIndex:text.length-1];
    }
    return text;
}

- (BOOL)filterTextField:(LogTextField *)logField withDetectValue:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        return YES;
    }
    
    NSRange range = [text rangeOfString:@"."];
    if (range.location != NSNotFound) {
        if (range.location + 1 >= text.length-1) {
            if (range.location + 1 == text.length-1) {
                NSRange aRange;
                aRange.length = 1;
                aRange.location = range.location+1;
                if ([[text substringWithRange:aRange] isEqualToString:@"."]) {
                    return NO;
                }else return YES;
            }else return YES;
        }
        else return NO;
    }
    
    return YES;
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    LogTextField *logField = (LogTextField *)textField;
    switch (self.recoveryLogType) {
        case RecoveryLogTypeDetect:
        {
            if ([logField.logFieldIdentify isEqualToString:@"remark"]) {
                self.remark = logField.text ? logField.text : @"";
            }
            if ([logField.logFieldIdentify isEqualToString:@"glucose"]) {
                self.gluco = logField.text ? logField.text : @"";
                self.gluco = [self filterDot:self.gluco];
                
            }
            if ([logField.logFieldIdentify isEqualToString:@"hemoglobinef"]) {
                self.hemo = logField.text ? logField.text : @"";
                self.hemo = [self filterDot:self.hemo];
            }
            break;
        }
        case RecoveryLogTypeDrug:
        {
            
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
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0)
    {
        BasicCell *cell = (BasicCell *)[self.dietView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.detailText.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        self.period = cell.detailText.text;
    }
    
}

- (IBAction)datePickerBtnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1000:
        {
            break;
        }
        case 1001:
        {
            if (![ParseData parseDateIsAvaliable:self.datePicker.date]) {
                [hud hide:YES];
                return;
            }
            
            NSString *dateString;
            if (self.datePicker.datePickerMode == UIDatePickerModeDate) {
                dateString = [NSString formattingDate:self.datePicker.date to:@"yyyy-MM-dd"];
                
                self.date = dateString;
                
            }else if (self.datePicker.datePickerMode == UIDatePickerModeTime){
                dateString = [NSString formattingDate:self.datePicker.date to:@"HH:mm"];
                self.time = dateString;
            }
            
            BasicCell *cell;
            switch (self.recoveryLogType) {
                case RecoveryLogTypeDetect:
                    cell = (BasicCell *)[self.detectView cellForRowAtIndexPath:self.selectedIndexPath];
                    break;
                case RecoveryLogTypeDrug:
                    cell = (BasicCell *)[self.drugView cellForRowAtIndexPath:self.selectedIndexPath];
                    break;
                case RecoveryLogTypeDiet:
                    cell = (BasicCell *)[self.dietView cellForRowAtIndexPath:self.selectedIndexPath];
                    break;
                case RecoveryLogTypeExercise:
                    cell = (BasicCell *)[self.exerciseView cellForRowAtIndexPath:self.selectedIndexPath];
                    break;
                default:
                    break;
            }
            
            cell.detailText.text = dateString;
            
            break;
        }
    }
    
    
    if ([DeviceHelper phone])
    {
        [hud hide:YES];
    }
    else
    {
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = nil;
        }
    }
    
}



@end
