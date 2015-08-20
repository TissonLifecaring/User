//
//  NSString+Signatrue.m
//  SugarNursing
//
//  Created by Dan on 14-12-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSString+Signatrue.h"
#import "UtilsMacro.h"

@implementation NSString (Signatrue)

+ (NSString *)generateSigWithParameters:(NSDictionary *)paramters
{
    // Remove keys: method/sign/sessionId
    NSMutableArray *keys = [[paramters allKeys] mutableCopy];
    NSMutableArray *keysToRemove = [@[] mutableCopy];
    
    for (NSString *key in keys) {
        if ([key isEqualToString:@"method"]) {
            [keysToRemove addObject:key];
        }
        if ([key isEqualToString:@"sign"]) {
            [keysToRemove addObject:key];
        }
        if ([key isEqualToString:@"sessionId"]) {
            [keysToRemove addObject:key];
        }
        if ([[paramters objectForKey:key] isEqualToString:@""]) {
            [keysToRemove addObject:key];
        }
    }
    
    [keys removeObjectsInArray:keysToRemove];
    
    // SortedArray
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    __block NSString *joinString = @"";
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *akey = (NSString *)obj;
        NSString *keyAndValue = [akey stringByAppendingString:[paramters objectForKey:akey]];
        joinString = [joinString stringByAppendingString:keyAndValue];
    }];
    
    // SessionToken
    NSArray *fetchObjects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (0 == [fetchObjects count]) {
        return nil;
    }
    User *user = fetchObjects[0];
    
    joinString = [joinString stringByAppendingString:user.sessionToken];
    
    DDLogDebug(@"Parameter join string: %@",joinString);
    
    // MD5
    return [joinString md5];
}

@end
