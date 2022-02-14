//
//  MPIOSRoute.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSRouter.h"
#import "MPIOSViewController.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSProvider.h"

@interface MPIOSRouter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, MPIOSRouteResponseBlock> *routeResponseHandler;
@property (nonatomic, assign) BOOL doBacking;
@property (nonatomic, strong) NSNumber *thePushingRouteId;

@end

@implementation MPIOSRouter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _routeResponseHandler = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)requestRoute:(NSString *)routeName
         routeParams:(NSDictionary *)routeParams
              isRoot:(BOOL)isRoot
            viewport:(CGSize)viewport
     completionBlock:(MPIOSRouteResponseBlock)completionBlock {
    if (self.thePushingRouteId != nil) {
        NSNumber *value = self.thePushingRouteId;
        self.thePushingRouteId = nil;
        [self.engine sendMessage:@{
            @"type": @"router",
            @"message": @{
                    @"event": @"updateRoute",
                    @"routeId": value,
                    @"viewport": @{
                            @"width": @(viewport.width),
                            @"height": @(viewport.height),
                    },
            },
        }];
        completionBlock(value);
        return;
    }
    NSString *requestId = [[NSUUID UUID] UUIDString];
    self.routeResponseHandler[requestId] = completionBlock;
    [self.engine sendMessage:@{
        @"type": @"router",
        @"message": @{
                @"event": @"requestRoute",
                @"requestId": requestId,
                @"name": routeName ?: @"/",
                @"params": routeParams ?: @{},
                @"viewport": @{
                        @"width": @(viewport.width),
                        @"height": @(viewport.height),
                },
                @"root": [NSNumber numberWithBool:isRoot],
        },
    }];
}

- (void)updateRouteViewport:(NSNumber *)routeId viewport:(CGSize)viewport {
    [self.engine sendMessage:@{
        @"type": @"router",
        @"message": @{
                @"event": @"updateRoute",
                @"routeId": routeId,
                @"viewport": @{
                        @"width": @(viewport.width),
                        @"height": @(viewport.height),
                },
        },
    }];
}

- (void)reponseRoute:(NSDictionary *)message {
    if (![message isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *requestId = message[@"requestId"];
    NSNumber *routeId = message[@"routeId"];
    if ([requestId isKindOfClass:[NSString class]] && [routeId isKindOfClass:[NSNumber class]]) {
        if (self.routeResponseHandler[requestId] != nil) {
            self.routeResponseHandler[requestId](routeId);
            [self.routeResponseHandler removeObjectForKey:requestId];
        }
    }
}

- (void)didReceivedRouteData:(NSDictionary *)message {
    if (![message isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *event = message[@"event"];
    if (![event isKindOfClass:[NSString class]]) {
        return;
    }
    if ([event isEqualToString:@"responseRoute"]) {
        [self reponseRoute:message];
    }
    if ([event isEqualToString:@"didPush"]) {
        [self didPush:message];
    }
    else if ([event isEqualToString:@"didReplace"]) {
        [self didReplace:message];
    }
    else if ([event isEqualToString:@"didPop"]) {
        [self didPop];
    }
}

- (void)dispose:(NSNumber *)viewId {
    if (self.doBacking) {
        return;
    }
    if (viewId == nil) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"router",
            @"message": @{
                    @"event": @"disposeRoute",
                    @"routeId": viewId,
            },
        }];
    }
}

- (void)triggerPop:(NSNumber *)viewId {
    if (self.doBacking) {
        return;
    }
    if (viewId == nil) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"router",
            @"message": @{
                    @"event": @"popToRoute",
                    @"routeId": viewId,
            },
        }];
    }
}

- (void)didPush:(NSDictionary *)message {
    if (!([message[@"routeId"] isKindOfClass:[NSNumber class]])) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    self.thePushingRouteId = message[@"routeId"];
    if (engine != nil) {
        MPIOSViewController *nextViewController = [[MPIOSViewController alloc] init];
        nextViewController.engine = engine;
        [engine.provider.navigatorProvider handlePushViewController:nextViewController];
    }
}

- (void)didReplace:(NSDictionary *)message {
    if (!([message[@"routeId"] isKindOfClass:[NSNumber class]])) {
        return;
    }
    MPIOSEngine *engine = self.engine;
    self.thePushingRouteId = message[@"routeId"];
    if (engine != nil) {
        MPIOSViewController *nextViewController = [[MPIOSViewController alloc] init];
        nextViewController.engine = engine;
        [engine.provider.navigatorProvider handleReplaceViewController:nextViewController];
    }
}

- (void)didPop {
    self.doBacking = YES;
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine.provider.navigatorProvider handlePop];
    }
    self.doBacking = NO;
}

@end
