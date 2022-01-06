//
//  MPFLTJSRuntime.m
//  mp_flutter_runtime
//
//  Created by ydt on 6.1.22.
//

#import "MPFLTJSRuntime.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MPFLTJSRuntime ()

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation MPFLTJSRuntime

static NSMutableDictionary<NSString *, JSContext *> *contextRefs;

+ (void)load {
    contextRefs = [NSMutableDictionary dictionary];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.mpflutter.mp_flutter_runtime.js_context"
                                     binaryMessenger:[registrar messenger]];
    FlutterEventChannel *event = [FlutterEventChannel
                                  eventChannelWithName:@"com.mpflutter.mp_flutter_runtime.js_callback"
                                  binaryMessenger:[registrar messenger]];
    MPFLTJSRuntime* instance = [[MPFLTJSRuntime alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [event setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"createContext"]) {
        NSString *ref = [[NSUUID UUID] UUIDString];
        JSContext *context = [[JSContext alloc] init];
        __weak MPFLTJSRuntime *welf = self;
        context[@"postMessage"] = ^(NSString *message) {
            __strong MPFLTJSRuntime *self = welf;
            if (self == nil) {
                return;
            }
            if (self.eventSink != nil) {
                self.eventSink(message);
            }
        };
        [contextRefs setObject:context forKey:ref];
        result(ref);
    }
    else if ([call.method isEqualToString:@"releaseContext"]) {
        NSString *ref = call.arguments;
        if ([ref isKindOfClass:[NSString class]]) {
            [contextRefs removeObjectForKey:ref];
        }
        result(nil);
    }
    else if ([call.method isEqualToString:@"evaluateScript"]) {
        NSDictionary *options = call.arguments;
        if ([options isKindOfClass:[NSDictionary class]]) {
            NSString *contextRef = options[@"contextRef"];
            NSString *script = options[@"script"];
            if ([contextRef isKindOfClass:[NSString class]] &&
                [script isKindOfClass:[NSString class]]) {
                JSContext *context = contextRefs[contextRef];
                if (context != nil) {
                    [context setException:nil];
                    JSValue *ret = [context evaluateScript:script];
                    JSValue *exception = [context exception];
                    if (exception != nil) {
                        result([FlutterError errorWithCode:@"JSContext"
                                                   message:[exception toString]
                                                   details:[exception toString]]);
                    }
                    else {
                        result([ret toObject]);
                    }
                }
            }
        }
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

@end
