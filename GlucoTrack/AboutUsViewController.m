//
//  AboutUsViewController.m
//  SugarNursing
//
//  Created by Dan on 15-1-9.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AboutUsViewController.h"
#import "AppVersionHelper.h"

@interface AboutUsViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title =  NSLocalizedString(@"About Us", nil);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Version", nil),version];
}

- (IBAction)versionUpdate:(id)sender
{
    AppVersionHelper *helper = [AppVersionHelper shareVersionHelper];
    [helper checkAppVersion];
    
}



@end
