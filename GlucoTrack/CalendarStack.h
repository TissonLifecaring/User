//
//  CalendarStack.h
//  GlucoTrack
//
//  Created by Dan on 15-2-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemindItem.h"
@import UIKit;
@import EventKit;

typedef NS_ENUM(NSInteger, EKType){
    EKTypeDrug = 0,
    EKTypeDetection
};

@interface CalendarStack : NSObject

@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic) BOOL isAccessToEventStoreGranted;
@property (nonatomic) BOOL requestEventStoreGranted;

@property (strong, nonatomic) EKCalendar *drugsCalendar;
@property (strong, nonatomic) EKCalendar *detectionCalendar;

- (NSArray*)detectionCalendarsArray;
- (NSArray*)drugsCalendarsArray;

+ (instancetype)shareCalendarStack;
- (void)updateAuthorizationStatusToAccessEventStore;

- (void)fetchDrugRemindersWithCompletion:(void (^)(NSArray *reminders))completion;
- (void)fetchDetectionRemindersWithCompletion:(void (^)(NSArray *reminders))completion;

- (void)addReminderItem:(RemindItem *)item forCalendarType:(EKType)type;
- (void)deleteReminderForToDoItem:(RemindItem *)item forCalendarType:(EKType)type;
- (void)deleteReminder:(EKReminder *)reminder;
- (void)deleteAllReminderForCalendarType:(EKType)type completionBlock:(void(^)())completion;
- (void)saveReminder:(EKReminder *)reminder;

- (EKRecurrenceRule *)reminderRecurrenceRuleWithDays:(NSArray *)days;

@end
