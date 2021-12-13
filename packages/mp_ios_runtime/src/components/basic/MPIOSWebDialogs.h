//
//  MPIOSWebDialogs.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/16.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSWebDialogs : NSObject

+ (void)didReceivedWebDialogsMessage:(NSDictionary *)message engine:(MPIOSEngine *)engine;

@end

NS_ASSUME_NONNULL_END
