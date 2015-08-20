//
//  VerificationViewController.m
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "VerificationViewController.h"
#import "AreaNameAndCodeViewController.h"
#import "RegistViewController.h"
#import "ResetPwdViewController.h"
#import "ToRebindMobileViewController.h"
#import "UtilsMacro.h"



@interface VerificationViewController ()<UIAlertViewDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) CountryAndAreaCode *countryAndAreaCode;

@end

@implementation VerificationViewController

- (void)awakeFromNib
{
    // Default CountryAndAreaCode
    self.countryAndAreaCode = [[CountryAndAreaCode alloc] init];
    self.countryAndAreaCode.countryName = NSLocalizedString(@"hongkong", nil);
    self.countryAndAreaCode.areaCode = @"852";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLabels];

}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)updateLabels
{
    self.countryLabel.text = self.countryAndAreaCode.countryName;
    self.areaCodeLabel.text = [NSString stringWithFormat:@"+%@",self.countryAndAreaCode.areaCode];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.row) {
        case 0:
        case 1:
        case 3:
            height = 30;
            break;
        case 2:
            height = 44;
            break;
        default:
            break;
    }
    return height;
}

- (IBAction)GetVerificationCode:(id)sender
{
    [self.view endEditing:YES];
    
    if ([self.countryAndAreaCode.areaCode isEqualToString:@"852"]) {
        if (self.phoneField.text.length != 8) {
            hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            hud.mode = MBProgressHUDModeText;
            hud.delegate = self;
            hud.labelText = NSLocalizedString(@"Phone number is not valid", nil);
            [hud show:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
            return;
            return;
        }
    }
    
    if ([self.countryAndAreaCode.areaCode isEqualToString:@"86"]) {
        if (self.phoneField.text.length != 11) {
            hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            hud.mode = MBProgressHUDModeText;
            hud.delegate = self;
            hud.labelText = NSLocalizedString(@"Phone number is not valid", nil);
            [hud show:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
            return;
            return;
        }
    }
    
    if (self.verifiedType == VerifiedTypeInReset) {
        if (![self.phoneField.text isEqualToString:[NSString phoneNumber]]) {
            hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            hud.mode = MBProgressHUDModeText;
            hud.delegate = self;
            hud.labelText = NSLocalizedString(@"Not your mobile phone", nil);
            [hud show:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
            return;
        }
    }
    
    NSString *confirmInfo = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.countryAndAreaCode.areaCode, self.phoneField.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil) message:confirmInfo delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];

}

- (void)userIsRegistered
{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        
        hud.delegate = self;
        hud.labelText = NSLocalizedString(@"Sending code", nil);
        [hud show:YES];
        
        // 如果是註冊、未登錄狀態的重設密碼、重新綁定都需要驗證用戶是否已經註冊
        if (self.verifiedType == VerifiedTypeInReset) {
            [self userGetCode];
            return;
        }
        
        
        NSDictionary *parameters = @{@"method":@"isMember",
                                     @"mobile":self.phoneField.text,
                                     @"memberType":@"2"};
        
        [GCRequest userIsRegisteredWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
            hud.mode = MBProgressHUDModeText;
            if (!error) {
                NSString *ret_code = [responseData objectForKey:@"ret_code"];
                if ([ret_code isEqualToString:@"0"]) {
                    
                    if (self.verifiedType == VerifiedTypeReset) {
                        if ([[responseData valueForKey:@"isMember"] isEqualToString:@"1"]) {
                            [self userGetCode];
                        }else{ hud.labelText = NSLocalizedString(@"User No Exists", nil);}
                    }else if (self.verifiedType == VerifiedTypeRegister){
                        if ([[responseData valueForKey:@"isMember"] isEqualToString:@"0"]){
                            [self userGetCode];
                        }else{ hud.labelText = NSLocalizedString(@"User Exists", nil); }
                    }else if (self.verifiedType == VerifiedTypeRebind){
                        if ([[responseData valueForKey:@"isMember"] isEqualToString:@"0"]){
                            [self userGetCode];
                        }else{ hud.labelText = NSLocalizedString(@"Mobile phone is rebinded", nil); }
                    }
                    
                }else{
                    hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                }
            }else{
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            }
            
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }];

    }
}

- (void)userGetCode
{
    NSDictionary *parameters = @{@"method":@"getCaptcha",
                                 @"mobile":self.phoneField.text,
                                 @"zone":self.countryAndAreaCode.areaCode};
    
    [GCRequest userGetCodeWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        hud.mode = MBProgressHUDModeText;
        
        if (!error) {
            
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                switch (self.verifiedType) {
                    case 0:
                        [self performSegueWithIdentifier:@"Register" sender:nil];
                        break;
                    case 1:
                    case 2:
                        [self performSegueWithIdentifier:@"Reset" sender:nil];
                        break;
                    case 3:
                        [self performSegueWithIdentifier:@"Rebind" sender:nil];
                        break;
                }
            }
            else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else{
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        
    }];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"AreaCode"])
    {
        AreaNameAndCodeViewController *areaNameAndCodeVC = [segue destinationViewController];
        areaNameAndCodeVC.countryAndAreaCode = self.countryAndAreaCode;

    }else if ([segue.identifier isEqual:@"Register"])
    {
        RegistViewController *registerVC = [segue destinationViewController];
        registerVC.areaCode = self.countryAndAreaCode.areaCode;
        registerVC.phoneNumber = self.phoneField.text;
    }else if ([segue.identifier isEqual:@"Reset"])
    {
        ResetPwdViewController *resetVC = [segue destinationViewController];
        resetVC.areaCode = self.countryAndAreaCode.areaCode;
        resetVC.phoneNumber = self.phoneField.text;
    }else if ([segue.identifier isEqualToString:@"Rebind"])
    {
        ToRebindMobileViewController *rebindVC = [segue destinationViewController];
        rebindVC.phoneNumber = self.phoneField.text;
        rebindVC.areaCode = self.countryAndAreaCode.areaCode;
    }
}

- (IBAction)back:(UIStoryboardSegue*)unwindSegue
{
    
}

@end
