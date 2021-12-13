//
//  MPIOSIgnorePointer.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSIgnorePointer.h"

@implementation MPIOSIgnorePointer

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSNumber *ignoring = attributes[@"ignoring"];
    if ([ignoring isKindOfClass:[NSNumber class]] && [ignoring boolValue]) {
        self.userInteractionEnabled = NO;
    }
    else {
        self.userInteractionEnabled = YES;
    }
}

@end
