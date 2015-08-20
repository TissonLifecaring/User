//
//  LoginViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-6.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "UIViewController+Notifications.h"
#import "VerificationViewController.h"
#import "UtilsMacro.h"


@interface LoginViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}


@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordTextField;

@property (weak, nonatomic) IBOutlet UIView *loginContentView;

@end

@implementation LoginViewController

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
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VerificationViewController *verificationVC= (VerificationViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
    
    if ([segue.identifier isEqualToString:@"Regist"])
    {
        verificationVC.title = NSLocalizedString(@"Register", nil);
        verificationVC.verifiedType = 0;

    }
    else if ([segue.identifier isEqualToString:@"Reset"])
    {
        verificationVC.title = NSLocalizedString(@"Reset", nil);
        verificationVC.verifiedType = 1;
        
    }
    
}

#pragma mark - KeyboardNotification

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotification:@selector(keyboardWillShow:) :@selector(keyboardWillHide:)];
    
    [self automatiWriteUserName];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboardNotification];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat kbHeight = kbSize.height;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    CGFloat calHeight = screenHeight/2 - 50 - CGRectGetHeight(self.loginContentView.bounds)/2;
    
    CGFloat moveHeight = (kbHeight - calHeight);
    if (calHeight >= kbHeight)
    {
        return;
    }
    else
    {
        
        CGFloat contentSize = CGRectGetHeight(self.loginContentView.bounds) + kbHeight;
        //移动后若上方超出状态栏 , 则loginView再往下调整确保能完全显示输入框
        if (contentSize > screenHeight - 20)
        {
            moveHeight -= contentSize - (screenHeight - 20); //20为状态栏高度;
        }
        
        // -50为初始值
        self.loginContentViewYCons.constant = -50 + moveHeight;
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.loginContentViewYCons.constant  = -50;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark 自动填写用户名
- (void)automatiWriteUserName
{
    
    NSArray *userObjects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    User *user;
    if (userObjects.count>0)
    {
        user = userObjects[0];
        [self.usernameTextField setText:user.userName];
    }
}

#pragma mark - userAction
- (IBAction)loginButtonEvent:(id)sender {
    [self login];
}


- (void)login
{
    [self.view endEditing:YES];
    
    if (![ParseData parseUserNameIsAvaliable:self.usernameTextField.text]) {
        return;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Login..", nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"verify",
                                 @"accountName":self.usernameTextField.text,
                                 @"password":self.userPasswordTextField.text,
                                 @"language":[NSString language],
                                 @"clientSource":[NSString clientSystem],
                                 @"deviceToken":[NSString deviceToken]};
    
    [GCRequest userLoginWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        if (!error) {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"]) {
                
                // 这里对获取到的会话标识、会话标识Token和用户标识等进行数据持久化
                
                NSMutableDictionary *responseDic = [responseData mutableCopy];
                [responseDic setValue:[self.userPasswordTextField.text md5] forKey:@"passWord"];
                [responseDic setValue:self.usernameTextField.text forKey:@"userName"];
                
                NSArray *userObjects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
                
                // 这里的user是一个单例，有且只有一个用户数据，标识当前的用户
                User *user;
                
                if ([userObjects count]== 0)
                {
                    user = [User createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    
                }else{
                    user = userObjects[0];
                }
                
                [user updateCoreDataForData:responseDic withKeyPath:nil];
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                DDLogInfo(@"Saving user: %@",user);
                
                //保存IM账号密码
                NSString *account = [NSString stringWithFormat:@"%@",responseDic[@"openIMAccount"]];
                NSString *password = [NSString stringWithFormat:@"%@",responseDic[@"openIMPwd"]];
                [self saveOpenIMInfoWithAccount:account password:password];
                
                [AppDelegate userLogIn];
                [hud hide:YES];
                
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

#pragma mark - textfieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 11:
            self.userTextFieldBG.image = [UIImage imageNamed:@"003"];
            break;
        case 12:
            self.userPasswordFieldBG.image = [UIImage imageNamed:@"003"];
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 11:
            self.userTextFieldBG.image = [UIImage imageNamed:@"004"];
            break;
        case 12:
            self.userPasswordFieldBG.image = [UIImage imageNamed:@"004"];
            break;
    }
}


#pragma mark 保存阿里百川IM登陆参数
- (void)saveOpenIMInfoWithAccount:(NSString *)account password:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:@"openIMAccount"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"openIMPwd"];
}

#pragma mark - dismissKeyboard

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loginButtonEvent:nil];
    return YES;
}

#pragma mark - unwindSegue

- (IBAction)back:(UIStoryboardSegue *)unwindSegue
{
//    UIViewController *sourceViewController = unwindSegue.sourceViewController;
}


@end
