//
//  MedicalRecord.h
//  SugarNursing
//
//  Created by Dan on 15-1-7.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecordPhoto, UserID;

@interface MedicalRecord : NSManagedObject

@property (nonatomic, retain) NSString * diagHosp;
@property (nonatomic, retain) NSString * diagTime;
@property (nonatomic, retain) NSString * mediHistId;
@property (nonatomic, retain) NSString * mediName;
@property (nonatomic, retain) NSString * mediRecord;
@property (nonatomic, retain) NSString * treatMent;
@property (nonatomic, retain) NSString * treatPlan;
@property (nonatomic, retain) NSOrderedSet *recordPhoto;
@property (nonatomic, retain) UserID *userid;
@end

@interface MedicalRecord (CoreDataGeneratedAccessors)

- (void)insertObject:(RecordPhoto *)value inRecordPhotoAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRecordPhotoAtIndex:(NSUInteger)idx;
- (void)insertRecordPhoto:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRecordPhotoAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRecordPhotoAtIndex:(NSUInteger)idx withObject:(RecordPhoto *)value;
- (void)replaceRecordPhotoAtIndexes:(NSIndexSet *)indexes withRecordPhoto:(NSArray *)values;
- (void)addRecordPhotoObject:(RecordPhoto *)value;
- (void)removeRecordPhotoObject:(RecordPhoto *)value;
- (void)addRecordPhoto:(NSOrderedSet *)values;
- (void)removeRecordPhoto:(NSOrderedSet *)values;
@end
