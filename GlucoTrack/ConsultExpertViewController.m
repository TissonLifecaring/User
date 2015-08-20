//
//  ConsultExpertViewController.m
//  GlucoTrack
//
//  Created by Ian on 15/7/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ConsultExpertViewController.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import "NoDataView.h"
#import "MyDoctor.h"
#import "OtherMappingInfo.h"
#import "NSDictionary+Formatting.h"
#import <SSPullToRefresh.h>
#import <UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "ConsultExpertCell.h"
#import "SPKitExample.h"
#import "AppDelegate+UserLogInOut.h"

@interface ConsultExpertViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
NSFetchedResultsControllerDelegate,
SSPullToRefreshViewDelegate
>
{
    MBProgressHUD *_hud;
    SSPullToRefreshView *_refreshView;
}

@property (nonatomic) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic) NSMutableArray *sourceArray;

@property (nonatomic, strong) NSFetchedResultsController *fetchedController;

@end

@implementation ConsultExpertViewController

- (void)awakeFromNib
{
    
    self.sourceArray = [NSMutableArray array];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureFetchController];
    [self configureSubViews];
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (void)configureFetchController
{
    
    self.fetchedController = [MyDoctor fetchAllGroupedBy:nil
                                                sortedBy:@"registerTime"
                                               ascending:NO
                                           withPredicate:nil
                                                delegate:self
                                               incontext:[CoreDataStack sharedCoreDataStack].context];
}


- (void)configureSubViews
{
    _refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.myTableView delegate:self];
    [_refreshView startLoadingAndExpand:YES animated:YES];
}

- (void)configureTableFootView
{
    if (self.fetchedController.fetchedObjects.count > 0)
    {
        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataView *view = [[NoDataView alloc] initWithFrame:self.myTableView.bounds];
        self.myTableView.tableFooterView = view;
    }
}

#pragma mark - SSPullRefreshView Delegate
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self requestMyDoctorList];
}

#pragma mark - NetWorking
- (void)requestMyDoctorList
{
    
    NSDictionary *parameters = @{@"method":@"getMyDoctorList",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID]};
    [GCRequest userGetMyDoctorListWithAttachWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                NSArray *array = responseData[@"doctors"];
                
                self.sourceArray = [array mutableCopy];
                
                for (MyDoctor *doctor in [MyDoctor findAllInContext:[CoreDataStack sharedCoreDataStack].context])
                {
                    [doctor deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                [self updateCoreData:self.sourceArray];
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                [_hud hide:YES];
            }
            else
            {
                _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:NO];
                [_hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            
        }
        else
        {
            
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [_hud hide:YES afterDelay:HUD_TIME_DELAY];
            
        }
        
        [_refreshView finishLoading];
    }];
}



#pragma mark - CoreData Update
- (void)updateCoreData:(NSMutableArray *)parameters
{
    for (NSDictionary *dic in parameters)
    {
        NSMutableDictionary *parameter = [dic mutableCopy];
        //数据规范化
        [parameter sexFormattingToUserForKey:@"sex"];
        [parameter dateFormattingToUser:@"YYYY-MM-dd" ForKey:@"birthday"];
        
        
        //更新MyDoctor
        NSString *exptId = [NSString stringWithFormat:@"%@",parameter[@"exptId"]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exptId = %@",exptId];
        NSArray *objects = [MyDoctor findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        
        MyDoctor *doctor;
        if (objects.count>0)
        {
            doctor = objects[0];
        }
        else
        {
            doctor = [MyDoctor createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        }
        
        [doctor updateCoreDataForData:parameter withKeyPath:nil];
        
        //更新OtherMappingInfo
        NSDictionary *otherMapping = parameter[@"otherMapping"][0];
        NSString *otherAccount = otherMapping[@"otherAccount"];
        if (!otherAccount || otherAccount.length<=0) break;
        
        predicate = [NSPredicate predicateWithFormat:@"otherAccount = %@",otherAccount];
        NSArray *result = [OtherMappingInfo findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        OtherMappingInfo *mappingInfo;
        if (result.count>0)
        {
            mappingInfo = result[0];
        }
        else
        {
            mappingInfo = [OtherMappingInfo createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        }
        
        [mappingInfo updateCoreDataForData:otherMapping withKeyPath:nil];
        
        doctor.otherMappintInfo = mappingInfo;
    }
}

#pragma mark - NSFetchResultController Delegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView reloadData];
    [self configureTableFootView];
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.row >= self.fetchedController.fetchedObjects.count) return;
    MyDoctor *doctor = self.fetchedController.fetchedObjects[indexPath.row];

    if ([[self.appDelegate.ywIMKit.IMCore getLoginService] isCurrentLogined])
    {
        [self goToChatWithPersonId:doctor.otherMappintInfo.otherAccount];
    }
    else
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [AppDelegate loginIMWithSuccessBlock:^{
            [_hud hide:YES];
            [self goToChatWithPersonId:doctor.otherMappintInfo.otherAccount];
        } failedBlock:^{
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = NSLocalizedString(@"Server is busy", nil);
            [_hud hide:YES afterDelay:HUD_TIME_DELAY];
        }];
    }
}

- (void)goToChatWithPersonId:(NSString *)personId
{
    YWPerson *person = [[YWPerson alloc] initWithPersonId:personId appKey:IM_EXPERT_KEY];
    
    [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithPerson:person
                                                          fromNavigationController:self.navigationController];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConsultExpertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConsultExpertCell"];
    
    [self configureConsultExpertCell:cell entity:self.fetchedController.fetchedObjects[indexPath.row]];
    
    return cell;
}

- (void)configureConsultExpertCell:(ConsultExpertCell *)cell entity:(MyDoctor *)doctor
{
    [cell.expertImageView sd_setImageWithURL:[NSURL URLWithString:doctor.headimageUrl]
                            placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    
    cell.expertNameLabel.text = doctor.exptName;
    cell.expertDetailLabel.text = doctor.skilled;
}


@end
