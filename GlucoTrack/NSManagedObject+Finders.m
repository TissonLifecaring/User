//
//  NSManagedObject+Finders.m
//  SugarNursing
//
//  Created by Dan on 14-12-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSManagedObject+Finders.h"
#import "CoreDataStack.h"
#import "UtilsMacro.h"

@implementation NSManagedObject (Finders)

+ (instancetype)createEntityInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [self entityDescriptionInContext:context];
    return [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
}

- (BOOL)deleteEntityInContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSManagedObject *inContext = [context existingObjectWithID:[self objectID] error:&error];
    if (error) {
        DDLogDebug(@"Unable to Delete %@ entity. Error: %@",inContext, [error localizedDescription]);
    }
    
    if (context) {
        [context deleteObject:inContext];
    }
    return YES;
    
}

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    return [self executeFetchRequest:request inContext:context];
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:searchPredicate];
    return [self executeFetchRequest:request inContext:context];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchPredicate inContext:context];
    return [self executeFetchRequest:request inContext:context];
    
}

+ (NSFetchedResultsController *)fetchAllWithDelegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    NSFetchedResultsController *controller = [self fetchController:request delegate:delegate useFileCache:NO groupedBy:nil inContext:context];
    
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        DDLogDebug(@"FetchedResultsController fetched error: %@",[error localizedDescription]);
    }
    
    return controller;
}

+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)group sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchPredicate delegate:(id<NSFetchedResultsControllerDelegate>)delegate incontext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchPredicate inContext:context];
    
    NSFetchedResultsController *controller = [self fetchController:request delegate:delegate useFileCache:NO groupedBy:group inContext:context];
    
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        DDLogDebug(@"FetchedResultsController fetched error: %@",[error localizedDescription]);
    }
    
    return controller;
}

+ (NSFetchedResultsController *)fetchController:(NSFetchRequest *)request delegate:(id<NSFetchedResultsControllerDelegate>)delegate useFileCache:(BOOL)useFileCache groupedBy:(NSString *)groupKeyPath inContext:(NSManagedObjectContext *)context
{
    NSString *cacheName = useFileCache ? [NSString stringWithFormat:@"GCCache-%@",NSStringFromClass([self class])] : nil;
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:groupKeyPath cacheName:cacheName];
    controller.delegate = delegate;
    return controller;
}



+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        
        if (context) {
            results = [context executeFetchRequest:request error:&error];
        }
        
        if (results == nil) {
            DDLogDebug(@"Execute FetchRequest Error: %@",[error localizedDescription]);
        }
        
    }];
    
    return results;
}

+ (NSString *)entityName
{
    NSString *entityName;
    if ([entityName length] == 0) {
        entityName = NSStringFromClass(self);
    }
    return entityName;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    NSString *entityName = [self entityName];
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
}


+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityDescriptionInContext:context]];
    return fetchRequest;
}

+ (NSFetchRequest *)requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    
    if (searchPredicate) {
        request.predicate = searchPredicate;
    }
    
    if (sortTerm) {
        
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithCapacity:2];
        NSArray * sortKeys = [sortTerm componentsSeparatedByString:@","];
        for (__strong NSString *sortKey in sortKeys) {
            NSArray *sortComponents = [sortKey componentsSeparatedByString:@":"];
            if (sortComponents.count > 1) {
                NSNumber *customAscending = sortComponents.lastObject;
                ascending = customAscending.boolValue;
                sortKey = sortComponents[0];
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
            [sortDescriptors addObject:sortDescriptor];
        }
        [request setSortDescriptors:sortDescriptors];
    }
    
    
    return request;
}

@end
