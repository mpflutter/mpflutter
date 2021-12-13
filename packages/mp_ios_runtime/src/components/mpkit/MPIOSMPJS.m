//
//  MPIOSMPJS.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPJS.h"
#import "MPIOSEngine+Private.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation MPIOSMPJS

- (instancetype)initWithEngine:(MPIOSEngine *)engine
{
    self = [super init];
    if (self) {
        _engine = engine;
        [self inject];
    }
    return self;
}

- (void)inject {
    NSString *scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"mp_ios_mpjs" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:scriptPath
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    if (script != nil) {
        [self.engine.jsContext evaluateScript:script];
        NSLog(@"%@", self.engine.jsContext.exception);
    }
}

- (void)didReceivedMessage:(NSDictionary *)message {
    if (message == nil) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    id requestId = message[@"requestId"];
    if (engine != nil) {
        JSValue *value = engine.jsContext[@"MPJS"][@"instance"][@"handleMessage"];
        if ([value isObject]) {
            [value callWithArguments:@[
                message,
                ^(NSString *result) {
                    MPIOSEngine *engine = self.engine;
                    if (engine != nil) {
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
                        if (![dict isKindOfClass:[NSDictionary class]]) {
                            dict = @{};
                        }
                        [engine sendMessage:@{
                            @"type": @"mpjs",
                            @"message": @{
                                    @"requestId": requestId ?: @"",
                                    @"result": dict[@"value"] ?: [NSNull null],
                            },
                        }];
                    }
                },
                ^(NSString *result) {
                    MPIOSEngine *engine = self.engine;
                    if (engine != nil) {
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
                        if (![dict isKindOfClass:[NSDictionary class]]) {
                            dict = @{};
                        }
                        [engine sendMessage:@{
                            @"type": @"mpjs",
                            @"message": dict,
                        }];
                    }
                },
            ]];
        }
    }
}

@end
