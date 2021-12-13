//
//  MPIOSMPJS.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSMPJS : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;

- (instancetype)initWithEngine:(MPIOSEngine *)engine;

- (void)didReceivedMessage:(NSDictionary *)message;

@end

NS_ASSUME_NONNULL_END
