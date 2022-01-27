//
//  MPIOSClipboard.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSFlutterPlatform.h"

@implementation MPIOSFlutterPlatform

+ (void)load {
    [MPIOSPluginRegister registerChannel:@"flutter/platform" clazz:[self class]];
}

- (void)onMethodCall:(NSString *)method params:(id)params result:(MPIOSMethodChannelResult)result {
    if ([method isEqualToString:@"Clipboard.setData"]) {
        if ([params isKindOfClass:[NSDictionary class]] && [params[@"text"] isKindOfClass:[NSString class]]) {
            [[UIPasteboard generalPasteboard] setString:params[@"text"]];
        }
        result(nil);
    }
    else if ([method isEqualToString:@"Clipboard.getData"]) {
        result(@{@"text": [[UIPasteboard generalPasteboard] string] ?: @""});
    }
    else {
        result(MPIOSMethodChannelNOTImplemented);
    }
}

@end
