//
//  MPIOSTextMeasurer.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/10/6.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSTextMeasurer.h"
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSComponentFactory.h"

@implementation MPIOSTextMeasurer

- (void)didReceivedDoMeasureData:(NSDictionary *)data {
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSArray *items = data[@"items"];
    if (![items isKindOfClass:[NSArray class]]) {
        return;
    }
    self.engine.componentFactory.disableCache = YES;
    NSMutableArray *views = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPIOSComponentView *view = [self.engine.componentFactory create:obj];
        if (view != nil) {
            [views addObject:view];
        }
    }];
    self.engine.componentFactory.disableCache = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.engine.componentFactory flushTextMeasureResult];
    });
}

@end
