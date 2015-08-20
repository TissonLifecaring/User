//
//  MedicalHistoryEditViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"

typedef enum {
    MedicalHistoryTypeEdit,
    MedicalHistoryTypeAdd,
} MedicalHistoryType;

@interface MedicalRecordEditViewController : UITableViewController

@property (strong, nonatomic) MedicalRecord *medicalRecord;
@property (assign) MedicalHistoryType medicalHistoryType;

@end
