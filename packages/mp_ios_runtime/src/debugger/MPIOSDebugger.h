//
//  MPIOSDebugger.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

@interface MPIOSDebugger : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;
@property (nonatomic, strong) NSString *serverAddr;

- (void)start;
- (void)sendMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
