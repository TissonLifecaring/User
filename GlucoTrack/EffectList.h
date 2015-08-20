//
//  EffectList.h
//  GlucoCare
//
//  Created by Dan on 15-1-13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ControlEffect;

@interface EffectList : NSManagedObject

@property (nonatomic, retain) NSString * avg;
@property (nonatomic, retain) NSString * detectCount;
@property (nonatomic, retain) NSString * max;
@property (nonatomic, retain) NSString * min;
@property (nonatomic, retain) NSString * overtopCount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) ControlEffect *controlEffect;

@end
