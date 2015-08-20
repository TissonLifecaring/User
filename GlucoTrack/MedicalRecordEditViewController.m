//
//  MedicalHistoryEditViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MedicalRecordEditViewController.h"
#import "MyTextView.h"

@interface MedicalRecordEditViewController ()<UITextFieldDelegate, UITextViewDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}


@property (weak, nonatomic) IBOutlet UITextField *medicalNameField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *hospitalField;
@property (weak, nonatomic) IBOutlet MyTextView *treatMentField;
@property (weak, nonatomic) IBOutlet MyTextView *treatPlanField;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;

@property (strong, nonatomic) UITextField *activeTextField;

@property (strong, nonatomic) UIPopoverController *popoverController;

@end

@implementation MedicalRecordEditViewController
@synthesize popoverController;

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureMedicalRecord];
}

- (void)configureRightBarButton
{
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    }
    
}

- (void)configureMedicalRecord
{
    self.medicalNameField.text = self.medicalRecord.mediName;
    self.dateField.text = self.medicalRecord.diagTime;
    self.hospitalField.text = self.medicalRecord.diagHosp;
    self.hospitalField.placeholder = NSLocalizedString(@"Hospital Name", nil);
    self.treatMentField.text = self.medicalRecord.treatMent;
    self.treatMentField.placeholder = NSLocalizedString(@"Treatment Condition", nil);
    self.treatPlanField.text = self.medicalRecord.treatPlan;
    self.treatPlanField.placeholder = NSLocalizedString(@"Treatment Scheme", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    switch (indexPath.row) {
        case 1:
        {
            [self configureRightBarButton];

            if ([self.medicalRecord.diagTime isEqualToString:@""] || !self.medicalRecord.diagTime)
            {
                self.datePicker.date = [NSDate date];
            }
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [dateFormatter dateFromString:self.dateField.text];
                [self.datePicker setDate:date animated:NO];
            }
            
            [self showDatePickerView];
            break;
        }
        default:
            break;
    }
    
}

- (void)showDatePickerView
{
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
        
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:NO];
            self.popoverController = nil;
        }
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        popoverContent.view = self.datePickerView;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.popoverContentSize = self.datePickerView.bounds.size;
        [self.popoverController presentPopoverFromRect:CGRectMake(130, 20+44*2, 0, 0)
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
        
    }

}

- (IBAction)pickerViewBtnTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case 1001:
            break;
        case 1002:
        {
            if ([ParseData parseDateIsAvaliable:self.datePicker.date])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
                self.dateField.text = dateString;
            }
        }
            break;
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

- (void)save:(id)sender
{
    [self.view endEditing:YES];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Saving Data", nil);
    [hud show:YES];
    
    NSMutableDictionary *parameters = [@{@"method":@"mediRecordEdit",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":[NSString linkmanID],
                                 @"mediName":self.medicalNameField.text,
                                 @"mediRecord":self.medicalRecord.mediRecord ? self.medicalRecord.mediRecord : NSLocalizedString(@"Please fill your info", nil),
                                 @"diagHosp":self.hospitalField.text,
                                 @"diagTime":self.dateField.text,
                                 @"treatMent":self.treatMentField.text,
                                 @"treatPlan":self.treatPlanField.text,} mutableCopy];
    
    switch (self.medicalHistoryType) {
        case MedicalHistoryTypeEdit:
            [parameters setValue:self.medicalRecord.mediHistId forKey:@"mediHistId"];
            break;
        case MedicalHistoryTypeAdd:
            break;
        default:
            break;
    }
    
    [GCRequest userEditMedicalRecordWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                // Add Mode needs to create a new MedicalRecord
                if (!self.medicalRecord) {
                    MedicalRecord *newMedicalRecord = [MedicalRecord createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    UserID *userId = [UserID createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    userId.userId = [NSString userID];
                    userId.linkManId = [NSString linkmanID];
                    newMedicalRecord.userid = userId;
                    
                    self.medicalRecord = newMedicalRecord;
                }
                
                [self.medicalRecord updateCoreDataForData:responseData withKeyPath:nil];
                [self updateMedicalRecord];
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Data Updated", nil);
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                hud.mode = MBProgressHUDModeText;
                hud.labelText  = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
            
        }else{
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];

    }];
}

- (void)updateMedicalRecord
{
    self.medicalRecord.mediName = self.medicalNameField.text;
    self.medicalRecord.diagTime = self.dateField.text;
    self.medicalRecord.diagHosp = self.hospitalField.text;
    self.medicalRecord.treatMent = self.treatMentField.text;
    self.medicalRecord.treatPlan =  self.treatPlanField.text;
    self.medicalRecord.mediRecord = self.medicalRecord.mediRecord ? self.medicalRecord.mediRecord : NSLocalizedString(@"Please fill your info", nil);
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self configureRightBarButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self configureRightBarButton];
}


@end
