//
//  GCHttpClient.m
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "GCHttpClient.h"


@implementation GCHttpClient

+ (instancetype)sharedClient
{
    static GCHttpClient *_shareClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = TIMEOUT_INTERVAL_FORREQUEST;
        
        _shareClient = [[GCHttpClient alloc] initWithBaseURL:[NSURL URLWithString:GCUserURLString
                                                              ] sessionConfiguration:configuration];
        _shareClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
        
    });
    
    return _shareClient;
}

@end
