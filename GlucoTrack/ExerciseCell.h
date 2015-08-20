//
//  ExerciseCell.h
//  SugarNursing
//
//  Created by Dan on 14-12-2.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogTextField.h"

@interface ExerciseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LogTextField *exerciseName;
@property (weak, nonatomic) IBOutlet LogTextField *time;
@property (weak, nonatomic) IBOutlet LogTextField *unit;
@property (weak, nonatomic) IBOutlet LogTextField *calorie;

@end
