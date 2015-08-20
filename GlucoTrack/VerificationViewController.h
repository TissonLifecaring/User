//
//  VerificationViewController.h
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"


typedef NS_ENUM(NSInteger, VerifiedType) {
    VerifiedTypeRegister = 0,
    VerifiedTypeReset = 1,
    VerifiedTypeInReset = 2,
    VerifiedTypeRebind = 3,
};

@interface VerificationViewController : UITableViewController

@property (assign, nonatomic) VerifiedType verifiedType;
@property (weak, nonatomic) IBOutlet CustomLabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *verifiedLabel;


@end
