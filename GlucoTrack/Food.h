//
//  Food.h
//  GlucoTrack
//
//  Created by Dan on 15-1-19.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietLog;

@interface Food : NSManagedObject

@property (nonatomic, retain) NSString * calorie;
@property (nonatomic, retain) NSString * food;
@property (nonatomic, retain) NSString * sort;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSString * weight;
@property (nonatomic, retain) DietLog *dietLog;

@end
