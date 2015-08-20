//
//  DeviceHelper.m
//  GlucoTrack
//
//  Created by Ian on 15-4-17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "DeviceHelper.h"
#import <sys/utsname.h>
#import <Foundation/Foundation.h>


static NSString *modelName;
static CGFloat fontSize;

@implementation DeviceHelper


+ (void)configureAppropriateFontSize
{
    
    CGFloat deviceFontSize;
    if ([DeviceHelper iphone4])
    {
        deviceFontSize = 15.0f;
    }
    else if ([DeviceHelper iphone5])
    {
        deviceFontSize = 16.0f;
    }
    else if ([DeviceHelper iphone6])
    {
        deviceFontSize = 17.0f;
    }
    else if ([DeviceHelper iphone6Plus])
    {
        deviceFontSize = 18.0f;
    }
    else if ([DeviceHelper pad])
    {
        deviceFontSize = 18.0f;
    }
    else
    {
        deviceFontSize = 16.0f;
    }
    
    fontSize = deviceFontSize;
}



#pragma mark - 设备类型名称
+ (NSString *)deviceModelName
{
    if (modelName && modelName.length>0)
    {
        return modelName;
    }
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 2G (A1599)";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 2G (A1600)";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 2G (A1601)";
    
    
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air2 (A1566)";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air2 (A1567)";
    
    
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    
    if ([DeviceHelper pad]) return @"iPad Air";
    if ([DeviceHelper phone]) return @"iPhone 5S";
    
    
    
    return @"iPhone 5s (A1453/A1533)";
}


+ (BOOL)iphone4
{
    modelName = [self deviceModelName];
    if ([modelName isEqualToString:@"iPhone 4"] ||
        [modelName isEqualToString:@"iPhone 4S"])
        return YES;
    else
        return NO;
}

+ (BOOL)iphone5
{
    modelName = [self deviceModelName];
    if ([modelName isEqualToString:@"iPhone 5"]  ||
        [modelName isEqualToString:@"iPhone 5C"] ||
        [modelName isEqualToString:@"iPhone 5S"])
        return YES;
    else
        return NO;
}

+ (BOOL)iphone6
{
    modelName = [self deviceModelName];
    return [modelName isEqualToString:@"iPhone 6"];
}

+ (BOOL)iphone6Plus
{
    modelName = [self deviceModelName];
    return [modelName isEqualToString:@"iPhone 6 Plus"];
}

+ (BOOL)ipad
{
    modelName = [self deviceModelName];
    if (modelName.length < 4) return NO;
    return [[modelName substringToIndex:4] isEqualToString:@"iPad"];
}

+ (BOOL)phone
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

+ (BOOL)pad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (CGFloat)normalFontSize
{
    return fontSize;
}

+ (CGFloat)biggerFontSize
{
    return fontSize+3;
}

+ (CGFloat)smallerFontSize
{
    return fontSize-2;
}

+ (CGFloat)biggestFontSize
{
    return fontSize+6;
}


@end
