//
//  MPIOSClipRRect.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSClipRRect.h"
#import "MPIOSComponentUtils.h"

@interface MPIOSClipRRect ()

@property (nonatomic, assign) float tlRadius;
@property (nonatomic, assign) float trRadius;
@property (nonatomic, assign) float blRadius;
@property (nonatomic, assign) float brRadius;

@end

@implementation MPIOSClipRRect

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self resetClip];
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    self.clipsToBounds = YES;
    if ([attributes[@"borderRadius"] isKindOfClass:[NSString class]]) {
        UIEdgeInsets borderRadius = [MPIOSComponentUtils cornerRadiusFromString:attributes[@"borderRadius"]];
        self.tlRadius = borderRadius.top;
        self.blRadius = borderRadius.left;
        self.brRadius = borderRadius.bottom;
        self.trRadius = borderRadius.right;
    }
    [self resetClip];
}

- (void)resetClip {
    if (self.tlRadius == self.trRadius &&
        self.blRadius == self.brRadius &&
        self.trRadius == self.blRadius) {
        self.layer.cornerRadius = MIN(self.tlRadius,
                                      MIN(CGRectGetWidth(self.frame) / 2.0,
                                          CGRectGetHeight(self.frame) / 2.0));
        self.layer.mask = nil;
    }
    else if (self.tlRadius > 0.0 || self.trRadius > 0.0 || self.blRadius > 0.0 || self.brRadius > 0.0) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        [maskLayer setPath:[MPIOSComponentUtils
                            bezierPathWithValue:UIEdgeInsetsMake(self.tlRadius,
                                                                 self.blRadius,
                                                                 self.brRadius,
                                                                 self.trRadius)
                            size:self.frame.size].CGPath];
        self.layer.mask = maskLayer;
        self.layer.cornerRadius = 0.0;
    }
    else {
        self.layer.cornerRadius = 0.0;
        self.layer.mask = nil;
    }
}

@end

@interface MPIOSClipRRectAncestor ()

@property (nonatomic, assign) float tlRadius;
@property (nonatomic, assign) float trRadius;
@property (nonatomic, assign) float blRadius;
@property (nonatomic, assign) float brRadius;

@end

@implementation MPIOSClipRRectAncestor

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if (self.target == nil) {
        return;
    }
    self.target.clipsToBounds = YES;
    if ([attributes[@"borderRadius"] isKindOfClass:[NSString class]]) {
        UIEdgeInsets borderRadius = [MPIOSComponentUtils cornerRadiusFromString:attributes[@"borderRadius"]];
        self.tlRadius = borderRadius.top;
        self.blRadius = borderRadius.left;
        self.brRadius = borderRadius.bottom;
        self.trRadius = borderRadius.right;
    }
    [self resetClip];
}

- (void)resetClip {
    if (self.target == nil) {
        return;
    }
    if (self.tlRadius == self.trRadius &&
        self.blRadius == self.brRadius &&
        self.trRadius == self.blRadius) {
        self.target.layer.cornerRadius = MIN(self.tlRadius,
                                      MIN(CGRectGetWidth(self.target.frame) / 2.0,
                                          CGRectGetHeight(self.target.frame) / 2.0));
        self.target.layer.mask = nil;
    }
    else if (self.tlRadius > 0.0 || self.trRadius > 0.0 || self.blRadius > 0.0 || self.brRadius > 0.0) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        [maskLayer setPath:[MPIOSComponentUtils
                            bezierPathWithValue:UIEdgeInsetsMake(self.tlRadius,
                                                                 self.blRadius,
                                                                 self.brRadius,
                                                                 self.trRadius)
                            size:self.target.frame.size].CGPath];
        self.target.layer.mask = maskLayer;
        self.target.layer.cornerRadius = 0.0;
    }
    else {
        self.target.layer.cornerRadius = 0.0;
        self.target.layer.mask = nil;
    }
}

@end
