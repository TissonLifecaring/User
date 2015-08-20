//
//  NSManagedObject+Finders.h
//  SugarNursing
//
//  Created by Dan on 14-12-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Finders)

+ (instancetype)createEntityInContext:(NSManagedObjectContext *)context;
- (BOOL)deleteEntityInContext:(NSManagedObjectContext *)context;

+ (NSArray *) findAllInContext:(NSManagedObjectContext *)context;

+ (NSArray *) findAllWithPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)context;

+ (NSArray *) findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *)fetchAllWithDelegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)group sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchPredicate delegate:(id<NSFetchedResultsControllerDelegate>)delegate incontext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *)fetchController:(NSFetchRequest *)request delegate:(id<NSFetchedResultsControllerDelegate>)delegate useFileCache:(BOOL)useFileCache groupedBy:(NSString *)groupKeyPath inContext:(NSManagedObjectContext *)context;

@end
