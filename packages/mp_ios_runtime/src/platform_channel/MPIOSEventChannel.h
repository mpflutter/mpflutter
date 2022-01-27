//
//  MPIOSEventChannel.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

typedef void(^MPIOSEventChannelEventSink)(id data);

@interface MPIOSEventChannel : NSObject

@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, weak) MPIOSEngine *engine;

- (void)onListen:(id)params eventSink:(MPIOSEventChannelEventSink)eventSink;
- (void)onCancel:(id)params;

@end

NS_ASSUME_NONNULL_END
