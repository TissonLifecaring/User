//
//  ControlEffectViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "ControlEffectViewController.h"
#import "EvaluateCell.h"
#import "EffectCell.h"
#import "UtilsMacro.h"
#import "VendorMacro.h"
#import "DeviceHelper.h"
#import "ShareHelper.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface ControlEffectViewController ()<UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate, NSFetchedResultsControllerDelegate,SSPullToRefreshViewDelegate, UMSocialUIDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    NSInteger _lastSelect;
}


@property (weak, nonatomic) IBOutlet GCTableView *tableView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *wrapperView;
@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSDictionary *countDayDic;
@property (strong, nonatomic) NSArray *countDayArr;
@property (strong, nonatomic) NSString *countDay;

@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation ControlEffectViewController

- (void)awakeFromNib
{
    _lastSelect = 0;
    self.countDay = @"7";
    self.dataArray = [NSMutableArray array];
    self.countDayDic = @{@"7":NSLocalizedString(@"Nearest 7 days", nil),
                         @"14":NSLocalizedString(@"Nearest 14 days", nil),
                         @"30":NSLocalizedString(@"Nearest 30 days", nil),
                         @"60":NSLocalizedString(@"Nearest 60 days", nil),
                         };
    self.countDayArr = @[@"7",@"14",@"30",@"60"];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetchController];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    [self setupRefreshView];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UIView *iconActionSheet = [self.navigationController.view viewWithTag:kTagSocialIconActionSheet];
    [iconActionSheet setNeedsDisplay];
}

- (void)viewDidLayoutSubviews
{
    if (self.refreshView == nil) {
        self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
        [self.refreshView startLoadingAndExpand:YES animated:YES];
    }
}

//- (void)setupRefreshView
//{
//    self.refreshView = [YALSunnyRefreshControl attachToScrollView:self.tableView];
//    self.refreshView.delegate = self;
//}

//- (void)YALRefreshViewDidStartLoading:(YALSunnyRefreshControl *)view
//{
//    [self getControlEffectData];
//}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self getControlEffectData];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (void)configureFetchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    self.fetchController = [ControlEffect fetchAllGroupedBy:nil sortedBy:@"userid.userId" ascending:YES withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)getControlEffectData
{
    NSDictionary *parameters = @{@"method":@"queryConclusion",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],
                                 @"countDay":self.countDay};
    [GCRequest userGetControlEffectWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                for (ControlEffect *controlEffect in self.fetchController.fetchedObjects) {
                    [controlEffect deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                ControlEffect *controlEffect = [ControlEffect createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                userID.userId = [NSString userID];
                userID.linkManId = [NSString linkmanID];
                controlEffect.userid = userID;
                
                [controlEffect updateCoreDataForData:responseData withKeyPath:nil];
                
                NSMutableOrderedSet *lists = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                
                EffectList *g3 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [g3 updateCoreDataForData:[responseData objectForKey:@"g3"] withKeyPath:nil];
                g3.name = NSLocalizedString(@"Fasting Blood-glucose", nil);
                EffectList *g2 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [g2 updateCoreDataForData:[responseData objectForKey:@"g2"] withKeyPath:nil];
                g2.name = NSLocalizedString(@"Postprandial Blood-glucose After 2 hours", nil);
                EffectList *g1 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [g1 updateCoreDataForData:[responseData objectForKey:@"g1"] withKeyPath:nil];
                g1.name = NSLocalizedString(@"Postprandial Blood-glucose After 1 hours", nil);
                EffectList *hemoglobin = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [hemoglobin updateCoreDataForData:[responseData objectForKey:@"hemoglobin"] withKeyPath:nil];
                hemoglobin.name = NSLocalizedString(@"Glycated hemoglobin", nil);
                
                [lists addObject:g3];
                [lists addObject:g1];
                [lists addObject:g2];
                [lists addObject:hemoglobin];
                
                controlEffect.effectList = lists;
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
            }
            else
            {
                [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
                if ([ret_code isEqualToString:@"-79"])
                {
                    
                    for (ControlEffect *controlEffect in self.fetchController.fetchedObjects) {
                        [controlEffect deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    }
                    
                    ControlEffect *controlEffect = [ControlEffect createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    controlEffect.userid = userID;
                    
                    [controlEffect updateCoreDataForData:responseData withKeyPath:nil];
                    
                    NSMutableOrderedSet *lists = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    
                    EffectList *g3 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    g3.name = NSLocalizedString(@"Fasting Blood-glucose", nil);
                    EffectList *g2 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    g2.name = NSLocalizedString(@"Postprandial Blood-glucose After 2 hours", nil);
                    EffectList *g1 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    g1.name = NSLocalizedString(@"Postprandial Blood-glucose After 1 hours", nil);
                    EffectList *hemoglobin = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    hemoglobin.name = NSLocalizedString(@"Glycated hemoglobin", nil);
                    
                    [lists addObject:g3];
                    [lists addObject:g1];
                    [lists addObject:g2];
                    [lists addObject:hemoglobin];
                    
                    controlEffect.effectList = lists;
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                }
            }
        }
        if (self.refreshView) {
            [self.refreshView finishLoading];
        }
    }];
}



#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    if (self.fetchController.sections.count > 0) {
        sections = self.fetchController.sections.count;
    }else sections = 0;
    return sections;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchController.fetchedObjects.count > 0) {
        ControlEffect *controlEffect = self.fetchController.fetchedObjects[0];
        return controlEffect.effectList.count+2;
    }else{
        return 6;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        EvaluateCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EvaluateCell" forIndexPath:indexPath];
        [self configureEvaluateCell:cell forIndexPath:indexPath];
        [self setBackgroundColorForCell:cell indexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 1)
    {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
        [self setBackgroundColorForCell:cell indexPath:indexPath];
        cell.backgroundColor = UIColorFromRGB(0x2C8CC6);
        
        cell.textLabel.text = NSLocalizedString(@"Select Period",nil);
        cell.textLabel.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.detailTextLabel.text = [self.countDayDic valueForKey:self.countDay];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    else
    {
        EffectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EffectCell" forIndexPath:indexPath];
        [self setBackgroundColorForCell:cell indexPath:indexPath];
        [self configureEffectCell:cell forIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)setupConstraintsWithCell:(UITableViewCell *)cell
{
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
}

- (void)setBackgroundColorForCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 5)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:(float)((0xF7FBFF & 0xFF0000) >> 16)/255.0 green:(float)((0xF7FBFF & 0xFF00)>>8) /255.0 blue:(float)((0xF7FBFF & 0xFF))/255.0 alpha:1]];
//        [cell setBackgroundColor:UIColorFromRGB(0xF7FBFF)];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)configureEvaluateCell:(EvaluateCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.scoreLabel.textColor = UIColorFromRGB(0x377EBC);
    cell.scoreLabel.font = [UIFont systemFontOfSize:[DeviceHelper biggestFontSize]];
    cell.evaluateTextLabel.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    
    ControlEffect *controlEffect;
    if (self.fetchController.fetchedObjects.count > 0)
    {
        controlEffect = [self.fetchController objectAtIndexPath:indexPath];
    }
    
    
    cell.scoreLabel.text = NSLocalizedString(@"Curative Effect Evaluation",nil);
    if (controlEffect.conclusionScore) {
        cell.scoreLabel.attributedText = [self configureLastLetter:[cell.scoreLabel.text stringByAppendingFormat:@" %@",controlEffect.conclusionScore,NSLocalizedString(@"point", nil)]];
    }else{
        cell.scoreLabel.attributedText = [self configureLastLetter:[cell.scoreLabel.text stringByAppendingFormat:@" %@",@"--"]];
    }
    
    if ((controlEffect.conclusionDesc && ![controlEffect.conclusionDesc isEqualToString:@""]) || (controlEffect.conclusion && ![controlEffect.conclusion isEqualToString:@""])) {
        cell.evaluateTextLabel.text = [NSString stringWithFormat:@"%@  %@",controlEffect.conclusion?controlEffect.conclusion:@"",controlEffect.conclusionDesc?controlEffect.conclusionDesc:@""];
    }else{
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor orangeColor]};
        NSAttributedString *aString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Cannot get the Evaluation", nil) attributes:attributes];
        cell.evaluateTextLabel.attributedText = aString;
    }
    
    
    [self setupConstraintsWithCell:cell];
}

- (void)configureEffectCell:(EffectCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    ControlEffect *controlEffect;
    EffectList *effectList;
    if (self.fetchController.fetchedObjects.count > 0) {
        controlEffect = self.fetchController.fetchedObjects[0];
        effectList = [controlEffect.effectList objectAtIndex:indexPath.row-2];
    }
    
    
    cell.testCount.text = NSLocalizedString(@"DetectionTime",nil);
    cell.overproofCount.text = NSLocalizedString(@"Exceeding Time",nil);
    cell.maximumValue.text = NSLocalizedString(@"Maximum Value",nil);
    cell.minimumValue.text = NSLocalizedString(@"Minimum Value",nil);
    cell.averageValue.text = NSLocalizedString(@"Average Value",nil);
    
    cell.testCount.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.overproofCount.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.maximumValue.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.minimumValue.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    cell.averageValue.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    
    cell.evaluateType.text = effectList.name;
    cell.evaluateType.textColor = UIColorFromRGB(0x498FCD);
    
    
    
    cell.maximumValue.attributedText = [self configureLastLetter:[cell.maximumValue.text stringByAppendingFormat:@" %@",effectList.max?effectList.max:@"--"]];
    cell.minimumValue.attributedText = [self configureLastLetter:[cell.minimumValue.text stringByAppendingFormat:@" %@",effectList.min?effectList.min:@"--"]];
    cell.averageValue.attributedText = [self configureLastLetter:[cell.averageValue.text stringByAppendingFormat:@" %@",effectList.avg?effectList.avg:@"--"]];
    cell.testCount.attributedText = [self configureLastLetter:[cell.testCount.text stringByAppendingFormat:@" %@",effectList.detectCount?effectList.detectCount:@"--"]];
    cell.overproofCount.attributedText = [self configureLastLetter:[cell.overproofCount.text stringByAppendingFormat:@" %@",effectList.overtopCount?effectList.overtopCount:@"--"]];
    
    [self setupConstraintsWithCell:cell];
    
    
    
}

- (NSMutableAttributedString *)configureLastLetter:(NSString *)string
{
    NSRange range = [string rangeOfString:@" "];
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string];
    [aString setAttributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]} range:NSMakeRange(range.location+1, string.length-range.location-1) ];
    return aString;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static EvaluateCell *evaluateCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            evaluateCell = [self.tableView dequeueReusableCellWithIdentifier:@"EvaluateCell"];
        });
        [self configureEvaluateCell:evaluateCell forIndexPath:indexPath];
        return [self calculateHeightForConfiguredSizingCell:evaluateCell];
    }
    else if (indexPath.row == 1) {
        return 30;
    } else {
        static EffectCell *effectCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            effectCell = [self.tableView dequeueReusableCellWithIdentifier:@"EffectCell"];
        });
        [self configureEffectCell:effectCell forIndexPath:indexPath];
        return [self calculateHeightForConfiguredSizingCell:effectCell];
        
    }
    
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.margin = 0;
        HUD.delegate = self;
        HUD.customView = self.wrapperView;
        HUD.mode = MBProgressHUDModeCustomView;
        [HUD show:YES];
    }
}

#pragma mark - pickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _lastSelect = row;
    [pickerView reloadAllComponents];
}


#pragma mark - pickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:[DeviceHelper biggerFontSize]]];
    [label setText:[self.countDayDic valueForKey:[self.countDayArr objectAtIndex:row]]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
//    if (row == _lastSelect)
//    {
//        [label setTextColor:[UIColor orangeColor]];
//    }
//    else
//    {
//        [label setTextColor:[UIColor blackColor]];
//    }
    return label;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return [self.countDayDic valueForKey:[self.countDayArr objectAtIndex:row]] ;
//}

- (IBAction)cancelAndConfirm:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1001:
        {
            break;
        }
        case 1002:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            self.countDay = [self.countDayArr objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            
            cell.detailTextLabel.text  = [self.countDayDic valueForKey:self.countDay];
            
            [self.refreshView startLoadingAndExpand:YES animated:YES];
            break;
        }
    }
    [HUD hide:YES afterDelay:0.25];
}



#pragma mark - Social Share
- (IBAction)socailShare:(id)sender
{
    NSString *shareString = [self configureShareString:nil];
    
    if (!shareString || shareString.length<=0)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"Cannot share without Evaluation", nil);
        [HUD show:YES];
        [HUD hide:YES afterDelay:HUD_TIME_DELAY];
    }
    else
    {
        [ShareHelper socailShareWithViewController:self shareText:@"" shareType:SocialShareTypeText photographView:nil shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToTencent,UMShareToQQ,UMShareToQzone,UMShareToSms,UMShareToEmail]];
    }
}

- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    NSString *shareURL = [self configureShareURL];
    NSString *shareString = [self configureShareString:nil];
    NSString *shareStringWithURL = [self configureShareString:shareURL];
    NSString *title = [self configureShareTitle];
    
    socialData.shareText = shareString;
    
    //有标题和内容
    if (platformName == UMShareToQQ || platformName == UMShareToWechatSession || platformName == UMShareToQzone || platformName == UMShareToTencent)
    {
        socialData.extConfig.qzoneData.title = title;
        socialData.extConfig.qqData.title = title;
        socialData.extConfig.wechatSessionData.title = title;
        
        
        socialData.extConfig.qzoneData.shareText = shareString;
        socialData.extConfig.qqData.shareText = shareString;
        socialData.extConfig.wechatSessionData.shareText = shareString;
        socialData.extConfig.tencentData.shareText = shareStringWithURL;
        
        socialData.extConfig.qzoneData.url = shareURL;
        socialData.extConfig.qqData.url = shareURL;
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

- (NSString *)configureShareString:(NSString *)shareURL
{

    ControlEffect *controlEffect;
    if (self.fetchController.fetchedObjects.count > 0)
    {
        controlEffect = [self.fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        
        if (controlEffect.conclusionScore && controlEffect.conclusionScore.length>0)
        {
            NSString *pointString = [NSString stringWithFormat:@"%@%@",controlEffect.conclusionScore,NSLocalizedString(@"point", nil)];
            NSString *effectString = [NSString stringWithFormat:@"%@  %@",controlEffect.conclusion?controlEffect.conclusion:@"",controlEffect.conclusionDesc?controlEffect.conclusionDesc:@""];
            
            NSString *shareString = [NSString stringWithFormat:@"%@,%@【%@】 %@",
                                     pointString,
                                     effectString,
                                     NSLocalizedString(@"GlucoTrack", nil),
                                     [NSString stringWithFormat:@"%@",shareURL]];
            
            
            return shareString;
        }
    }
    
    return @"";
}


- (NSString *)configureShareTitle
{
    
    NSString *time = [self.countDayDic valueForKey:self.countDay];
    
    NSString *title = [NSString stringWithFormat:@"我%@的%@",time,NSLocalizedString(@"Control Effect",nil)];
    return title;
}

- (NSString *)configureShareURL
{
    NSDate *date = [NSDate date];
    NSString *dateStr = [NSString formattingDate:date to:@"yyyyMMdd"];
    NSString *url = [GCSHARE_TEST_URL stringByAppendingFormat:@"detection?linkManId=%@&myDate=%@&days=%@",[NSString linkmanID],dateStr,self.countDay];
    return url;
}

@end
