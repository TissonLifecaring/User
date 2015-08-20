//
//  CalendarStack.m
//  GlucoTrack
//
//  Created by Dan on 15-2-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "CalendarStack.h"
#import "UtilsMacro.h"

@interface CalendarStack (){
}

@end

@implementation CalendarStack

#pragma mark -- singlon

+ (instancetype)shareCalendarStack
{
    static CalendarStack *_calendarStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _calendarStack = [[CalendarStack alloc] init];
        [_calendarStack updateAuthorizationStatusToAccessEventStore];
        [_calendarStack requestEventStoreGranted];
    });
    return _calendarStack;
}

#pragma makr -- EkEventStore

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void)updateAuthorizationStatusToAccessEventStore
{
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:{
            self.isAccessToEventStoreGranted = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied", nil) message:NSLocalizedString(@"This app doesn't have access to your Reminders.", nil) delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
            [alertView show];
            break;
        }
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            break;
        case EKAuthorizationStatusNotDetermined:{
            __weak CalendarStack *weakSelf = self;
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
                weakSelf.isAccessToEventStoreGranted = granted;
            }];
            break;
        }
    }
}

- (void)requestAccessToEventStore
{
    if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if (granted) {
                self.requestEventStoreGranted = YES;
            }else self.requestEventStoreGranted = NO;
        }];
    }
}

#pragma mark - Calendar

- (NSArray *)drugsCalendarsArray
{
    NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
    NSString *calendarTitle = NSLocalizedString(@"GluCare--DrugReminder", nil);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@",calendarTitle];
    NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
    return filtered;
    
}

- (EKCalendar *)drugsCalendar
{
    if (!_drugsCalendar) {
        
        if ([[self drugsCalendarsArray] count]) {
            _drugsCalendar = [[self drugsCalendarsArray] firstObject];
        }else{
            _drugsCalendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            _drugsCalendar.title = NSLocalizedString(@"GluCare--DrugReminder", nil);
//            _drugsCalendar.source = self.eventStore.defaultCalendarForNewReminders.source;
            
            EKSource *localSource;
            
            for (EKSource *source in self.eventStore.sources) {
                //                if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCould"]) {
                //                    localSource = source;
                //                }
                if (source.sourceType == EKSourceTypeCalDAV) {
                    localSource = source;
                    break;
                }
            }
            
            if (localSource == nil) {
                _drugsCalendar.source = self.eventStore.defaultCalendarForNewReminders.source;
            }else{
                _drugsCalendar.source = localSource;
                
            }
            
            NSError *error = nil;
            BOOL calendarSuccess = [self.eventStore saveCalendar:_drugsCalendar commit:YES error:&error];
            if (!calendarSuccess) {
                // Handle error
            }else DDLogDebug(@"Saveing DrugCalendar Succeed!");
            
        }
    }
    
    return _drugsCalendar;
}

- (NSArray *)detectionCalendarsArray
{
    NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
    
    NSString *calendarTitle = NSLocalizedString(@"GluCare--DetectionReminder", nil);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@",calendarTitle];
    NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
    return filtered;
}

- (EKCalendar *)detectionCalendar
{
    if (!_detectionCalendar) {
        
        if ([[self detectionCalendarsArray] count]) {
            _detectionCalendar = [[self detectionCalendarsArray] firstObject];
        }else{
            _detectionCalendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            _detectionCalendar.title = NSLocalizedString(@"GluCare--DetectionReminder", nil);
            
            EKSource *localSource;
            
            for (EKSource *source in self.eventStore.sources) {
//                if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCould"]) {
//                    localSource = source;
//                }
                if (source.sourceType == EKSourceTypeCalDAV) {
                    localSource = source;
                    break;
                }
            }
            
            if (localSource == nil) {
                _detectionCalendar.source = self.eventStore.defaultCalendarForNewReminders.source;
            }else{
                _detectionCalendar.source = localSource;

            }
            
            
            
            NSError *error = nil;
            BOOL calendarSuccess = [self.eventStore saveCalendar:_detectionCalendar commit:YES error:&error];
            if (!calendarSuccess) {
                // Handle error
                
            }else DDLogDebug(@"Saveing DetectionCalendar Succeed!");
            
        }
    }

    return _detectionCalendar;
}

#pragma mark -- Fetch Reminders


- (void)fetchDrugRemindersWithCompletion:(void (^)(NSArray *))completion
{
    if (self.isAccessToEventStoreGranted) {
        NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:@[self.drugsCalendar]];
        NSMutableArray *dReminders = [@[] mutableCopy];
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            
            @autoreleasepool {
                for (EKReminder *aReminder in reminders) {
                    if (!aReminder.isCompleted ) {
                        [dReminders addObject:aReminder];
                    }
//                    NSCalendar *aCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//                    NSDate *dueDate = [aCalendar dateFromComponents:aReminder.dueDateComponents];
//                    
//                    if (aReminder.isCompleted || [dueDate compare:[NSDate date]] < 1) {
//                        [self deleteReminder:aReminder];
//                    }else{
                }
            }
            
            
            if (completion) {
                completion(dReminders);
            }
        }];
        
    
    }
}

- (void)fetchDetectionRemindersWithCompletion:(void (^)(NSArray *))completion
{
    if (self.isAccessToEventStoreGranted) {
        NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:@[self.detectionCalendar]];
        NSMutableArray *dReminders = [@[] mutableCopy];
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            
            @autoreleasepool {
                for (EKReminder *aReminder in reminders) {
                    [dReminders addObject:aReminder];
                }
            }
            
            if (completion) {
                completion(dReminders);
            }
            
        }];
        

    }
}

#pragma mark -- Add/Delete reminders to calendar

- (void)addReminderItem:(RemindItem *)item forCalendarType:(EKType)type
{
    if (!self.isAccessToEventStoreGranted) {
        return;
    }
    
    switch (type) {
        case EKTypeDrug:
        {
            EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
            reminder.title = item.title;
            reminder.notes = item.notes;
            reminder.startDateComponents = item.startDateComponents;
            reminder.dueDateComponents = item.dueDateComponents;
            reminder.calendar = self.drugsCalendar;
            reminder.timeZone = [NSTimeZone systemTimeZone];

            EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:0];
            [reminder addAlarm:alarm];
            
            EKRecurrenceRule *rule = [self reminderRecurrenceRuleWithDays:item.days];
            if (rule) {
                [reminder addRecurrenceRule:rule];
            }
            
            [self saveReminder:reminder];
            break;
        }
        case EKTypeDetection:
        {
            EKRecurrenceRule *rule = [self reminderRecurrenceRuleWithDays:item.days];
            if (!rule) {
                return;
            }
            
            EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
            reminder.title = item.title;
            reminder.notes = item.notes;
            reminder.startDateComponents = item.startDateComponents;
            reminder.dueDateComponents = item.dueDateComponents;
            reminder.calendar = self.detectionCalendar;
            
            EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:0];
            [reminder addAlarm:alarm];
            
            //!important rule need to add after alarm
            [reminder addRecurrenceRule:rule];
            
            [self saveReminder:reminder];
            
            break;
        }
    }
    
}

- (EKRecurrenceRule *)reminderRecurrenceRuleWithDays:(NSArray *)days
{
    NSMutableArray *daysOfWeek = [NSMutableArray arrayWithCapacity:7];
    [days enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL b = [(NSNumber *)obj boolValue];
        if (b) {
            [daysOfWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:(idx+1)]];
        }
    }];
    
    if ([daysOfWeek count] == 0) {
        return nil;
    }
    
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 daysOfTheWeek:daysOfWeek daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:nil];
    return rule;
}

- (void)deleteReminder:(EKReminder *)reminder
{
    NSError *error;
    BOOL success = [self.eventStore removeReminder:reminder commit:YES error:&error];
    if (!success) {
        //Handle error
        DDLogDebug(@"Delete Reminder Error! %@",[error localizedFailureReason]);
    }else DDLogDebug(@"Suceessfully delete reminder.");
    
    NSError *commmitErr = nil;
    BOOL commitSuccess = [self.eventStore commit:&commmitErr];
    if (!commitSuccess) {
        //Handle error
    }
}

- (void)deleteReminderForToDoItem:(RemindItem *)item forCalendarType:(EKType)type
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@",item.startDateComponents];
    __block NSArray *results;
    switch (type) {
        case EKTypeDrug:
        {
            [self fetchDrugRemindersWithCompletion:^(NSArray *reminders) {
                results = [reminders filteredArrayUsingPredicate:predicate];
            }];
            break;
        }
        case EKTypeDetection:
        {
            [self fetchDetectionRemindersWithCompletion:^(NSArray *reminders) {
                results = [reminders filteredArrayUsingPredicate:predicate];
            }];
        }
            break;
    }
    
    if ([results count]) {
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self deleteReminder:obj];
        }];
        
        NSError *commmitErr = nil;
        BOOL success = [self.eventStore commit:&commmitErr];
        if (!success) {
            //Handle error
        }
    }
}

- (void)deleteAllReminderForCalendarType:(EKType)type completionBlock:(void (^)())completion
{
    if (self.isAccessToEventStoreGranted) {
        
        NSPredicate *predicate;
        switch (type) {
            case EKTypeDrug:
            {
                 predicate = [self.eventStore predicateForRemindersInCalendars:@[self.drugsCalendar]];
                break;
            }
            case EKTypeDetection:
            {
                predicate = [self.eventStore predicateForRemindersInCalendars:@[self.detectionCalendar]];
                break;
            }
        }

        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            
            @autoreleasepool {
                for (EKReminder *aReminder in reminders) {
                    [self deleteReminder:aReminder];
                }
            }
            
            if (completion) {
                completion();
            }
            
        }];
        
        
    }
        
}

- (void)saveReminder:(EKReminder *)reminder
{
    NSError *error = nil;
    BOOL success = [self.eventStore saveReminder:reminder commit:YES error:&error];
    if (!success) {
        //Handle error
        DDLogDebug(@"Save Reminder Error: %@",[error debugDescription]);
    }else DDLogDebug(@"Suceessfully save reminder.");
    
    NSError *commitError = nil;
    BOOL commitSuccess = [self.eventStore commit:&commitError];
    if (!commitSuccess) {
        //Handle error
        DDLogDebug(@"Commit Reminder Error %@",[error debugDescription]);
    }
}

@end
