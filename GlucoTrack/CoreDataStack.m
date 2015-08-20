//
//  CoreDataStack.m
//  SugarNursing
//
//  Created by Dan on 14-12-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "CoreDataStack.h"
#import "UtilsMacro.h"

@implementation CoreDataStack

@synthesize context = _context;
@synthesize model = _model;
@synthesize coordinator = _coordinator;

#pragma mark - FILES
NSString *storeFilename = @"GlucoCare.sqlite";

#pragma mark - SHARED STACK

+ (instancetype)sharedCoreDataStack
{
    static CoreDataStack *_coreDataStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _coreDataStack  = [[CoreDataStack alloc] init];
        [_coreDataStack setupCoreData];
    });
    return _coreDataStack;
}

#pragma mark - PATHS

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoresDirectory{
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            DDLogDebug(@"Successfully create stores directory!");
        }
        else { DDLogDebug(@"Failed to create stores directory: %@",error);}
    }
    return storesDirectory;
}

- (NSURL *)storeURL{
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP

- (NSManagedObjectModel *)model {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_model != nil) {
        return _model;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];

    return _model;
}

- (NSPersistentStoreCoordinator *)coordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_coordinator != nil) {
        return _coordinator;
    }
    
    // Create the coordinator
    
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    return _coordinator;
}

- (NSPersistentStore *)store{
    if (_store != nil) {
        return _store;
    }
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@true,
                              NSInferMappingModelAutomaticallyOption:@false};
    _store = [[self coordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
    
    if (!_store) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DDLogDebug(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }else { DDLogDebug(@"Successfully added store: %@",_store);}
    
    return _store;
}

- (NSManagedObjectContext *)context {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_context != nil) {
        return _context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self coordinator];
    if (!coordinator) {
        return nil;
    }
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:coordinator];
    return _context;
}

- (void)setupCoreData
{
    [self context];
    [self store];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.context;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DDLogDebug(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
