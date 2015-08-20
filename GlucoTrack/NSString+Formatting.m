//
//  NSString+Formatting.m
//  SugarNursing
//
//  Created by Dan on 15-1-11.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NSString+Formatting.h"

@implementation NSString (Formatting)

+ (NSString *)formattingDateString:(NSString *)dateString From:(NSString *)format1 to:(NSString *)format2
{
    if (!dateString || [dateString isEqualToString:@""]|| !format1 || !format2) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format1];
    
    NSDate *date = [dateFormatter dateFromString:dateString];

    [dateFormatter setDateFormat:format2];
    
    return [dateFormatter stringFromDate:date];
    
}

+ (NSString *)formattingDate:(NSDate *)date to:(NSString *)format
{
    if (!date || !format ) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formattingUsage:(NSString *)usage
{
    NSDictionary *usageDic = @{NSLocalizedString(@"Oral", nil):@"01",
                               NSLocalizedString(@"Insulin", nil):@"02",
                               NSLocalizedString(@"Injection", nil):@"03"};
    if (!usage) {
        return nil;
    }
    
    if (![[usageDic allKeys] containsObject:usage]) {
        return nil;
    }
    
    return [usageDic valueForKey:usage];
    
}

+ (NSString *)formattingUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{NSLocalizedString(@"mg", nil):@"01",
                              NSLocalizedString(@"g", nil):@"02",
                              NSLocalizedString(@"grain", nil):@"03",
                              NSLocalizedString(@"slice", nil):@"04",
                              NSLocalizedString(@"unit", nil):@"05",
                              NSLocalizedString(@"ml", nil):@"06",
                              NSLocalizedString(@"piece", nil):@"07",
                              NSLocalizedString(@"bottle", nil):@"08"};
    
    if (!unit) {
        return nil;
    }
    if (![[unitDic allKeys] containsObject:unit]) {
        return nil;
    }
    
    return [unitDic valueForKey:unit];
}

+ (NSString *)formattingDietPeriod:(NSString *)period
{
    NSDictionary *periodDic = @{NSLocalizedString(@"breakfast", nil):@"01",
                                NSLocalizedString(@"lunch", nil):@"02",
                                NSLocalizedString(@"dinner", nil):@"03",
                                NSLocalizedString(@"snack", nil):@"04"};
    if (!period) {
        return nil;
    }
    if (![[periodDic allKeys] containsObject:period]) {
        return nil;
    }
    return [periodDic valueForKey:period];
    
}

+ (NSString *)formattingFoodUnit:(NSString *)unit
{
    NSDictionary *unitDic = @{NSLocalizedString(@"g", nil):@"01",
//                              NSLocalizedString(@"kg", nil):@"02",
                              };
    
    if (!unit) {
        return nil;
    }
    if (![[unitDic allKeys] containsObject:unit]) {
        return nil;
    }
    
    return [unitDic valueForKey:unit];
}

+ (NSString *)formattingFeeling:(NSString *)feeling
{
    NSDictionary *feelingDic = @{NSLocalizedString(@"正常", nil):@"01",
                                 NSLocalizedString(@"三多", nil):@"02",
                                 NSLocalizedString(@"乏力", nil):@"03",
                                 NSLocalizedString(@"腹痛", nil):@"04",
                                 NSLocalizedString(@"气短", nil):@"05",
                                 NSLocalizedString(@"胸闷", nil):@"06",
                                 NSLocalizedString(@"头晕", nil):@"07",
                                 NSLocalizedString(@"恶心", nil):@"08",
                                 NSLocalizedString(@"冷汗 ", nil):@"09",
                                 NSLocalizedString(@"其他", nil):@"10",
                                };
    if (!feeling) {
        return nil;
    }
    if (![[feelingDic allKeys] containsObject:feeling]) {
        return nil;
    }
    return [feelingDic valueForKey:feeling];
    
}

+ (NSString *)formattingDataSource:(NSString *)dataSource
{
    NSDictionary *sourceDic = @{@"GlucoTrack":@"01",
                                NSLocalizedString(@"others", nil):@"02"};
    
    if (!dataSource) {
        return nil;
    }
    if (![[sourceDic allKeys] containsObject:dataSource]) {
        return nil;
    }
    
    return [sourceDic valueForKey:dataSource];
    
}

@end
