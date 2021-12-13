//
//  MPIOSOffstage.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSOffstage.h"

@implementation MPIOSOffstage

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSNumber *offstage = attributes[@"offstage"];
    NSNumber *visible = attributes[@"visible"];
    if ([offstage isKindOfClass:[NSNumber class]] && [offstage boolValue]) {
        self.hidden = YES;
    }
    else if ([visible isKindOfClass:[NSNumber class]] && ![visible boolValue]) {
        self.hidden = YES;
    }
    else {
        self.hidden = NO;
    }
    
}

@end
