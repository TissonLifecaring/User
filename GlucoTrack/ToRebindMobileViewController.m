//
//  ToRebindMobileViewController.m
//  SugarNursing
//
//  Created by Dan on 15-1-3.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ToRebindMobileViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "UtilsMacro.h"

@interface ToRebindMobileViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UIButton *getAgainBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeField;

@property (nonatomic) NSInteger secondsCountDown;
@property (strong, nonatomic) NSTimer *countDownTimer;


@end

@implementation ToRebindMobileViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"To Rebind Your Mobile", nil);
    self.codeField.placeholder = NSLocalizedString(@"Input the code you received", nil);
    [self configureCountDownTimer];
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

- (IBAction)getCodeAgain:(id)sender {
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


- (IBAction)rebind:(id)sender
{
    [self.view endEditing:YES];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Rebinding...", nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"accountEdit",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"userId":[NSString userID],
                                 @"mobile":self.phoneNumber,
                                 @"captcha":self.codeField.text,
                                 };
    
    [GCRequest userRebindMobileWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Rebind succeed", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [AppDelegate userLogOut];
                });
            }else{
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }else{
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
    }];

    
}


@end
