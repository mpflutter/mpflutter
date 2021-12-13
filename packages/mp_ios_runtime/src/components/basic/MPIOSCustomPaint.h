//
//  MPIOSCustomPaint.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/17.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

@interface MPIOSDrawableStorage : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;

- (void)decodeDrawable:(NSDictionary *)params;

@end

@interface MPIOSCustomPaint : MPIOSComponentView

+ (void)didReceivedCustomPaintMessage:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine;

@end

NS_ASSUME_NONNULL_END
