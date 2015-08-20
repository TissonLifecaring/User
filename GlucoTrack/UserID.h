//
//  UserID.h
//  GlucoTrack
//
//  Created by Ian on 15/7/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advise, ControlEffect, MedicalRecord, Message, RecordLog, UserInfomation, UserMessages, UserSetting;

@interface UserID : NSManagedObject

@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) Advise *advise;
@property (nonatomic, retain) ControlEffect *controlEffect;
@property (nonatomic, retain) MedicalRecord *medicalRecord;
@property (nonatomic, retain) Message *message;
@property (nonatomic, retain) RecordLog *recordLog;
@property (nonatomic, retain) UserInfomation *userInfomation;
@property (nonatomic, retain) UserMessages *userMessages;
@property (nonatomic, retain) UserSetting *userSetting;

@end
