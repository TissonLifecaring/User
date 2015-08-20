//
//  NSDictionary+LowerCaseKey.m
//  SugarNursing
//
//  Created by Dan on 14-12-29.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSDictionary+LowerCaseKey.h"
#import "UtilsMacro.h"

@implementation NSDictionary (LowerCaseKey)

- (NSDictionary *)keysLowercased
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        DDLogDebug(@"The data to lowercased is not a NSDictionary.");
        return nil;
    }
    
    NSMutableDictionary *aDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    aDictionary = [self enumerateKeysAndObjectsToLowerCase:self];
    return aDictionary;
}

- (NSMutableDictionary *)enumerateKeysAndObjectsToLowerCase:(NSDictionary *)dic
{
    NSMutableDictionary *aDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [self enumerateKeysAndObjectsToLowerCase:obj];
        }
        NSString *aKey = (NSString *)key;
        [aDic setValue:obj forKey:aKey.lowercaseString];
        
    }];
    return aDic;
}

@end
