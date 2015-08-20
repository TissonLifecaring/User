//
//  RegistViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RegistViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "UtilsMacro.h"

@interface RegistViewController ()<UIAlertViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}
@property (strong, nonatomic) NSTimer *countDownTimer;
@property (nonatomic) NSInteger secondsCountDown;

@property (strong, nonatomic) UIPopoverController *popoverController;

@end


@implementation RegistViewController
@synthesize popoverController;

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
    
    self.title = NSLocalizedString(@"Register", nil);
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
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
    [self.getCodeAginBtn setTitle:[NSString stringWithFormat:@"%ld%@",(long)self.secondsCountDown,NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
    [self.getCodeAginBtn setBackgroundColor:[UIColor grayColor]];
    self.getCodeAginBtn.userInteractionEnabled = NO;
    if (self.secondsCountDown==0) {
        [self.countDownTimer invalidate];
        [self.getCodeAginBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
        [self.getCodeAginBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:131/255.0 blue:13/255.0 alpha:1]];
        self.getCodeAginBtn.userInteractionEnabled = YES;
    }
}

#pragma mark - IBAction

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



- (IBAction)genderPicker:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"choosegender", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"male", nil),NSLocalizedString(@"female", nil), nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0)
    {
        [self.genderBtn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
}


- (IBAction)datePicker:(id)sender
{
    [self.view endEditing:YES];
    
    
    if ([DeviceHelper phone])
    {
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.customView = self.pickerView;
        hud.margin = 0;
        hud.delegate = self;
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
        popoverContent.view = self.pickerView;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.popoverContentSize = self.pickerView.bounds.size;
        CGRect rect = [self.scrollView convertRect:self.dateBtn.frame toView:self.view];
        [self.popoverController presentPopoverFromRect:rect
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
        
    }
}

- (IBAction)dateCancelAndConfirm:(id)sender
{
    UIButton *btn = (UIButton *)sender;

    if (btn.tag == 1001)
    {
        if ([ParseData parseDateIsAvaliable:self.datePicker.date])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
            [self.dateBtn setTitle:dateString forState:UIControlStateNormal];
        }
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

- (IBAction)regist:(id)sender
{
    [self.view endEditing:YES];
    if (![ParseData parseCodeIsAvaliable:self.codeField.text]) {
        return;
    }
    if (![ParseData parseUserNameIsAvaliable:self.usernameField.text]) {
        return;
    }
    if (![ParseData parsePasswordIsAvaliable:self.passwordField.text]) {
        return;
    }
    [self userRegister];

}

- (void)userRegister
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Registering...", nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"accountRegist",
                                 @"mobile":self.phoneNumber,
                                 @"captcha":self.codeField.text,
                                 @"password":self.passwordField.text,
                                 @"userName":self.usernameField.text,
                                 @"sex":[self.genderBtn currentTitle],
                                 @"birthday":[self.dateBtn currentTitle],
                                 @"zone":self.areaCode,
                                 };
    
    [GCRequest userRegisterWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]){
                hud.labelText = NSLocalizedString(@"Register succeed", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [AppDelegate userLogOut];
                });
                
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

@end
