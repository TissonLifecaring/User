//
//  MedicateCell.h
//  SugarNursing
//
//  Created by Dan on 14-12-2.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogTextField.h"

@interface MedicateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LogTextField *drugField;
@property (weak, nonatomic) IBOutlet LogTextField *usageField;
@property (weak, nonatomic) IBOutlet LogTextField *dosageField;
@property (weak, nonatomic) IBOutlet LogTextField *unitField;

@end
