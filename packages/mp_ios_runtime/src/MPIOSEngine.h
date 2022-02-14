//
//  MPIOSEngine.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPIOSDataReceiver <NSObject>

- (void)didReceivedFrameData:(NSDictionary *)message;

@end

@class MPIOSProvider;

@interface MPIOSEngine : NSObject

@property (nonatomic, strong) MPIOSProvider *provider;

- (instancetype)initWithJSCode:(NSString *)jsCode;
- (instancetype)initWithDebuggerServerAddr:(NSString *)debuggerServerAddr;
- (instancetype)initWithMpkData:(NSData *)mpkData;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
