//
//  AdviseViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AdviseViewController.h"
#import "AdviseCell.h"
#import <SSPullToRefresh.h>
#import "NoDataView.h"
#import "ShareHelper.h"
#import <MBProgressHUD.h>
#import <MWPhotoBrowser.h>
#import "MsgRecord_Cell.h"
#import "NoDataView.h"
#import "AdviseAttach.h"
#import "NSString+UserCommon.h"
#import "CoreDataStack.h"
#import "NSManagedObject+Finders.h"
#import "NSManagedObject+Savers.h"
#import "GCRequest.h"
#import <UIImageView+AFNetworking.h>


static CGFloat cellEstimatedHeight = 200;

static NSString *loadSize = @"15";
static NSString *cellIndentifier = @"MsgRecord_Cell";


@interface AdviseViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
SSPullToRefreshViewDelegate,
NSFetchedResultsControllerDelegate,
UMSocialUIDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
MWPhotoBrowserDelegate
>
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) SSPullToRefreshView *pullToRefreshView;

@property (strong, nonatomic) NSMutableArray *photos;

@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL isAll;


@end

@implementation AdviseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    [self configureFetchController];
    
    [self configureBarItem];
    
    
}

- (void)viewDidLayoutSubviews
{
    if (self.pullToRefreshView == nil)
    {
        self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
        [self.pullToRefreshView startLoadingAndExpand:YES animated:YES];
    }
}

- (void)configureBarItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonEvent)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)configureFetchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    self.fetchController = [Advise fetchAllGroupedBy:nil sortedBy:@"adviceTime" ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

#pragma mark - SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self requestDoctorSuggestsDataWithBeforeTime:nil afterTime:nil refresh:YES];
}

#pragma mark - NSFetchController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (void)getDoctorSuggestions
{
    NSDictionary *parameters = @{@"method":@"getDoctorSuggests",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],};
    
    [GCRequest userGetDoctorSuggestionWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                // 清除缓存
                for (Advise *advise in self.fetchController.fetchedObjects) {
                    [advise deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                NSArray *adviseArray;
                
                if ([[responseData objectForKey:@"suggestList"] isKindOfClass:[NSArray class]])
                {
                    adviseArray = [responseData objectForKey:@"suggestList"];
                }
                else
                {
                    adviseArray = @[];
                }
               
                for (NSDictionary *adviseDic in adviseArray) {
                    
                    NSMutableDictionary *adviseDic_ = [adviseDic mutableCopy];
                    [adviseDic_ dateFormattingToUser:@"yyyy-MM-dd HH:mm:ss" ForKey:@"AdviseTime"];
                    
                    Advise *advise =[Advise createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    [advise updateCoreDataForData:adviseDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    advise.userid = userID;
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
            }
        }
        if (self.pullToRefreshView) {
            [self.pullToRefreshView finishLoading];
        }
    }];
}



#pragma mark - NetWorking
- (void)requestDoctorSuggestsDataWithBeforeTime:(NSString *)beforeTime afterTime:(NSString *)afterTime refresh:(BOOL)refresh
{
    self.loading = YES;
    NSMutableDictionary *parameters = [@{@"method":@"getDoctorSuggestsWithAttach",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":[NSString linkmanID],
                                         @"start":refresh ? @"1": @(self.fetchController.fetchedObjects.count+1).stringValue,
                                         @"size":loadSize
                                         } mutableCopy];
    
    if (beforeTime && beforeTime.length > 0)
    {
        [parameters setValue:beforeTime forKey:@"beforeTime"];
    }
    else if (afterTime && afterTime.length > 0)
    {
        [parameters setValue:afterTime forKey:@"afterTime"];
    }
    
    
    [GCRequest userGetDoctorSuggestsWithAttachWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        self.loading = NO;
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                if (refresh)
                {
                    
                    // 清除缓存
                    for (Advise *advise in self.fetchController.fetchedObjects)
                    {
                        [advise deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    }
                }
                
                NSInteger size = [responseData[@"suggestListSize"] integerValue];
                if (size < [loadSize integerValue])
                {
                    self.isAll = YES;
                }
                else
                {
                    self.isAll = NO;
                }
                
                
                NSArray *adviseArray = responseData[@"suggestList"];
                
                
                
                for (NSDictionary *adviseDic in adviseArray)
                {
                    
                    NSMutableDictionary *adviseDic_ = [adviseDic mutableCopy];
                    [adviseDic_ dateFormattingToUser:@"yyyy-MM-dd HH:mm:ss" ForKey:@"adviceTime"];
                    
                    Advise *advise =[Advise createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    [advise updateCoreDataForData:adviseDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    advise.userid = userID;
                    
                    
                    NSArray *adviseArray = adviseDic_[@"attach"];
                    NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] init];
                    for (NSDictionary *attachDic in adviseArray)
                    {
                        AdviseAttach *attach = [AdviseAttach createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [attach updateCoreDataForData:attachDic withKeyPath:nil];
                        [orderSet addObject:attach];
                    }
                    
                    advise.adviseAttach = orderSet;
                }
                
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                
                NSInteger total = [responseData[@"total"] integerValue];
                if (total <= self.fetchController.fetchedObjects.count)
                {
                    self.isAll = YES;
                }
            }
            else
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                [hud show:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            [hud show:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
        if (self.pullToRefreshView)
        {
            [self.pullToRefreshView finishLoadingAnimated:YES completion:nil];
        }
    }];
    
    
}


#pragma mark - UITalbeView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgRecord_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier
                                                           forIndexPath:indexPath];
    [cell configureCellWithModel:self.fetchController.fetchedObjects[indexPath.row]
                        delegate:self];
    cell.myCollectView.tag = indexPath.row;
    [cell.myCollectView reloadData];
    return cell;
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellEstimatedHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static MsgRecord_Cell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    });
    [sizingCell configureCellWithModel:self.fetchController.fetchedObjects[indexPath.row]
                              delegate:self];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(MsgRecord_Cell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), cellEstimatedHeight);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds))
    {
        if (!self.isAll && !self.loading)
        {
            Advise *advise = [self.fetchController.fetchedObjects lastObject];
            [self requestDoctorSuggestsDataWithBeforeTime:advise.adviceTime afterTime:nil refresh:NO];
        }
    }
}



- (void)configureTableViewFooterView
{
    if (self.fetchController.fetchedObjects.count > 0)
    {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataView *view = [[NoDataView alloc] initWithFrame:self.tableView.bounds];
        self.tableView.tableFooterView = view;
    }
}




#pragma mark - UICollectView Delegate & DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Advise *advise = self.fetchController.fetchedObjects[collectionView.tag];
    return advise.adviseAttach.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MsgAttach_Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:66666];
    
    Advise *advise = self.fetchController.fetchedObjects[collectionView.tag];
    AdviseAttach *attach = advise.adviseAttach[indexPath.row];
    [imageView afSetImageWithURL:[NSURL URLWithString:attach.attachPath]
                placeholderImage:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.photos = [[NSMutableArray alloc] init];
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
    Advise *advise = self.fetchController.fetchedObjects[collectionView.tag];
    
    MWPhoto *photo;
    for (int i=0 ; i < advise.adviseAttach.count; i++)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:66666];
        UIImage *image = imageView.image;
        
        photo = [MWPhoto photoWithImage:image];
        [photos addObject:photo];
    }
    
    self.photos = photos;
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = NO;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        // conditionly check for any version >= iOS 8
        [self showViewController:photoBrowser sender:nil];
        
    } else
    {
        // iOS 7 or below
        [self.navigationController pushViewController:photoBrowser animated:YES];
    }
}


#pragma mark - MWPhotoBrowser Delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.photos.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    
    
    return nil;
}


#pragma mark - Social Share
- (void)shareButtonEvent
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




@end
