//
//  TermsOfServiceViewController.m
//  SugarNursing
//
//  Created by Dan on 15-1-9.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "TermsOfServiceViewController.h"
#import <SSPullToRefresh.h>

#define SERVICE_HTML @"http://120.24.60.25:8081/lcp-laop/service_terms.html"

@interface TermsOfServiceViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermsOfServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Terms of service", nil);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:SERVICE_HTML]];

    [self.webView loadRequest:request];
}



@end
