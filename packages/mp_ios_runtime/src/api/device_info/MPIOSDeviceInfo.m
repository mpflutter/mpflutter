//
//  MPIOSDeviceInfo.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSDeviceInfo.h"

@implementation MPIOSDeviceInfo

+ (void)setupWithJSContext:(JSContext *)context size:(CGSize)size {
    JSValue *document = [JSValue valueWithNewObjectInContext:context];
    document[@"currentScript"] = @"";
    JSValue *body = [JSValue valueWithNewObjectInContext:context];
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        body[@"clientWidth"] = [JSValue valueWithDouble:UIScreen.mainScreen.bounds.size.width
                                              inContext:context];
        body[@"clientHeight"] = [JSValue valueWithDouble:UIScreen.mainScreen.bounds.size.height
                                              inContext:context];
    }
    else {
        body[@"clientWidth"] = [JSValue valueWithDouble:size.width
                                              inContext:context];
        body[@"clientHeight"] = [JSValue valueWithDouble:size.height
                                              inContext:context];
    }
    if (@available(iOS 11.0, *)) {
        body[@"windowPaddingTop"] = [JSValue valueWithDouble:[UIApplication sharedApplication].windows.firstObject.safeAreaInsets.top * [UIScreen mainScreen].scale
                                                      inContext:context];
        body[@"windowPaddingBottom"] = [JSValue valueWithDouble:[UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom * [UIScreen mainScreen].scale
                                                      inContext:context];
    } else { }
    document[@"body"] = body;
    context.globalObject[@"disableMPProxy"] = @(YES);
    context.globalObject[@"document"] = document;
    context.globalObject[@"devicePixelRatio"] = [JSValue valueWithDouble:[UIScreen mainScreen].scale
                                                               inContext:context];
}

@end
