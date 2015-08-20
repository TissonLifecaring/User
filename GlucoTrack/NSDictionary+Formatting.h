//
//  NSDictionary+Formatting.h
//  SugarNursing
//
//  Created by Dan on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Formatting)

- (void)dateFormattingFromServer:(NSString *)dateFormatting ForKey:(NSString *)key;
- (void)dateFormattingToUser:(NSString *)dateFormatting ForKey:(NSString *)key;
- (void)dateFormattingFromUser:(NSString *)userDateFormatting ToServer:(NSString *)serverDateFormatting ForKey:(NSString *)key;
- (void)sexFormattingToUserForKey:(NSString *)key;
- (void)sexFormattingToServerForKey:(NSString *)key;
- (void)serverLevelFormattingToUserForKey:(NSString *)key;
- (void)medicineUnitsFormattingToUserForKey:(NSString *)key;
- (void)medicineUsageFormattingToUserForKey:(NSString *)key;
- (void)eatPeriodFormattingToUserForKey:(NSString *)key;
- (void)eatUnitsFormattingToUserForKey:(NSString *)key;
- (void)feelingFormattingToUserForKey:(NSString *)key;
- (void)dataSourceFormattingToUserForKey:(NSString *)key;


@end
