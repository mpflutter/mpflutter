//
//  MPIOSClipOval.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSClipOval.h"

@implementation MPIOSClipOval

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self resetClip];
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    self.clipsToBounds = YES;
    [self resetClip];
}

- (void)resetClip {
    self.layer.cornerRadius = MIN(CGRectGetWidth(self.frame) / 2.0,
                                  CGRectGetHeight(self.frame) / 2.0);
}

@end
