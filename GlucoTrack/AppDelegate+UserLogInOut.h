//
//  AppDelegate+UserLogInOut.h
//  SugarNursing
//
//  Created by Dan on 14-11-6.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AppDelegate.h"
#import "UtilsMacro.h"


@interface AppDelegate (UserLogInOut)

+ (void)userLogIn;
+ (void)userLogOut;

//登陆阿里百川
+ (void)loginIMWithSuccessBlock:(void(^)())successBlock failedBlock:(void(^)())failedBlock;

@end
