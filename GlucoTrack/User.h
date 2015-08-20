//
//  User.h
//  SugarNursing
//
//  Created by Dan on 15-1-3.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSString * passWord;
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * sessionToken;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;

@end
