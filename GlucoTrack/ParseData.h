//
//  ParseData.h
//  SugarNursing
//
//  Created by Dan on 15-1-5.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseData : NSObject

+ (id)parseDictionary:(NSDictionary *)data ForKeyPath:(NSString *)keyPath;

+ (BOOL)parseDateIsAvaliable:(NSDate *)date;

+ (BOOL)parseFuthureDateIsAvaliable:(NSDate *)date;

+ (BOOL)parseDateStringIsAvaliable:(NSString *)dateString format:(NSString *)format;

+ (BOOL)parseUserNameIsAvaliable:(NSString *)userName;

+ (BOOL)parsePasswordIsAvaliable:(NSString *)password;

+ (BOOL)parseStringIsAvaliable:(NSString *)string;

+ (BOOL)parseIsCurrentUser:(NSString *)userName;

+ (BOOL)parseCodeIsAvaliable:(NSString *)codeString;



@end
