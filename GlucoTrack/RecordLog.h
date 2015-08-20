//
//  RecordLog.h
//  GlucoTrack
//
//  Created by Dan on 15-2-2.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DetectLog, DietLog, DrugLog, ExerciseLog, UserID;

@interface RecordLog : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * logType;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) DetectLog *detectLog;
@property (nonatomic, retain) DietLog *dietLog;
@property (nonatomic, retain) DrugLog *drugLog;
@property (nonatomic, retain) ExerciseLog *exerciseLog;
@property (nonatomic, retain) UserID *userid;

@end
