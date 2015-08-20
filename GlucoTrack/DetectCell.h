//
//  DetectCell.h
//  GlucoTrack
//
//  Created by Dan on 15-1-26.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogTextField.h"

@interface DetectCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LogTextField *detectType;
@property (weak, nonatomic) IBOutlet LogTextField *detectField;
@property (weak, nonatomic) IBOutlet LogTextField *detectUnit;

@end
