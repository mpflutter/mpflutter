//
//  MPIOSStorage.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSStorage.h"
#import "MPIOSEngine.h"
#import "MPIOSProvider.h"

@implementation MPIOSStorage

+ (void)setupWithJSContext:(JSContext *)context engine:(nonnull MPIOSEngine *)engine {
    NSUserDefaults *userDefaults = [engine.provider.dataProvider createUserDefaults];
    context.globalObject[@"wx"][@"removeStorageSync"] = ^(NSString *key){
        if ([key isKindOfClass:[NSString class]]) {
            [userDefaults removeObjectForKey:key];
        }
    };
    context.globalObject[@"wx"][@"getStorageSync"] = ^JSValue* (NSString *key){
        if ([key isKindOfClass:[NSString class]]) {
            return [userDefaults valueForKey:key];
        }
        else {
            return nil;
        }
    };
    context.globalObject[@"wx"][@"setStorageSync"] = ^(NSString *key, JSValue *value){
        if ([key isKindOfClass:[NSString class]]) {
            id obj = value.toObject;
            if (obj != nil) {
                [userDefaults setObject:obj forKey:key];
            }
        }
    };
    context.globalObject[@"wx"][@"getStorageInfoSync"] = ^NSDictionary* (){
        return @{
            @"keys": [[userDefaults dictionaryRepresentation] allKeys],
        };
    };
}

@end
