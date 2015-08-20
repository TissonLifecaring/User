//
//  RecordPhoto.h
//  SugarNursing
//
//  Created by Dan on 15-1-4.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MedicalRecord;

@interface RecordPhoto : NSManagedObject

@property (nonatomic, retain) NSString * attachName;
@property (nonatomic, retain) NSString * attachPath;
@property (nonatomic, retain) MedicalRecord *medicalRecord;

@end
