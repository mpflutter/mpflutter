//
//  MPIOSTextMeasurer.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/10/6.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSEngine;

@interface MPIOSTextMeasurer : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;

- (void)didReceivedDoMeasureData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
