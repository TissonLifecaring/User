//
//  Advise.h
//  GlucoTrack
//
//  Created by Ian on 15/6/18.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AdviseAttach, UserID;

@interface Advise : NSManagedObject

@property (nonatomic, retain) NSString * adviceId;
@property (nonatomic, retain) NSString * adviceTime;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * exptId;
@property (nonatomic, retain) NSString * exptName;
@property (nonatomic, retain) NSOrderedSet *adviseAttach;
@property (nonatomic, retain) UserID *userid;
@end

@interface Advise (CoreDataGeneratedAccessors)

- (void)insertObject:(AdviseAttach *)value inAdviseAttachAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAdviseAttachAtIndex:(NSUInteger)idx;
- (void)insertAdviseAttach:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAdviseAttachAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAdviseAttachAtIndex:(NSUInteger)idx withObject:(AdviseAttach *)value;
- (void)replaceAdviseAttachAtIndexes:(NSIndexSet *)indexes withAdviseAttach:(NSArray *)values;
- (void)addAdviseAttachObject:(AdviseAttach *)value;
- (void)removeAdviseAttachObject:(AdviseAttach *)value;
- (void)addAdviseAttach:(NSOrderedSet *)values;
- (void)removeAdviseAttach:(NSOrderedSet *)values;
@end
