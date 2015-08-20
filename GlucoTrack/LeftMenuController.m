//
//  LeftMenuController.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "LeftMenuController.h"
#import "LeftMenuCell.h"
#import "MemberInfoCell.h"
#import "PersonalInfoViewController.h"
#import "MemberCenterViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "TestTrackerViewController.h"
#import "RecoveryLogViewController.h"
#import "ControlEffectViewController.h"
#import "RemindViewController.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface LeftMenuController ()

@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic) NSInteger selectedIndex;


@end

@implementation LeftMenuController

- (void)awakeFromNib
{
    [super awakeFromNib];
    _selectedIndex = -1;
    if (!self.menuArray) {
        self.menuArray  = @[
                            @[NSLocalizedString(@"Test Result",),@"Test"],
                            @[NSLocalizedString(@"Control Effect",),@"Effect"],
                            @[NSLocalizedString(@"Recovery Log",),@"Recovery"],
                            @[NSLocalizedString(@"My Tips",),@"Remind"],
                            @[NSLocalizedString(@"Service Center",),@"Service"],
                            @[NSLocalizedString(@"Advise",),@"Advise"],
                            @[NSLocalizedString(@"Consult Expert",),@"Advise"],
                            @[NSLocalizedString(@"Member Center",),@"Center"],
                            @[NSLocalizedString(@"Log Out",),@"IconEmpty"],
                            ];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetchController];
    [self getUserInfo];
    [self getNewMessages];
    [self configureMenu];
}

- (void)configureFetchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.linkManId = %@ && userid.userId = %@",[NSString linkmanID], [NSString userID]];
    self.fetchController = [UserInfomation fetchAllGroupedBy:nil sortedBy:@"userid.userId" ascending:YES withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
        
    self.mfetchController = [UserMessages fetchAllGroupedBy:nil sortedBy:@"userid.userId" ascending:YES withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    if (0 == self.mfetchController.fetchedObjects.count) {
        self.userMessages = [UserMessages createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        UserID *userID = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        userID.userId = [NSString userID];
        userID.linkManId = [NSString linkmanID];
        self.userMessages.userid = userID;
    }else{
        self.userMessages = self.mfetchController.fetchedObjects[0];
    }
}

- (void)configureMenu
{
    self.leftMenu.rowHeight = UITableViewAutomaticDimension;
    self.leftMenu.estimatedRowHeight = 100;
}

- (void)configureNewMessages:(NSDictionary *)userInfo
{
    NSString *content = [userInfo valueForKey:@"content"];
    
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:&error];
    
    if ([[contentDic valueForKey:@"type"] isEqualToString:@"messageAgent"]) {
        self.userMessages.agentMsg = [NSString stringWithFormat:@"%d",[self.userMessages.agentMsg intValue]+1];
    }
    if ([[contentDic valueForKey:@"type"] isEqualToString:@"messageSuggest"]) {
        self.userMessages.suggest = [NSString stringWithFormat:@"%d",[self.userMessages.suggest intValue]+1];
    }
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

- (void)getNewMessages
{
    NSDictionary *parameters = @{@"method":@"getNewMessageCount",
                                 @"recvUser":[NSString userID],
                                 @"sessionId":[NSString sessionID],
                                 @"sign":@"sign"};
    
    [GCRequest userGetNewMessagesWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                NSMutableArray *countList = [[responseData objectForKey:@"countList"] mutableCopy];
                
                [countList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary *message = (NSDictionary *)obj;
                    NSString *newNum = [message valueForKey:@"newNum"];
                    
                    if ([[message valueForKey:@"messageType"] isEqualToString:@"agentMsg"]) {
                        self.userMessages.agentMsg = [NSString stringWithFormat:@"%ld",[self.userMessages.agentMsg integerValue]+[newNum integerValue]];
                    }
                    if ([[message valueForKey:@"messageType"] isEqualToString:@"suggest"]) {
                        self.userMessages.suggest = [NSString stringWithFormat:@"%ld",[self.userMessages.suggest integerValue]+[newNum integerValue]];
                    }
                
                }];
            }
        }
        
        [[CoreDataStack sharedCoreDataStack] saveContext];
    }];
}

- (void)getUserInfo
{
    //Get UserInfo after Logining
    
    NSDictionary *parameters = @{@"method":@"getPersonalInfo",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],
                                 @"sign":@"sign"};
    
    [GCRequest userGetInfoWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        // 这里无论获取用户信息的请求是成功还是失败，在CoreData中至少都要创建一个以userID为主键的userInfo（用户能登陆入主界面，已经存在userid和linkmandid)
        
        UserInfomation *userInfo;
        UserID *userID;
        
        if ( 0 == self.fetchController.fetchedObjects.count) {
            userInfo = [UserInfomation createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            userID= [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            userID.userId = [NSString userID];
            userID.linkManId = [NSString linkmanID];
            userInfo.userid = userID;
            
        }else{
            userInfo = self.fetchController.fetchedObjects[0];
            userID = userInfo.userid;
        }
        
        if (!error) {
            
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            
            if ([ret_code isEqualToString:@"0"]) {
                
                // Save userInformation to CoreData
                
                responseData = [[responseData objectForKey:@"linkManInfo"] mutableCopy];
                
                // Formatting responseData to coreData
                [responseData dateFormattingToUser:@"yyyy-MM-dd" ForKey:@"birthday"];
                [responseData sexFormattingToUserForKey:@"sex"];
                [responseData serverLevelFormattingToUserForKey:@"servLevel"];
                
                [userInfo updateCoreDataForData:responseData withKeyPath:nil];
                
                
                //缓存头像
                UIImageView *imageView = [UIImageView new];
                [imageView sd_setImageWithURL:[NSURL URLWithString:userInfo.headImageUrl]];
                
                
            }else{
                [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
            }
                
        }
        
        [[CoreDataStack sharedCoreDataStack] saveContext];
        
        DDLogDebug(@"Saving UserInfo :%@",userInfo);
        
    }];
    
}

#pragma mark - NSFetchResultControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([controller isEqual:self.fetchController]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.leftMenu reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if ([controller isEqual:self.mfetchController]) {
        
        NSInteger count = [self.userMessages.suggest integerValue] + [self.userMessages.agentMsg integerValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        
        NSIndexPath *agentMsgIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        NSIndexPath *suggestIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
        
        [self.leftMenu reloadRowsAtIndexPaths:@[agentMsgIndexPath,suggestIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuArray.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 140;
    } else return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 ) {
        MemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberInfoCell" forIndexPath:indexPath];
        [self configureMemberInfoCell:cell atIndexPath:indexPath];
        return cell;
    }
    
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftMenuCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    [cell configureCellWithIconName:self.menuArray[indexPath.row-1][1] LabelText:self.menuArray[indexPath.row-1][0]];
    cell.badgeString = @"0";
    
    if (indexPath.row == 5) {
        cell.badgeRelativeView = cell.LeftMenuLabel;
        cell.badgeString = self.userMessages.agentMsg;
    }
    if (indexPath.row == 6) {
        cell.badgeRelativeView = cell.LeftMenuLabel;
        cell.badgeString = self.userMessages.suggest;
    }
    
    return cell;
}

- (void)configureMemberInfoCell:(MemberInfoCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.badgeString = @"0";
    
    UserInfomation *userInfo;
    if ([self.fetchController.fetchedObjects count] == 0) {
        userInfo = nil;
    }else{
        userInfo = self.fetchController.fetchedObjects[0];
    }
    [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:userInfo.headImageUrl] placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    cell.userNameLabel.text = userInfo.userName;
    
    int age;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *birthDate = [dateFormatter dateFromString:userInfo.birthday];
    NSTimeInterval dateDiff = [birthDate timeIntervalSinceNow];
    age = abs(trunc(dateDiff/(60*60*24))/365);
    
    cell.sexAndAgeLabel.text = [NSString stringWithFormat:@"%@   %d%@",userInfo.sex,age,NSLocalizedString(@"years old", nil)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndex == indexPath.row) {
        if (indexPath.row == 8) {
            [self switchToViewControllerAtIndex:self.selectedIndex];
            return;
        }
        [self.sideMenuViewController hideMenuViewController];
        return;
    } else {
        self.selectedIndex = indexPath.row;
        [self switchToViewControllerAtIndex:self.selectedIndex];
    }
    
    // 置零所有的badge数
    TDBadgedCell *cell = (TDBadgedCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.badgeString boolValue]) {
        
        if (indexPath.row == 5) {
            self.userMessages.agentMsg = @"0";
        }
        if (indexPath.row == 6) {
            self.userMessages.suggest = @"0";
        }
    }
    
}

- (void)switchToViewControllerAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            [self.sideMenuViewController setContentViewController:[[UIStoryboard memberCenterStoryboard] instantiateInitialViewController] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
//            PersonalInfoViewController *personalInfo = [[UIStoryboard memberCenterStoryboard] instantiateViewControllerWithIdentifier:@"PersonalInfo"];
//            [personalInfo.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleDone target:self action:@selector(menu:)]];
//            UINavigationController *personalInfoNav = [[UINavigationController alloc] initWithRootViewController:personalInfo];
//            [self.sideMenuViewController setContentViewController:personalInfoNav animated:YES];
//            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 1:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard testTracker] instantiateInitialViewController] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 2:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard controlEffect] instantiateInitialViewController] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard recoveryLog] instantiateInitialViewController]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard myRemind] instantiateInitialViewController]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 5:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard myService] instantiateInitialViewController]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 6:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard advise] instantiateInitialViewController]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 7:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard consultExpert] instantiateInitialViewController]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 8:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard memberCenterStoryboard] instantiateInitialViewController] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 9:
        {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
            [self.parentViewController.view addSubview:hud];
            hud.delegate = self;
            hud.labelText = NSLocalizedString(@"Logout..", nil);
            [hud show:YES];
            
            NSDictionary *parameters = @{@"method":@"delSession",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"accountId":[NSString userID],
                                         };
            [GCRequest userLogoutWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
                hud.mode = MBProgressHUDModeText;
                if (!error) {
                    NSString *ret_code = [responseData objectForKey:@"ret_code"];
                    if ([ret_code isEqualToString:@"0"]) {
                        
                        // User logout
                        [AppDelegate userLogOut];
                    }else{
                        hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    }
                }else{
                    hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                }
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }];
            
            break;
        }
        default:
            break;
    }
}

- (void)menu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
