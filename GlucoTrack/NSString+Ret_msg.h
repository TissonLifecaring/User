//
//  NSString+Ret_msg.h
//  GlucoCare
//
//  Created by Dan on 15-1-12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Ret_msg)

+ (NSString *)localizedMsgFromRet_code:(NSString *)ret_code withHUD:(BOOL)hasHud;

+ (NSString *)localizedErrorMesssagesFromError:(NSError *)error;

@end
