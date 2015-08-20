//
//  CountryAndAreaCode.h
//  SugarNursing
//
//  Created by Dan on 15-1-8.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief 国家名称和国家码类
 */
@interface CountryAndAreaCode : NSObject

/**
 * @brief 国家中文名称
 */
@property(nonatomic,copy) NSString* countryName;

/**
 * @brief 国家码
 */
@property(nonatomic,copy) NSString* areaCode;

/**
 * @brief 国家拼音名字
 */
@property(nonatomic,copy) NSString* pinyinName;

@end

