//
//  OtherMappingInfo.h
//  GlucoTrack
//
//  Created by Ian on 15/7/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyDoctor;

@interface OtherMappingInfo : NSManagedObject

@property (nonatomic, retain) NSString * otherAccount;
@property (nonatomic, retain) NSString * otherName;
@property (nonatomic, retain) NSString * otherPwd;
@property (nonatomic, retain) MyDoctor *myDoctor;

@end
