//
//  DietLog.h
//  GlucoTrack
//
//  Created by Dan on 15-3-10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Food, RecordLog;

@interface DietLog : NSManagedObject

@property (nonatomic, retain) NSString * calorie;
@property (nonatomic, retain) NSString * eatId;
@property (nonatomic, retain) NSString * eatPeriod;
@property (nonatomic, retain) NSDate * eatTime;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * glucose;
@property (nonatomic, retain) NSOrderedSet *foodList;
@property (nonatomic, retain) RecordLog *recordLog;
@end

@interface DietLog (CoreDataGeneratedAccessors)

- (void)insertObject:(Food *)value inFoodListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFoodListAtIndex:(NSUInteger)idx;
- (void)insertFoodList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFoodListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFoodListAtIndex:(NSUInteger)idx withObject:(Food *)value;
- (void)replaceFoodListAtIndexes:(NSIndexSet *)indexes withFoodList:(NSArray *)values;
- (void)addFoodListObject:(Food *)value;
- (void)removeFoodListObject:(Food *)value;
- (void)addFoodList:(NSOrderedSet *)values;
- (void)removeFoodList:(NSOrderedSet *)values;
@end
