//
//  MPIOSMethodChannel.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSMethodChannel.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSPlatformChannelIO.h"

@implementation MPIOSMethodChannel

- (void)onMethodCall:(NSString *)method params:(id)params result:(MPIOSMethodChannelResult)result {
}

- (void)invokeMethod:(NSString *)method params:(id)params result:(MPIOSMethodChannelResult)result {
    __strong MPIOSEngine *strongEngine = self.engine;
    if (strongEngine != nil) {
        NSString *seqId = [[NSUUID UUID] UUIDString];
        [strongEngine sendMessage:@{
            @"type": @"platform_channel",
                    @"message": @{
                          @"event": @"invokeMethod",
                          @"method": self.channelName ?: [NSNull null],
                          @"beInvokeMethod": method ?: [NSNull null],
                          @"beInvokeParams": params ?: [NSNull null],
                          @"seqId": seqId,
                    },
        }];
        if (result != nil) {
            [strongEngine.platformChannelIO.responseCallbacks setObject:result forKey:seqId];
        }
    }
}

@end
