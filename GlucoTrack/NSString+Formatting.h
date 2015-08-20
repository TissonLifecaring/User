//
//  NSString+Formatting.h
//  SugarNursing
//
//  Created by Dan on 15-1-11.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Formatting)

+ (NSString *)formattingDateString:(NSString *)dateString From:(NSString *)format1 to:(NSString *)format2;

+ (NSString *)formattingDate:(NSDate *)date to:(NSString *)format;

+ (NSString *)formattingUsage:(NSString *)usage;

+ (NSString *)formattingUnit:(NSString *)unit;

+ (NSString *)formattingDietPeriod:(NSString *)period;

+ (NSString *)formattingFoodUnit:(NSString *)unit;

+ (NSString *)formattingFeeling:(NSString *)feeling;

+ (NSString *)formattingDataSource:(NSString *)dataSource;

@end
