//
//  MemberCenterViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-24.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MemberCenterViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "CustomLabel.h"
#import "UtilsMacro.h"
#import "ThumbnailImageView.h"

@interface MemberCenterViewController ()<NSFetchedResultsControllerDelegate>


@property (weak, nonatomic) IBOutlet ThumbnailImageView *thumbnail;
@property (weak, nonatomic) IBOutlet CustomLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *sexLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation MemberCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetchController];
    [self getUserInfo];
    [self configureUserInfo];
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
                
            }else{
                [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
            }
            
        }
        
        [[CoreDataStack sharedCoreDataStack] saveContext];
                
    }];
    
}


#pragma mark - PrepareForSegue

- (void)configureFetchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid.userId = %@ && userid.linkManId = %@",[NSString userID],[NSString linkmanID]];
    self.fetchController = [UserInfomation fetchAllGroupedBy:nil sortedBy:@"userid.userId" ascending:YES withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)configureUserInfo
{
//    if (self.fetchController.fetchedObjects.count == 0) {
//        self.tipsLabel.text = NSLocalizedString(@"Please edit your info", nil);
//        return;
//    }
    UserInfomation *userInfo = self.fetchController.fetchedObjects[0];

    if ([userInfo.userName isEqualToString:@""] || [userInfo.birthday isEqualToString:@""] || [userInfo.sex isEqualToString:@""]) {
        self.tipsLabel.text = NSLocalizedString(@"Please fill your info", nil);
    }else{
        self.tipsLabel.text = @"";
    }

    [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:userInfo.headImageUrl] placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    self.userNameLabel.text = userInfo.userName;
    self.sexLabel.text = userInfo.sex;
    
    int age;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *birthDate = [dateFormatter dateFromString:userInfo.birthday];
    
    NSTimeInterval dateDiff = [birthDate timeIntervalSinceNow];
    age = abs(trunc(dateDiff/(60*60*24))/365);
        
    self.ageLabel.text = [NSString stringWithFormat:@"%d %@",age,NSLocalizedString(@"years old", nil)];
}

#pragma mark - NSFetchedResultsConstrollerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self configureUserInfo];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }else return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)back:(UIStoryboardSegue *)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
