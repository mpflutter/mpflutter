//
//  MPIOSOpacity.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSOpacity.h"

@implementation MPIOSOpacity

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if ([attributes[@"opacity"] isKindOfClass:[NSNumber class]]) {
        self.alpha = [attributes[@"opacity"] doubleValue];
    }
}

@end

@implementation MPIOSOpacityAncestor

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if ([attributes[@"opacity"] isKindOfClass:[NSNumber class]]) {
        self.target.alpha *= [attributes[@"opacity"] doubleValue];
    }
}

@end
