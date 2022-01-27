//
//  MPIOSPluginRegister.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSPluginRegister.h"
#import "MPIOSComponentFactory.h"

@implementation MPIOSPluginRegister

static NSMutableDictionary *registedChannels;

+ (NSDictionary *)allRegistedChannels {
    return registedChannels;
}

+ (void)registerChannel:(NSString *)name clazz:(Class)clazz {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registedChannels = [NSMutableDictionary dictionary];
    });
    [registedChannels setObject:clazz forKey:name];
}

+ (void)registerPlatformView:(NSString *)name clazz:(Class)clazz {
    [MPIOSComponentFactory registerPlatformView:name clazz:clazz];
}

@end
