//
//  ExerciseLog.h
//  GlucoTrack
//
//  Created by Dan on 15-2-2.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecordLog;

@interface ExerciseLog : NSManagedObject

@property (nonatomic, retain) NSString * calorie;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSString * sportId;
@property (nonatomic, retain) NSString * sportName;
@property (nonatomic, retain) NSString * sportPeriod;
@property (nonatomic, retain) NSDate * sportTime;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) RecordLog *recordLog;

@end
