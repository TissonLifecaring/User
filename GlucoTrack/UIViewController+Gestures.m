//
//  UIViewController+Gestures.m
//  SugarNursing
//
//  Created by Dan on 14-11-15.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "UIViewController+Gestures.h"

@implementation UIViewController (Gestures)


#pragma mark - TapGestures

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}


@end
