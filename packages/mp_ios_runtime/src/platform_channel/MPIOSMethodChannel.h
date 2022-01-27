//
//  MPIOSMethodChannel.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

typedef void(^MPIOSMethodChannelResult)(id _Nullable result);

#define MPIOSMethodChannelNOTImplemented [NSError errorWithDomain:@"MPPlatformChannel" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"MPPlatformChannel Not Implemented."}]

@interface MPIOSMethodChannel : NSObject

@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, weak) MPIOSEngine *engine;

- (void)onMethodCall:(NSString * _Nonnull)method params:(id _Nullable)params result:(MPIOSMethodChannelResult _Nonnull)result;
- (void)invokeMethod:(NSString * _Nonnull)method params:(id _Nullable)params result:(MPIOSMethodChannelResult _Nonnull)result;

@end

NS_ASSUME_NONNULL_END
