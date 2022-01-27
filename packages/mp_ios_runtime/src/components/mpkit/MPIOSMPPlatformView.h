//
//  MPIOSMPPlatformView.h
//  mp_ios_runtime
//
//  Created by ydt on 10.12.21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSComponentView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MPIOSPlatformViewCallback)(id result);

@class MPIOSEngine;

@interface MPIOSMPPlatformView : MPIOSComponentView

+ (void)didReceivedPlatformViewMessage:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine;
- (void)onMethodCall:(NSString *)method params:(NSDictionary *)params resultCallback:(MPIOSPlatformViewCallback)resultCallback;
- (void)invokeMethod:(NSString *)method params:(NSDictionary *)params;
- (void)invokeMethod:(NSString *)method params:(NSDictionary *)params resultCallback:(MPIOSPlatformViewCallback)resultCallback;

@end

NS_ASSUME_NONNULL_END
