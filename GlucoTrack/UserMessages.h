//
//  UserMessages.h
//  GlucoTrack
//
//  Created by Dan on 15-3-9.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserID;

@interface UserMessages : NSManagedObject

@property (nonatomic, retain) NSString * suggest;
@property (nonatomic, retain) NSString * agentMsg;
@property (nonatomic, retain) UserID *userid;

@end
