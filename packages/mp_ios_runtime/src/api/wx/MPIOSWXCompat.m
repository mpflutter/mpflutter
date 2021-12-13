//
//  MPIOSWXCompat.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSWXCompat.h"

@implementation MPIOSWXCompat

+ (void)setupWithJSContext:(JSContext *)context {
    [self injectWXScope:context];
    context.globalObject[@"wx"][@"arrayBufferToBase64"] = ^(JSValue *value) {
        return [self arrayBufferToBase64:value];
    };
}

+ (void)injectWXScope:(JSContext *)context {
    if (context.globalObject[@"wx"] == nil || [context.globalObject[@"wx"] isUndefined]) {
        context.globalObject[@"wx"] = [JSValue valueWithNewObjectInContext:context];
    }
}

+ (JSValue *)arrayBufferToBase64:(JSValue *)value {
    if (value.isString) {
        return value;
    }
    return nil;
}

@end
