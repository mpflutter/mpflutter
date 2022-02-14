//
//  MPIOSDebugger.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <jetfire/JFRWebSocket.h>
#import "MPIOSDebugger.h"
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSViewController.h"
#import "MPIOSProvider.h"

@interface MPIOSDebugger ()<JFRWebSocketDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *messageQueue;
@property (nonatomic, strong) JFRWebSocket *socket;
@property (nonatomic, assign) BOOL shouldClearNavigator;

@end

@implementation MPIOSDebugger

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageQueue = [NSMutableArray array];
    }
    return self;
}

- (void)start {
    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/ws", self.serverAddr]]
                                          protocols:@[]];
    self.socket.delegate = self;
    [self.socket connect];
}

- (void)sendMessage:(NSString *)message {
    if (message == nil) {
        return;
    }
    if (self.socket == nil || !self.socket.isConnected) {
        [self.messageQueue addObject:message];
        return;
    }
    [self.socket writeString:message];
}

- (void)websocketDidConnect:(JFRWebSocket *)socket {
    self.shouldClearNavigator = YES;
    for (NSString *message in self.messageQueue) {
        [socket writeString:message];
    }
    [self.messageQueue removeAllObjects];
}

- (void)websocketDidDisconnect:(JFRWebSocket *)socket error:(NSError *)error {
    if (self.shouldClearNavigator) {
        [self.engine.provider.navigatorProvider handleRestart];
        self.shouldClearNavigator = NO;
    }
    [self.engine clear];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start];
    });
}

- (void)websocket:(JFRWebSocket *)socket didReceiveMessage:(NSString *)string {
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [engine didReceivedMessage:string];
        });
    }
}

@end
