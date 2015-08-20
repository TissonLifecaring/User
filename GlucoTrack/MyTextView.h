//
//  MyTextView.h
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTextView : UITextView

@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)aNotification;

@end
