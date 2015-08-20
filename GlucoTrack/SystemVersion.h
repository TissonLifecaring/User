//
//  SystemVersion.h
//  SugarNursing
//
//  Created by Dan on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#ifndef SugarNursing_SystemVersion_h
#define SugarNursing_SystemVersion_h

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#endif
