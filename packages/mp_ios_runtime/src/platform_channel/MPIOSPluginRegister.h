//
//  MPIOSPluginRegister.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSPluginRegister : NSObject

+ (NSDictionary *)allRegistedChannels;
+ (void)registerChannel:(NSString *)name clazz:(Class)clazz;
+ (void)registerPlatformView:(NSString *)name clazz:(Class)clazz;

@end

NS_ASSUME_NONNULL_END
