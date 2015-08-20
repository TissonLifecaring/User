//
//  NSDictionary+Formatting.m
//  SugarNursing
//
//  Created by Dan on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSDictionary+Formatting.h"
#import "UtilsMacro.h"

@implementation NSDictionary (Formatting)

- (void)dateFormattingFromServer:(NSString *)dateFormatting ForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatting];
    NSString *dateString = [NSString stringWithFormat:@"%@",self[key]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [self setValue:date forKey:key];
}

- (void)dateFormattingToUser:(NSString *)dateFormatting ForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self[key]]];
    [dateFormatter setDateFormat:dateFormatting];
    
    [self setValue:[dateFormatter stringFromDate:date] forKey:key];
}

- (void)dateFormattingFromUser:(NSString *)userDateFormatting ToServer:(NSString *)serverDateFormatting ForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:userDateFormatting];
    NSDate *date = [dateFormatter dateFromString:self[key]];
    [dateFormatter setDateFormat:serverDateFormatting];
    
    [self setValue:[dateFormatter stringFromDate:date] forKey:key];
    
}

- (void)sexFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *sex = [NSString stringWithFormat:@"%@",self[key]];
    
    [self setValue:[sex isEqualToString:@"01"] ? NSLocalizedString(@"male", nil) :[sex isEqualToString:@"00"] ? NSLocalizedString(@"female", nil) : nil forKey:key];
}

- (void)sexFormattingToServerForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *sex = [NSString stringWithFormat:@"%@",self[key]];
    
    [self setValue:[sex isEqualToString:NSLocalizedString(@"female", nil)] ? @"00" :[sex isEqualToString:NSLocalizedString(@"male", nil)] ? @"01" : nil forKey:key];
    
}

- (void)serverLevelFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *server = [NSString stringWithFormat:@"%@",self[key]];
    
    [self setValue:[server isEqualToString:@"00"] ? NSLocalizedString(@"No avaliable", nil) :[server isEqualToString:@"01"] ? NSLocalizedString(@"Avaliable", nil) : nil forKey:key];
    
}

- (void)medicineUnitsFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *unit = [NSString stringWithFormat:@"%@",self[key]];
    NSString *unit_;
    if ([unit isEqualToString:@"01"]) {
        unit_ = NSLocalizedString(@"mg", nil);
    }
    if ([unit isEqualToString:@"02"]) {
        unit_ = NSLocalizedString(@"g", nil);
    }
    if ([unit isEqualToString:@"03"]) {
        unit_ = NSLocalizedString(@"grain", nil);
    }
    if ([unit isEqualToString:@"04"]) {
        unit_ = NSLocalizedString(@"slice", nil);
    }
    if ([unit isEqualToString:@"05"]) {
        unit_ = NSLocalizedString(@"unit", nil);
    }
    if ([unit isEqualToString:@"06"]) {
        unit_ = NSLocalizedString(@"ml", nil);
    }
    if ([unit isEqualToString:@"07"]) {
        unit_ = NSLocalizedString(@"piece", nil);
    }
    if ([unit isEqualToString:@"08"]) {
        unit_ = NSLocalizedString(@"bottle", nil);
    }
    
    [self setValue:unit_ forKey:key];
}

- (void)medicineUsageFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *usage = [NSString stringWithFormat:@"%@",self[key]];
    NSString *usage_;
    if ([usage isEqualToString:@"01"]) {
        usage_ = NSLocalizedString(@"Oral", nil);
    }
    if ([usage isEqualToString:@"02"]) {
        usage_ = NSLocalizedString(@"Insulin", nil);
    }
    if ([usage isEqualToString:@"03"]) {
        usage_ = NSLocalizedString(@"Injection", nil);
    }
    
    [self setValue:usage_ forKey:key];
}

- (void)eatPeriodFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *eatPeriod = [NSString stringWithFormat:@"%@",self[key]];
    
    if ([eatPeriod isEqualToString:@"01"]) {
        [self setValue:NSLocalizedString(@"breakfast", nil) forKey:key];
    }
    else if ([eatPeriod isEqualToString:@"02"]) {
        [self setValue:NSLocalizedString(@"lunch", nil) forKey:key];
    }
    else if ([eatPeriod isEqualToString:@"03"]) {
        [self setValue:NSLocalizedString(@"dinner", nil) forKey:key];
    }
    else if ([eatPeriod isEqualToString:@"04"]) {
        [self setValue:NSLocalizedString(@"snack", nil) forKey:key];
    }
    else
    {
        [self setValue:@"" forKey:key];
    }
}

- (void)eatUnitsFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    NSString *eatUnit = [NSString stringWithFormat:@"%@",self[key]];
    if ([eatUnit isEqualToString:@"01"]) {
        [self setValue:NSLocalizedString(@"g", nil) forKey:key];
    }
}

- (void)feelingFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    NSString *feeling = [NSString stringWithFormat:@"%@",self[key]];
    NSMutableArray *feelingArr = [NSMutableArray arrayWithArray:[feeling componentsSeparatedByString:@","]];
    
    NSDictionary *feelingDic = @{@"01":NSLocalizedString(@"正常", nil),
                                 @"02":NSLocalizedString(@"三多", nil),
                                 @"03":NSLocalizedString(@"乏力", nil),
                                 @"04":NSLocalizedString(@"腹痛", nil),
                                 @"05":NSLocalizedString(@"气短", nil),
                                 @"06":NSLocalizedString(@"胸闷", nil),
                                 @"07":NSLocalizedString(@"头晕", nil),
                                 @"08":NSLocalizedString(@"恶心", nil),
                                 @"09":NSLocalizedString(@"冷汗 ", nil),
                                 @"10":NSLocalizedString(@"其他", nil),
                                 };
    
    [feelingArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *feel = (NSString *)obj;
        NSString *feel_ = feelingDic[feel];
        if (feel_) {
            [feelingArr replaceObjectAtIndex:idx withObject:feelingDic[feel]];
        }
    }];
    
    feeling = [feelingArr componentsJoinedByString:@","];
    
    [self setValue:feeling forKey:key];
}

- (void)dataSourceFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    NSString *dataSource = [NSString stringWithFormat:@"%@",self[key]];
    
    NSDictionary *sourceDic = @{@"01":@"GlucoTrack",
                                @"02":NSLocalizedString(@"others", nil)};
    
    [self setValue:sourceDic[dataSource] forKey:key];
}


@end
