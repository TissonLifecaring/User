//
//  RemindItem.h
//  GlucoTrack
//
//  Created by Dan on 15-2-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemindItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *notes;
@property (copy, nonatomic) NSDateComponents *startDateComponents;
@property (copy, nonatomic) NSDateComponents *dueDateComponents;
@property (copy, nonatomic) NSDateComponents *completionComponents;
@property (copy, nonatomic) NSDate *completionDate;

@property (strong, nonatomic) NSArray *days;

@end
