//
//  MPFLTJSRuntimeTimer.m
//  mp_flutter_runtime
//
//  Created by PonyCui on 2022/1/21.
//

#import "MPFLTJSRuntimeTimer.h"

@implementation MPFLTJSRuntimeTimer

static NSMutableDictionary *clearTimerHandles;

+ (void)setupWithJSContext:(JSContext *)context {
    clearTimerHandles = [NSMutableDictionary dictionary];
    context[@"setTimeout"] = ^{
        return [self setTimeout];
    };
    context[@"clearTimeout"] = ^{
        return [self clearTimeout];
    };
    context[@"setInterval"] = ^{
        return [self setInterval];
    };
    context[@"clearInterval"] = ^{
        return [self clearInterval];
    };
    context[@"requestAnimationFrame"] = ^{
        return [self requestAnimationFrame];
    };
    
    context[@"cancelAnimationFrame"] = ^{
        return [self cancelAnimationFrame];
    };
}

+ (NSNumber *)setTimeout {
    NSArray *args = [JSContext currentArguments];
    if (args.count == 2) {
        JSValue *callback = args[0];
        JSValue *time = args[1];
        NSNumber *handle = @(arc4random());
        if ([callback isObject] && [time isNumber]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[time toNumber] integerValue] / 1000.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (clearTimerHandles[handle] != nil) {
                    [clearTimerHandles removeObjectForKey:handle];
                    return;
                }
                [callback callWithArguments:@[]];
            });
        }
        return handle;
    }
    return @(0);
}

+ (void)clearTimeout {
    NSArray *args = [JSContext currentArguments];
    if (args.count == 1) {
        JSValue *handle = args[0];
        if ([handle isNumber]) {
            NSNumber *numberHandle = [handle toNumber];
            if (numberHandle != nil) {
                [clearTimerHandles setObject:@(1) forKey:numberHandle];
            }
        }
    }
}

+ (NSNumber *)requestAnimationFrame {
    NSArray *args = [JSContext currentArguments];
    if (args.count == 1) {
        JSValue *callback = args[0];
        NSNumber *handle = @(arc4random());
        if ([callback isObject]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0 / 1000.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (clearTimerHandles[handle] != nil) {
                    [clearTimerHandles removeObjectForKey:handle];
                    return;
                }
                [callback callWithArguments:@[@([[NSDate date] timeIntervalSince1970] * 1000)]];
            });
        }
        return handle;
    }
    return @(0);
}

+ (void)cancelAnimationFrame {
    NSArray *args = [JSContext currentArguments];
    if (args.count == 1) {
        JSValue *handle = args[0];
        if ([handle isNumber]) {
            NSNumber *numberHandle = [handle toNumber];
            if (numberHandle != nil) {
                [clearTimerHandles setObject:@(1) forKey:numberHandle];
            }
        }
    }
}

+ (NSNumber *)setInterval {
    NSArray *args = [JSContext currentArguments];
    if (args.count == 2) {
        JSValue *callback = args[0];
        JSValue *time = args[1];
        NSNumber *handle = @(arc4random());
        NSTimer *timer;
        timer = [NSTimer scheduledTimerWithTimeInterval:[[time toNumber] integerValue] / 1000.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (clearTimerHandles[handle] != nil) {
                [timer invalidate];
                [clearTimerHandles removeObjectForKey:handle];
                return;
            }
            [callback callWithArguments:@[]];
        }];
        return handle;
    }
    return @(0);
}

+ (void)clearInterval {
    NSArray *args = [JSContext currentArguments];
    if (args.count == 1) {
        JSValue *handle = args[0];
        if ([handle isNumber]) {
            NSNumber *numberHandle = [handle toNumber];
            if (numberHandle != nil) {
                [clearTimerHandles setObject:@(1) forKey:numberHandle];
            }
        }
    }
}

@end
