//
//  ResetPwdViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "UtilsMacro.h"

@interface ResetPwdViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *getAgainBtn;
@property (nonatomic) NSInteger secondsCountDown;
@property (strong, nonatomic) NSTimer *countDownTimer;

@end

@implementation ResetPwdViewController

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Reset", nil);
    [self configureCountDownTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)configureCountDownTimer
{
    self.secondsCountDown = 60;
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
}

- (void)timeFireMethod
{
    self.secondsCountDown--;
    [self.getAgainBtn setTitle:[NSString stringWithFormat:@"%ld%@",(long)self.secondsCountDown,NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
    [self.getAgainBtn setBackgroundColor:[UIColor grayColor]];
    self.getAgainBtn.userInteractionEnabled = NO;
    if (self.secondsCountDown==0) {
        [self.countDownTimer invalidate];
        [self.getAgainBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
        [self.getAgainBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:131/255.0 blue:13/255.0 alpha:1]];
        self.getAgainBtn.userInteractionEnabled = YES;
    }
}

- (IBAction)getCodeAgain:(id)sender
{
    NSString *confirmInfo = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.areaCode, self.phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil) message:confirmInfo delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        
        hud.delegate = self;
        hud.labelText = NSLocalizedString(@"Sending code", nil);
        [hud show:YES];
        
        NSDictionary *parameters = @{@"method":@"getCaptcha",
                                     @"mobile":self.phoneNumber,
                                     @"zone":self.areaCode};
        
        [GCRequest userGetCodeWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
            hud.mode = MBProgressHUDModeText;
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if (!error) {
                if ([ret_code isEqualToString:@"0"]) {
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = NSLocalizedString(@"Sending code succeed", nil);
                    [self configureCountDownTimer];
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

- (IBAction)resetAndLogin:(id)sender
{
    [self.view endEditing:YES];
    
    if (![ParseData parsePasswordIsAvaliable:self.passwordField.text]) {
        return;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Resetting...",nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"reSetPassword",
                                 @"mobile":self.phoneNumber,
                                 @"zone":self.areaCode,
                                 @"captcha":self.codeField.text,
                                 @"appType":@"1",
                                 @"password":self.passwordField.text};
    
    [GCRequest userResetPasswordWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                hud.labelText = NSLocalizedString(@"Reset succeed", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [AppDelegate userLogOut];
                });
            }else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }else{
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES];
        }
    }];

}
@end
