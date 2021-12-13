//
//  MPIOSWindowInfo.h
//  mp_ios_runtime
//
//  Created by ydt on 12.10.21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

@interface MPIOSWindowInfo : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;

- (void)updateWindowInfo;

@end

NS_ASSUME_NONNULL_END
