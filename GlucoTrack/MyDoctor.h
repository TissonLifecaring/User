//
//  MyDoctor.h
//  GlucoTrack
//
//  Created by Ian on 15/7/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OtherMappingInfo;

@interface MyDoctor : NSManagedObject

@property (nonatomic, retain) NSString * areaId;
@property (nonatomic, retain) NSString * mobileZone;
@property (nonatomic, retain) NSString * mobilePhone;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * identifyCard;
@property (nonatomic, retain) NSString * hospital;
@property (nonatomic, retain) NSString * headimageUrl;
@property (nonatomic, retain) NSString * exptName;
@property (nonatomic, retain) NSString * exptId;
@property (nonatomic, retain) NSString * expertLevel;
@property (nonatomic, retain) NSString * engName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * departmentId;
@property (nonatomic, retain) NSString * centerId;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * registerTime;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * skilled;
@property (nonatomic, retain) OtherMappingInfo *otherMappintInfo;

@end
