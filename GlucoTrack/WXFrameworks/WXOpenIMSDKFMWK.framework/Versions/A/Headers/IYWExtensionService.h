//
//  IYWGlobalExtensionService.h
//  
//
//  Created by huanglei on 15/3/10.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IYWExtension;

@protocol IYWExtensionService <NSObject>

/**
 *  获取某一个全局扩展
 */
- (id<IYWExtension>)getExtensionByServiceName:(NSString *)aServiceName;

@end
