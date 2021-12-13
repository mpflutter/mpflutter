//
//  MPIOSConsole.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSConsole.h"

@implementation MPIOSConsole

+ (void)setupWithJSContext:(JSContext *)context {
    context[@"console"] = self;
}

+ (void)log {
    NSArray *args = [JSContext currentArguments];
    for (JSValue *arg in args) {
        NSLog(@"[MPIOS]LOGV:%@", arg);
    }
}

+ (void)error {
    NSArray *args = [JSContext currentArguments];
    for (JSValue *arg in args) {
        NSLog(@"[MPIOS]LOGE:%@", arg);
    }
}

+ (void)info {
    NSArray *args = [JSContext currentArguments];
    for (JSValue *arg in args) {
        NSLog(@"[MPIOS]LOGI:%@", arg);
    }
}

+ (void)warn {
    NSArray *args = [JSContext currentArguments];
    for (JSValue *arg in args) {
        NSLog(@"[MPIOS]LOGW:%@", arg);
    }
}

+ (void)debug {
    NSArray *args = [JSContext currentArguments];
    for (JSValue *arg in args) {
        NSLog(@"[MPIOS]LOGD:%@", arg);
    }
}


@end
