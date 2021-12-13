//
//  MPIOSStorage.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSStorage.h"

@implementation MPIOSStorage

+ (void)setupWithJSContext:(JSContext *)context {
    context.globalObject[@"wx"][@"removeStorageSync"] = ^(NSString *key){
        if ([key isKindOfClass:[NSString class]]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
    };
    context.globalObject[@"wx"][@"getStorageSync"] = ^JSValue* (NSString *key){
        if ([key isKindOfClass:[NSString class]]) {
            return [[NSUserDefaults standardUserDefaults] valueForKey:key];
        }
        else {
            return nil;
        }
    };
    context.globalObject[@"wx"][@"setStorageSync"] = ^(NSString *key, JSValue *value){
        if ([key isKindOfClass:[NSString class]]) {
            id obj = value.toObject;
            if (obj != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
            }
        }
    };
    context.globalObject[@"wx"][@"getStorageInfoSync"] = ^NSDictionary* (){
        return @{
            @"keys": [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys],
        };
    };
}

@end
