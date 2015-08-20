//
//  PatientDataViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"

@interface PatientDataViewController : UITableViewController

@property (strong, nonatomic) MedicalRecord *medicalRecord;

@end
