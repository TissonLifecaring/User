//
//  IYWExtensionServiceDef.h
//
//
//  Created by huanglei on 15/3/10.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  扩展类型定义
 */
typedef enum : NSUInteger {
    /// 全局扩展
    YWExtensionTypeGlobal = 1,
    /// YWIMCore内部扩展
    YWExtensionTypeContext,
} YWExtensionType;

/**
 *  定义扩展的文件名，这个文件必须位于MainBundle
 *  这个文件中声明了所有被引入App的OpenIM扩展，是一个NSArray对象
 *  每个item是一个包含下面三个key的NSDictionary对象
 */
#define YWExtensionPlistFileName       @"YWExtensions"

/**
 *  扩展的plist中，extension的加载器名称
 */
#define YWExtensionPlistKeyLoaderName  @"LoaderName"

/**
 *  扩展的plist中，extension的类型
 */
#define YWExtensionPlistKeyType @"Type"


/**
 *  每一个扩展必须遵循这个协议
 */

@protocol IYWExtension <NSObject>

/**
 *  该扩展是否被启用
 */
- (BOOL)enable;

@end

/**
 *  每一个扩展必须有一个加载器类，遵循这个协议
 */
@protocol IYWExtensionLoader <NSObject>

/**
 *  每一个加载器类必须实现这个方法，并返回扩展的具体对象。
 *  @param aContext 如果是全局扩展，被加载时此参数为nil；如果是Context内部扩展，被加载时此参数为WXOBaseContext对象
 */
+ (id<IYWExtension>)loadExtensionWithContext:(id)aContext;

/**
 *  每一个加载器类必须实现此方法，返回ExtensionService的名称
 */
+ (NSString *)extensionServiceName;

@end



@interface IYWExtensionServiceDef : NSObject

@end