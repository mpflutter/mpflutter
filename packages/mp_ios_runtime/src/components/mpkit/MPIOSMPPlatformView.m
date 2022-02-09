//
//  MPIOSMPPlatformView.m
//  mp_ios_runtime
//
//  Created by ydt on 10.12.21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPPlatformView.h"
#import "MPIOSEngine.h"
#import "MPIOSComponentFactory.h"

@implementation MPIOSMPPlatformView

static NSMutableDictionary<NSString *, MPIOSPlatformViewCallback> *invokeMethodCallback;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invokeMethodCallback = [NSMutableDictionary dictionary];
    });
}

+ (void)didReceivedPlatformViewMessage:(NSDictionary *)message engine:(MPIOSEngine *)engine {
    if ([@"methodCall" isEqualToString:message[@"event"]] && message[@"hashCode"] != nil) {
        MPIOSMPPlatformView *target = (id)engine.componentFactory.cachedView[message[@"hashCode"]];
        if ([target isKindOfClass:[MPIOSMPPlatformView class]]) {
            NSString *method = message[@"method"];
            id params = message[@"params"];
            if ([method isKindOfClass:[NSString class]]) {
                [target onMethodCall:method params:params resultCallback:^(id  _Nonnull result) {
                    if (message[@"requireResult"] != nil &&
                        ![message[@"requireResult"] isKindOfClass:[NSNull class]] &&
                        [message[@"seqId"] isKindOfClass:[NSString class]]) {
                        if (engine != nil) {
                            [engine sendMessage:@{
                                @"type": @"platform_view",
                                @"message": @{
                                  @"event": @"methodCallCallback",
                                  @"seqId": message[@"seqId"],
                                  @"result": result ?: [NSNull null],
                                },
                            }];
                        }
                    }
                }];
            }
        }
    }
    else if ([@"methodCallCallback" isEqualToString:message[@"event"]]) {
        NSString *seqId = message[@"seqId"];
        if ([seqId isKindOfClass:[NSString class]]) {
            if (invokeMethodCallback[seqId] != nil) {
                invokeMethodCallback[seqId](message[@"result"]);
                [invokeMethodCallback removeObjectForKey:seqId];
            }
        }
    }
}

- (void)onMethodCall:(NSString *)method
              params:(NSDictionary *)params
      resultCallback:(MPIOSPlatformViewCallback)resultCallback {
    
}

- (void)invokeMethod:(NSString *)method params:(NSDictionary *)params {
    if (self.hashCode == nil || method == nil) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    NSString *seqId = [[NSUUID UUID] UUIDString];
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"platform_view",
            @"message": @{
              @"event": @"methodCall",
              @"hashCode": self.hashCode,
              @"method": method,
              @"params": params ?: [NSNull null],
              @"seqId": seqId,
            },
        }];
    }
}

- (void)invokeMethod:(NSString *)method
              params:(NSDictionary *)params
      resultCallback:(MPIOSPlatformViewCallback)resultCallback {
    if (resultCallback == nil) {
        [self invokeMethod:method params:params];
        return;
    }
    if (self.hashCode == nil || method == nil) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    NSString *seqId = [[NSUUID UUID] UUIDString];
    invokeMethodCallback[seqId] = resultCallback;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"platform_view",
            @"message": @{
              @"event": @"methodCall",
              @"hashCode": self.hashCode,
              @"method": method,
              @"params": params ?: [NSNull null],
              @"seqId": seqId,
              @"requireResult": @(YES),
            },
        }];
    }
}

@end
