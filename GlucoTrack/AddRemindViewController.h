//
//  AddRemindViewController.h
//  GlucoTrack
//
//  Created by Ian on 15-2-27.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
@import EventKit;

typedef NS_ENUM(NSInteger, RemindType){
    RemindTypeAdd = 0,
    RemindTypeEdit
};

@interface AddRemindViewController : UIViewController

@property (strong, nonatomic) NSArray *reminders;

@property (nonatomic) RemindType remindType;

// Only used for Edit mode
@property (strong, nonatomic) EKReminder *reminder;

@end
