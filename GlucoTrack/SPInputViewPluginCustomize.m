//
//  SPInputViewPluginCustomize.m
//  WXOpenIMSampleDev
//
//  Created by huanglei on 4/29/15.
//  Copyright (c) 2015 taobao. All rights reserved.
//

#import "SPInputViewPluginCustomize.h"

#import "SPKitExample.h"

@interface SPInputViewPluginCustomize ()

@property (nonatomic, readonly) YWConversationViewController *conversationViewController;

@end

@implementation SPInputViewPluginCustomize

#pragma mark - properties

- (YWConversationViewController *)conversationViewController
{
    if ([self.inputViewRef.controllerRef isKindOfClass:[YWConversationViewController class]]) {
        return (YWConversationViewController *)self.inputViewRef.controllerRef;
    } else {
        return nil;
    }
}


#pragma mark - YWInputViewPluginProtocol

/**
 * 您需要实现以下方法
 */

// 插件图标
- (UIImage *)pluginIconImage
{
    return [UIImage imageNamed:@"input_plug_ico_hi_nor"];
}

// 插件名称
- (NSString *)pluginName
{
    return @"打招呼";
}

// 插件对应的view，会被加载到inputView上
- (UIView *)pluginContentView
{
    return nil;
}

// 插件被选中运行
- (void)pluginDidClicked
{
    [[SPKitExample sharedInstance] exampleSendCustomMessageWithConversationController:self.conversationViewController];
}


@end
