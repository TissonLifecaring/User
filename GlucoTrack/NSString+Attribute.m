//
//  NSString+Attribute.m
//  SugarNursing
//
//  Created by Dan on 14-11-19.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSString+Attribute.h"

@implementation NSString (Attribute)

+ (NSDictionary *)attributeCommonInit
{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 1.0;
    shadow.shadowColor = [UIColor lightGrayColor];
    shadow.shadowOffset = CGSizeMake(0.5, 0.5);
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.paragraphSpacingBefore = 5.0;
    
    NSDictionary *attributes = @{NSShadowAttributeName:shadow, NSParagraphStyleAttributeName:paragraph};
    
    return attributes;
}


@end
