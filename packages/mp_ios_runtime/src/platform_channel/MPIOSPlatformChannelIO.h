//
//  MPIOSPlatformChannelIO.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPIOSMethodChannel.h"

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

@interface MPIOSPlatformChannelIO : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, MPIOSMethodChannelResult> *responseCallbacks;
@property (nonatomic, weak) MPIOSEngine *engine;

- (instancetype)initWithEngine:(MPIOSEngine *)engine;
- (void)didReceivedMessage:(NSDictionary *)message;

@end

NS_ASSUME_NONNULL_END
