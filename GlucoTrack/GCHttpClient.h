//
//  GCHttpClient.h
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "NetworkURLMacro.h"


@interface GCHttpClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end

