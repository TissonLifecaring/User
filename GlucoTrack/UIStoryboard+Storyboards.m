//
//  UIStoryboard+Storyboards.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "UIStoryboard+Storyboards.h"

@implementation UIStoryboard (Storyboards)

+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

+ (UIStoryboard *)memberCenterStoryboard
{
    return [UIStoryboard storyboardWithName:@"MemberCenter" bundle:nil];
}

+ (UIStoryboard *)loginStoryboard
{
    return [UIStoryboard storyboardWithName:@"Login" bundle:nil];
}

+ (UIStoryboard *)testTracker
{
    return [UIStoryboard storyboardWithName:@"TestTracker" bundle:nil];
}

+ (UIStoryboard *)recoveryLog
{
    return [UIStoryboard storyboardWithName:@"RecoveryLog" bundle:nil];
}

+ (UIStoryboard *)controlEffect
{
    return [UIStoryboard storyboardWithName:@"ControlEffect" bundle:nil];
}

+ (UIStoryboard *)myRemind
{
    return [UIStoryboard storyboardWithName:@"MyRemind" bundle:nil];
}

+ (UIStoryboard *)advise
{
    return [UIStoryboard storyboardWithName:@"Advise" bundle:nil];
}

+ (UIStoryboard *)myService
{
    return [UIStoryboard storyboardWithName:@"MyService" bundle:nil];
}

+ (UIStoryboard *)consultExpert
{
    return [UIStoryboard storyboardWithName:@"ConsultExpert" bundle:nil];
}


@end
