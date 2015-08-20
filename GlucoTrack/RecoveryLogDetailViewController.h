//
//  RecoveryLogDetailViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-20.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"

typedef NS_ENUM(NSInteger, RecoveryLogType){
    RecoveryLogTypeDetect,
    RecoveryLogTypeDrug,
    RecoveryLogTypeDiet,
    RecoveryLogTypeExercise,
};

typedef NS_ENUM(NSInteger, RecoveryLogStatus){
    RecoveryLogStatusAdd,
    RecoveryLogStatusEdit,
};

@interface RecoveryLogDetailViewController : UIViewController

@property (assign) RecoveryLogType recoveryLogType;
@property (assign) RecoveryLogStatus recoveryLogStatus;

// recordLog 只在编辑模式下使用，在新增模式下不能使用！
@property (strong, nonatomic) RecordLog *recordLog;


@end
