//
//  DetectLog.h
//  GlucoTrack
//
//  Created by Dan on 15-2-2.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecordLog;

@interface DetectLog : NSManagedObject

@property (nonatomic, retain) NSString * dataSource;
@property (nonatomic, retain) NSString * detectId;
@property (nonatomic, retain) NSDate * detectTime;
@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSString * glucose;
@property (nonatomic, retain) NSString * hemoglobinef;
@property (nonatomic, retain) NSString * insertSource;
@property (nonatomic, retain) NSString * mealFlag;
@property (nonatomic, retain) NSString * remar;
@property (nonatomic, retain) NSString * selfSense;
@property (nonatomic, retain) NSString * serialNo;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) RecordLog *recordLog;

@end
