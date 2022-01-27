//
//  MPIOSPlatformChannelIO.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSPlatformChannelIO.h"
#import "MPIOSPluginRegister.h"
#import "MPIOSMethodChannel.h"
#import "MPIOSEventChannel.h"
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"

@interface MPIOSPlatformChannelIO ()

@property (nonatomic, strong) NSDictionary<NSString *, id> *pluginInstances;

@end

@implementation MPIOSPlatformChannelIO

- (instancetype)initWithEngine:(MPIOSEngine *)engine
{
    self = [super init];
    if (self) {
        _engine = engine;
        _responseCallbacks = [NSMutableDictionary dictionary];
        NSMutableDictionary *pluginInstances = [NSMutableDictionary dictionary];
        [[MPIOSPluginRegister allRegistedChannels] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id instance = [(Class)obj new];
            if (instance != nil) {
                [pluginInstances setObject:instance forKey:key];
                if ([instance isKindOfClass:[MPIOSMethodChannel class]]) {
                    [(MPIOSMethodChannel *)instance setChannelName:key];
                    [(MPIOSMethodChannel *)instance setEngine:self.engine];
                }
                if ([instance isKindOfClass:[MPIOSEventChannel class]]) {
                    [(MPIOSEventChannel *)instance setChannelName:key];
                    [(MPIOSEventChannel *)instance setEngine:self.engine];
                }
            }
        }];
        self.pluginInstances = pluginInstances.copy;
    }
    return self;
}

- (void)didReceivedMessage:(NSDictionary *)message {
    if (![message isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *event = message[@"event"];
    if (![event isKindOfClass:[NSString class]]) {
        return;
    }
    if ([event isEqualToString:@"invokeMethod"]) {
        NSString *method = message[@"method"];
        NSString *beInvokeMethod = message[@"beInvokeMethod"];
        if (![method isKindOfClass:[NSString class]] ||
            ![beInvokeMethod isKindOfClass:[NSString class]]) {
            return;
        }
        id beInvokeParams = message[@"beInvokeParams"];
        id seqId = message[@"seqId"];
        id instance = self.pluginInstances[method];
        if ([instance isKindOfClass:[MPIOSMethodChannel class]]) {
            [(MPIOSMethodChannel *)instance onMethodCall:beInvokeMethod params:beInvokeParams result:^(id  _Nonnull result) {
                __strong MPIOSEngine *strongEngine = self.engine;
                if (strongEngine != nil) {
                    if ([result isKindOfClass:[NSError class]]) {
                        [strongEngine sendMessage:@{
                            @"type": @"platform_channel",
                            @"message": @{
                                    @"event": @"callbackResult",
                                    @"result": [NSString stringWithFormat:@"ERROR: %@", [(NSError *)result
                                                                                         localizedDescription]],
                                    @"seqId": seqId ?: [NSNull null],
                            },
                        }];
                    }
                    else {
                        [strongEngine sendMessage:@{
                            @"type": @"platform_channel",
                            @"message": @{
                                    @"event": @"callbackResult",
                                    @"result": result ?: [NSNull null],
                                    @"seqId": seqId ?: [NSNull null],
                            },
                        }];
                    }
                }
            }];
        }
        else if ([instance isKindOfClass:[MPIOSEventChannel class]]) {
            if ([beInvokeMethod isEqualToString:@"listen"]) {
                [(MPIOSEventChannel *)instance onListen:beInvokeParams eventSink:^(id  _Nonnull data) {
                    __strong MPIOSEngine *strongEngine = self.engine;
                    if (strongEngine != nil) {
                        [strongEngine sendMessage:@{
                            @"type": @"platform_channel",
                            @"message": @{
                                    @"event": @"callbackEventSink",
                                    @"method": method,
                                    @"result": data ?: [NSNull null],
                                    @"seqId": seqId ?: [NSNull null],
                            },
                        }];
                    }
                }];
            }
            else if ([beInvokeMethod isEqualToString:@"cancel"]) {
                [(MPIOSEventChannel *)instance onCancel:beInvokeParams];
            }
        }
    }
    else if ([event isEqualToString:@"callbackResult"]) {
        id seqId = message[@"seqId"];
        if (seqId == nil) {
            return;
        }
        id result = message[@"result"];
        MPIOSMethodChannelResult callback = self.responseCallbacks[seqId];
        if (callback != nil) {
            if ([result isKindOfClass:[NSString class]] && [(NSString *)result hasPrefix:@"ERROR:"]) {
                callback([NSError errorWithDomain:@"MPIOSMethodChannel" code:-1 userInfo:@{
                    NSLocalizedDescriptionKey: result,
                }]);
            }
            else {
                callback(result);
            }
            [self.responseCallbacks removeObjectForKey:seqId];
        }
    }
}

@end
