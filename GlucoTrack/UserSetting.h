//
//  UserSetting.h
//  GlucoTrack
//
//  Created by Dan on 15-1-29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserID;

@interface UserSetting : NSManagedObject

@property (nonatomic, retain) NSString * fontSize;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSNumber * detect;
@property (nonatomic, retain) NSNumber * drug;
@property (nonatomic, retain) NSNumber * diet;
@property (nonatomic, retain) NSNumber * exercise;
@property (nonatomic, retain) UserID *userid;

@end
