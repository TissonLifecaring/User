//
//  AdviseAttach.h
//  GlucoTrack
//
//  Created by Ian on 15/6/11.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advise;

@interface AdviseAttach : NSManagedObject

@property (nonatomic, retain) NSString * attachName;
@property (nonatomic, retain) NSString * attachPath;
@property (nonatomic, retain) Advise *advise;

@end
