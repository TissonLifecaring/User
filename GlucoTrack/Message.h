//
//  Message.h
//  SugarNursing
//
//  Created by Dan on 15-1-9.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserID;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * dealTime;
@property (nonatomic, retain) NSString * direct;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * sendTime;
@property (nonatomic, retain) NSString * stat;
@property (nonatomic, retain) UserID *userid;

@end
