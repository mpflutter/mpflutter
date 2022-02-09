//
//  MPIOSOverlay.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSOverlay.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSEngine+Private.h"

@interface MPIOSOverlay ()

@property (nonatomic, strong) NSNumber *onBackgroundTap;

@end

@implementation MPIOSOverlay

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if ([attributes[@"backgroundColor"] isKindOfClass:[NSString class]]) {
        self.backgroundColor = [MPIOSComponentUtils
                                       colorFromString:attributes[@"backgroundColor"]];
    }
    else {
        self.backgroundColor = nil;
    }
    if ([attributes[@"onBackgroundTap"] isKindOfClass:[NSNumber class]]) {
        self.onBackgroundTap = attributes[@"onBackgroundTap"];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(onTap)]];
    }
    else {
        self.onBackgroundTap = nil;
    }
}

- (void)onTap {
    if (self.onBackgroundTap != nil) {
        MPIOSEngine *engine = self.engine;
        if (engine != nil) {
            [engine sendMessage:@{
                @"type": @"overlay",
                @"message": @{
                        @"event": @"onBackgroundTap",
                        @"target": self.onBackgroundTap,
                },
            }];
        }
    }
}

@end
