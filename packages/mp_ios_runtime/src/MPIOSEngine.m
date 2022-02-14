//
//  MPIOSEngine.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSProvider.h"
#import "MPIOSConsole.h"
#import "MPIOSTimer.h"
#import "MPIOSDeviceInfo.h"
#import "MPIOSWXCompat.h"
#import "MPIOSNetworkHttp.h"
#import "MPIOSStorage.h"
#import "MPIOSDebugger.h"
#import "MPIOSComponentFactory.h"
#import "MPIOSWebDialogs.h"
#import "MPIOSCustomPaint.h"
#import "MPIOSRouter.h"
#import "MPIOSMPJS.h"
#import "MPIOSTextMeasurer.h"
#import "MPIOSMpkReader.h"
#import "MPIOSWindowInfo.h"
#import "MPIOSMPPlatformView.h"
#import "MPIOSListView.h"
#import "MPIOSGridView.h"
#import "MPIOSCustomScrollView.h"
#import "MPIOSPlatformChannelIO.h"

@interface MPIOSEngine ()

@property (nonatomic, assign) BOOL started;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<MPIOSDataReceiver>> *managedViews;
@property (nonatomic, strong) MPIOSComponentFactory *componentFactory;
@property (nonatomic, strong) NSString *jsCode;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSMutableArray<NSString *> *messageQueue;
@property (nonatomic, strong) MPIOSDebugger *debugger;
@property (nonatomic, strong) MPIOSMpkReader *mpkReader;
@property (nonatomic, strong) MPIOSDrawableStorage *drawableStorage;
@property (nonatomic, strong) MPIOSRouter *router;
@property (nonatomic, strong) MPIOSMPJS *mpJS;
@property (nonatomic, strong) MPIOSTextMeasurer *textMeasurer;
@property (nonatomic, strong) MPIOSWindowInfo *windowInfo;
@property (nonatomic, strong) MPIOSPlatformChannelIO *platformChannelIO;

@end

@implementation MPIOSEngine

- (instancetype)initWithJSCode:(NSString *)jsCode
{
    self = [super init];
    if (self) {
        [self doInit];
        _jsCode = jsCode;
    }
    return self;
}

- (instancetype)initWithDebuggerServerAddr:(NSString *)debuggerServerAddr
{
    self = [super init];
    if (self) {
        [self doInit];
        _debugger = [[MPIOSDebugger alloc] init];
        _debugger.serverAddr = debuggerServerAddr;
        _debugger.engine = self;
    }
    return self;
}

- (instancetype)initWithMpkData:(NSData *)mpkData
{
    self = [super init];
    if (self) {
        [self doInit];
        _mpkReader = [[MPIOSMpkReader alloc] initWithData:mpkData];
        NSData *mainDartJSData = [_mpkReader dataWithFilePath:@"main.dart.js"];
        if (mainDartJSData != nil) {
            _jsCode = [[NSString alloc] initWithData:mainDartJSData encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

- (void)doInit {
    _managedViews = [NSMutableDictionary dictionary];
    _componentFactory = [[MPIOSComponentFactory alloc] init];
    _componentFactory.engine = self;
    _drawableStorage = [[MPIOSDrawableStorage alloc] init];
    _drawableStorage.engine = self;
    _router = [[MPIOSRouter alloc] init];
    _router.engine = self;
    _messageQueue = [NSMutableArray array];
    _textMeasurer = [[MPIOSTextMeasurer alloc] init];
    _textMeasurer.engine = self;
    _windowInfo = [[MPIOSWindowInfo alloc] init];
    _windowInfo.engine = self;
    _provider = [[MPIOSProvider alloc] init];
    _platformChannelIO = [[MPIOSPlatformChannelIO alloc] initWithEngine:self];
}

- (void)start {
    if (self.started) {
        return;
    }
    if (self.jsCode == nil && self.debugger == nil) {
        return;
    }
    [self.windowInfo updateWindowInfo];
    self.jsContext = [[JSContext alloc] init];
    [self.jsContext setExceptionHandler:^(JSContext *context, JSValue *exception) {
        NSLog(@"%@", exception);
    }];
    [self setupJSContextEventChannel];
    [self setupDeferedLibraryLoader];
    [MPIOSConsole setupWithJSContext:self.jsContext];
    [MPIOSTimer setupWithJSContext:self.jsContext];
    [MPIOSDeviceInfo setupWithJSContext:self.jsContext size:[UIScreen mainScreen].bounds.size];
    [MPIOSWXCompat setupWithJSContext:self.jsContext];
    [MPIOSNetworkHttp setupWithJSContext:self.jsContext engine:self];
    [MPIOSStorage setupWithJSContext:self.jsContext engine:self];
    self.jsContext[@"self"] = self.jsContext.globalObject;
    self.mpJS = [[MPIOSMPJS alloc] initWithEngine:self];
    if (self.jsCode != nil) {
        [self.jsContext evaluateScript:self.jsCode];
        for (NSString *msg in self.messageQueue) {
            [self.jsContext[@"engineScope"][@"postMessage"] callWithArguments:@[msg]];
        }
        [self.messageQueue removeAllObjects];
    }
    else if (self.debugger != nil) {
        [self.debugger start];
    }
    self.started = YES;
}

- (void)setupJSContextEventChannel {
    __weak MPIOSEngine *welf = self;
    self.jsContext[@"engineScope"] = [JSValue valueWithNewObjectInContext:self.jsContext];
    self.jsContext[@"engineScope"][@"onMessage"] = ^(NSString *message) {
        __strong MPIOSEngine *self = welf;
        if (self != nil) {
            [self didReceivedMessage:message];
        }
    };
}

- (void)setupDeferedLibraryLoader {
    __weak MPIOSEngine *welf = self;
    self.jsContext[@"dartDeferredLibraryLoader"] = ^() {
        MPIOSEngine *self = welf;
        if (self == nil) {
            return;
        }
        if (self.mpkReader == nil) {
            return;
        }
        NSArray *jsArgs = [JSContext currentArguments];
        if (jsArgs.count < 3) {
            return;
        }
        NSString *fileName = [(JSValue *)jsArgs[0] toString];
        JSValue *resFunc = jsArgs[1];
        JSValue *rejFunc = jsArgs[2];
        NSData *codeData = [self.mpkReader dataWithFilePath:fileName];
        if (codeData == nil) {
            [rejFunc callWithArguments:@[]];
            return;
        }
        NSString *code = [[NSString alloc] initWithData:codeData encoding:NSUTF8StringEncoding];
        if (code == nil) {
            [rejFunc callWithArguments:@[]];
            return;
        }
        [self.jsContext evaluateScript:code];
        [resFunc callWithArguments:@[]];
    };
}

- (void)stop {
    self.jsContext = nil;
}

- (void)clear {
    [self.componentFactory clear];
}

- (void)didReceivedMessage:(NSString *)message {
    NSDictionary *decodedMessage = [NSJSONSerialization
                                    JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                    options:kNilOptions
                                    error:NULL];
    if (![decodedMessage isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
        [decodedMessage[@"type"] isEqualToString:@"frame_data"]) {
        [self didReceivedFrameData:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"diff_data"]) {
        [self didReceivedDiffData:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
              [decodedMessage[@"type"] isEqualToString:@"element_gc"]) {
       [self didReceivedElementGC:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"decode_drawable"]) {
        [self.drawableStorage decodeDrawable:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"custom_paint"]) {
        [MPIOSCustomPaint didReceivedCustomPaintMessage:decodedMessage[@"message"] engine:self];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"action:web_dialogs"]) {
        [MPIOSWebDialogs didReceivedWebDialogsMessage:decodedMessage[@"message"] engine:self];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"route"]) {
        [self.router didReceivedRouteData:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"mpjs"]) {
        [self.mpJS didReceivedMessage:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"rich_text"]) {
        [self.textMeasurer didReceivedDoMeasureData:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"platform_view"]) {
        [MPIOSMPPlatformView didReceivedPlatformViewMessage:decodedMessage[@"message"] engine:self];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"platform_channel"]) {
        [self.platformChannelIO didReceivedMessage:decodedMessage[@"message"]];
    } else if ([decodedMessage[@"type"] isKindOfClass:[NSString class]] &&
               [decodedMessage[@"type"] isEqualToString:@"scroll_view"]) {
        [self didReceivedScrollView:decodedMessage[@"message"]];
    }
}

- (void)didReceivedFrameData:(NSDictionary *)frameData {
    if (![frameData isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSNumber *routeId = frameData[@"routeId"];
    if ([routeId isKindOfClass:[NSNumber class]]) {
        id<MPIOSDataReceiver> targetView = self.managedViews[routeId];
        if (targetView != nil) {
            [targetView didReceivedFrameData:frameData];
        }
    }
}

- (void)didReceivedDiffData:(NSDictionary *)frameData {
    if (![frameData isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSArray *diffs = frameData[@"diffs"];
    if (![diffs isKindOfClass:[NSArray class]]) {
        return;
    }
    [diffs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.componentFactory create:obj];
    }];
}

- (void)didReceivedElementGC:(NSArray *)data {
    if (![data isKindOfClass:[NSArray class]]) {
        return;
    }
    [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [[self.componentFactory cachedView] removeObjectForKey:obj];
            [[self.componentFactory cachedElement] removeObjectForKey:obj];
        }
    }];
}

- (void)didReceivedScrollView:(NSDictionary *)message {
    if (![message isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *event = message[@"event"];
    if (event != nil && [@"onRefreshEnd" isEqualToString:event]) {
        NSNumber *target = message[@"target"];
        if (target != nil) {
            MPIOSComponentView *targetView = self.componentFactory.cachedView[target];
            if ([targetView isKindOfClass:[MPIOSListView class]]) {
                [(MPIOSListView *)targetView endRefresh];
            }
            else if ([targetView isKindOfClass:[MPIOSGridView class]]) {
                [(MPIOSGridView *)targetView endRefresh];
            }
            else if ([targetView isKindOfClass:[MPIOSCustomScrollView class]]) {
                [(MPIOSCustomScrollView *)targetView endRefresh];
            }
        }
    }
}

- (void)sendMessage:(NSDictionary *)message {
    if (self.debugger != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:message
                                                       options:kNilOptions
                                                         error:NULL];
        if (data != nil) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self.debugger sendMessage:str];
        }
    }
    else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:message
                                                       options:kNilOptions
                                                         error:NULL];
        if (data != nil) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (str == nil) {
                return;
            }
            JSValue *engineScope = self.jsContext[@"engineScope"];
            if (engineScope == nil || [(JSValue *)engineScope[@"postMessage"] isUndefined]) {
                [self.messageQueue addObject:str];
                return;
            }
            [self.jsContext[@"engineScope"][@"postMessage"] callWithArguments:@[str]];
        }
    }
}

@end
