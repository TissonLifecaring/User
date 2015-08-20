//
//  CoreDataStack.h
//  SugarNursing
//
//  Created by Dan on 14-12-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSPersistentStore *store;

+ (instancetype)sharedCoreDataStack;
- (void)setupCoreData;
- (void)saveContext;

@end
