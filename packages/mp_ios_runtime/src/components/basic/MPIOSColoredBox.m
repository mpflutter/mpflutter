//
//  MPIOSColoredBox.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSColoredBox.h"
#import "MPIOSComponentUtils.h"

@implementation MPIOSColoredBox

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if (attributes[@"color"] != nil) {
        self.backgroundColor = [MPIOSComponentUtils colorFromString:attributes[@"color"]];
    }
    else {
        self.backgroundColor = nil;
    }
}

@end
