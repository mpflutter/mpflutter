//
//  MPIOSTransform.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSTransform.h"
#import "MPIOSComponentUtils.h"

@interface MPIOSTransform ()

@property (nonatomic, assign) CGAffineTransform attrTransform;

@end

@implementation MPIOSTransform

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *transform = attributes[@"transform"];
    if ([transform isKindOfClass:[NSString class]]) {
        transform = [transform stringByReplacingOccurrencesOfString:@"matrix(" withString:@""];
        transform = [transform stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray *parts = [transform componentsSeparatedByString:@","];
        if (parts.count == 6) {
            self.attrTransform = CGAffineTransformMake([MPIOSComponentUtils floatFromString:parts[0]],
                                                       [MPIOSComponentUtils floatFromString:parts[1]],
                                                       [MPIOSComponentUtils floatFromString:parts[2]],
                                                       [MPIOSComponentUtils floatFromString:parts[3]],
                                                       [MPIOSComponentUtils floatFromString:parts[4]],
                                                       [MPIOSComponentUtils floatFromString:parts[5]]);
            self.transform = CGAffineTransformIdentity;
            [self applyTransform];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    self.transform = CGAffineTransformIdentity;
    [super setFrame:frame];
    [self applyTransform];
}

- (void)applyTransform {
    self.transform = self.attrTransform;
}

@end
