//
//  MyServiceViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MyServiceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ServiceCell.h"
#import "UtilsMacro.h"
#import <SSPullToRefresh.h>
#import "MyTextView.h"
#import "ShareHelper.h"


@interface MyServiceViewController ()<UITableViewDataSource, UITableViewDelegate, SSPullToRefreshViewDelegate, NSFetchedResultsControllerDelegate,MBProgressHUDDelegate,UMSocialUIDelegate>{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MyTextView *serverTextView;


@property (strong, nonatomic) SSPullToRefreshView *pullToRefreshView;

@end

@implementation MyServiceViewController

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchMessages];
    [self configureTableViewAndTextView];
    
    [self configureBarItem];
    
    self.pullToRefreshView  = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    [self.pullToRefreshView startLoadingAndExpand:YES animated:YES];

}

- (void)configureBarItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonEvent)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)fetchMessages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    self.fetchController = [Message fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)configureTableViewAndTextView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.serverTextView.placeholder = NSLocalizedString(@"Please leave your message.", nil);
    self.serverTextView.placeholderColor = [UIColor lightGrayColor];
    [[self.serverTextView layer] setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor]];
    [[self.serverTextView layer] setBorderWidth:1.0];
}
- (IBAction)sendMessages:(id)sender
{
    [self.view endEditing:YES];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.mode = MBProgressHUDModeText;
    hud.delegate = self;
    
    if (![ParseData parseStringIsAvaliable:self.serverTextView.text]) {
        hud.labelText = NSLocalizedString(@"Format is not avaliable", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    NSDictionary *parameters = @{@"method":@"sendAgentMessage",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"centerId":[NSString centerID],
                                 @"content":self.serverTextView.text,
                                 @"contentType":@"01",
                                 @"sendUser":[NSString userID]};
    [GCRequest userSendMessageWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        [hud show:YES];
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                self.serverTextView.text =nil;
                hud.labelText = NSLocalizedString(@"Send Message Succeed", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                
                [self.pullToRefreshView startLoadingAndExpand:YES animated:YES];
                
            }else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }else{
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
    }];
}

- (void)getMessages
{
    NSDictionary *parameters = @{@"method":@"getAgentMessageList",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"centerId":[NSString centerID],
                                 @"recvUser":[NSString userID],
                                 @"size":@"20",
                                 };
    [GCRequest userGetMessageListWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                for (Message *messageCache in self.fetchController.fetchedObjects) {
                    [messageCache deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                NSArray *messageArray;
                if ([[responseData objectForKey:@"agentMsgList"] isKindOfClass:[NSArray class]]) {
                    messageArray = [responseData objectForKey:@"agentMsgList"];
                }else{
                    messageArray = @[];
                }
                
                for (NSDictionary *messageDic in messageArray) {
                    
                    NSMutableDictionary *messageDic_ = [messageDic mutableCopy];
                    [messageDic_ dateFormattingToUser:@"yyyy-MM-dd HH:mm:ss" ForKey:@"sendTime"];
                    
                    Message *message = [Message createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    [message updateCoreDataForData:messageDic_ withKeyPath:nil];
                    
                    UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userID.userId = [NSString userID];
                    userID.linkManId = [NSString linkmanID];
                    message.userid = userID;
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
            }else{
                [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
            }
            
        }
        
        if (self.pullToRefreshView) {
            [self.pullToRefreshView finishLoading];
        }
    }];
}


#pragma mark - SSPullToRefreshDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self getMessages];
}

#pragma mark - NSFetchedResultControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - UITalbeView DataSource

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

    return self.fetchController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIndentifier = @"ServiceCell";
    ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
    [self configureServerCell:cell indexPath:indexPath];
    return cell;
}

- (void)configureServerCell:(ServiceCell *)cell indexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
    
    if ([message.direct isEqualToString:@"01"])
    {
        [cell.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:[NSString userThumbnail]] placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    }else
    {
        cell.thumbnailImageView.image = [UIImage imageNamed:@"CustomerService.png"];
    }
    cell.serviceLabel.text = message.content;
    cell.dateLabel.text = message.sendTime;
    
    [self setupConstraintsWithCell:cell];
}

- (void)setupConstraintsWithCell:(UITableViewCell *)cell
{
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static ServiceCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    });
    [self configureServerCell:sizingCell indexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
