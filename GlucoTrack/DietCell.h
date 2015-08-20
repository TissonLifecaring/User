//
//  DietCell.h
//  SugarNursing
//
//  Created by Dan on 14-12-2.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogTextField.h"

@interface DietCell : UITableViewCell


@property (weak, nonatomic) IBOutlet LogTextField *food;
@property (weak, nonatomic) IBOutlet LogTextField *weight;
@property (weak, nonatomic) IBOutlet LogTextField *calorie;
@property (weak, nonatomic) IBOutlet LogTextField *unit;

@end
