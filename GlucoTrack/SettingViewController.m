//
//  SettingViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "SettingViewController.h"
#import "UIStoryboard+Storyboards.h"
#import "VerificationViewController.h"
#import "CustomLabel.h"


@interface SettingViewController ()

@property (strong, nonatomic) UIActionSheet *sheet;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Setting", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self showVerificationVC];
            break;
        case 1:
            break;
//        case 3:
//            [self showsFontSizeSheet];
//            break;
    }
}

- (void)showVerificationVC
{
    VerificationViewController *verificationVC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:@"Verification"];
    verificationVC.title = NSLocalizedString(@"Reset", nil);
    verificationVC.verifiedType = VerifiedTypeInReset;
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        // conditionly check for any version >= iOS 8
        [self showViewController:verificationVC sender:nil];

    } else
    {
        // iOS 7 or below
        [self.navigationController pushViewController:verificationVC animated:YES];
    }
    
    
}

#pragma mark - ActionSheet

- (void)showsUnitsSheet
{
    self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择单位" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"mmol/L",@"mg/dL", nil];
    self.sheet.tag = 0;
    [self.sheet showInView:self.view];
}

- (void)showsFontSizeSheet
{
    self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择字体大小" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"12px",@"14px",@"16px", nil];
    self.sheet.tag = 1;
    [self.sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 0:
        {
            if (buttonIndex <= 0) {
                return;
            }else {
                self.unitLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
            }
            break;
        }
        case 1:
        {
            if (buttonIndex <= 0) {
                return;
            }else {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:[actionSheet buttonTitleAtIndex:buttonIndex].integerValue forKey:@"USER_FONTSIZE"];
                [[UILabel appearance] setFont:[UIFont systemFontOfSize:[actionSheet buttonTitleAtIndex:buttonIndex].integerValue]];
            }
            break;
        }
        default:
            break;
    }
    
    
}


- (IBAction)back:(UIStoryboardSegue *)segue
{
    
}


@end
