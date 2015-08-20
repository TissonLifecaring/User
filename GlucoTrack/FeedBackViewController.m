//
//  FeedBackViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "FeedBackViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyTextView.h"
#import "UtilsMacro.h"


@interface FeedBackViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet MyTextView *textView;


@end

@implementation FeedBackViewController

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)aHud
{
    [aHud removeFromSuperview];
    aHud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"FeedBack", nil);
    [self configureTextView];
}

- (void)configureTextView
{
    self.textView.placeholder = NSLocalizedString(@"Leave your feedback.", nil) ;
    self.textView.placeholderColor = [UIColor lightGrayColor];
    [[self.textView layer] setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor]];
    [[self.textView layer] setBorderWidth:1.0];
}

- (IBAction)feedBack:(id)sender
{
    [self sendFeedBack];
}

- (void)sendFeedBack
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Sending FeedBack…", nil);
    [hud show:YES];
    
    if (![ParseData parseStringIsAvaliable:self.textView.text]) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Format is not avaliable", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    NSDictionary *parameters = @{@"method":@"sendFeedBack",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"content":self.textView.text,
                                 @"sendUser":[NSString userID]};
    
    [GCRequest userSendFeedbackWithParameters:parameters withBlock:^(NSDictionary *responseData, NSError *error) {
        
        hud.mode = MBProgressHUDModeText;
        NSString *ret_code = [responseData objectForKey:@"ret_code"];
        if (!error) {
            if ([ret_code isEqualToString:@"0"]) {
                hud.labelText = NSLocalizedString(@"Send Feedback Succeed", nil);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HUD_TIME_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }else{
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        
    }];
}

@end
