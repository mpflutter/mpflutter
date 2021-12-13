//
//  MPIOSForegroundDecoratedBox.m
//  mp_ios_runtime
//
//  Created by ydt on 12.10.21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSForegroundDecoratedBox.h"
#import "MPIOSComponentUtils.h"

@interface MPIOSForegroundDecoratedBox ()

@property (nonatomic, strong) CALayer *frontLayer;
@property (nonatomic, strong) CAGradientLayer *graidentLayer;

@end

@implementation MPIOSForegroundDecoratedBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _frontLayer = [CALayer layer];
        _frontLayer.zPosition = 1;
        _graidentLayer = [CAGradientLayer layer];
        _graidentLayer.hidden = YES;
        [_frontLayer addSublayer:_graidentLayer];
        [self.layer addSublayer:_frontLayer];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if (attributes[@"color"] != nil) {
        self.frontLayer.backgroundColor = [[MPIOSComponentUtils colorFromString:attributes[@"color"]] CGColor];
    }
    else {
        self.frontLayer.backgroundColor = nil;
    }
    NSDictionary *decoration = attributes[@"decoration"];
    if ([decoration isKindOfClass:[NSDictionary class]] &&
        [decoration[@"gradient"] isKindOfClass:[NSDictionary class]]) {
        self.graidentLayer.startPoint = [MPIOSComponentUtils locationFromGradient:decoration[@"gradient"][@"begin"]];
        self.graidentLayer.endPoint = [MPIOSComponentUtils locationFromGradient:decoration[@"gradient"][@"end"]];
        self.graidentLayer.locations = [MPIOSComponentUtils stopsFromGradient:decoration[@"gradient"]];
        self.graidentLayer.colors = [MPIOSComponentUtils colorsFromGradient:decoration[@"gradient"]];
        if ([@"RadialGradient" isEqualToString:decoration[@"gradient"][@"classname"]]) {
            self.graidentLayer.type = kCAGradientLayerRadial;
            self.graidentLayer.startPoint = CGPointMake(0.5, 0.5);
            self.graidentLayer.endPoint = CGPointMake(0.0, 1.0);
        }
        else {
            self.graidentLayer.type = kCAGradientLayerAxial;
        }
        self.graidentLayer.hidden = NO;
    }
    else {
        self.graidentLayer.hidden = YES;
    }
    [self setBorderRadius:attributes];
    [self setBorder:attributes];
    [self setShadows:attributes];
}

- (void)setBorderRadius:(NSDictionary *)attributes {
    NSDictionary *decoration = attributes[@"decoration"];
    if ([decoration isKindOfClass:[NSDictionary class]] &&
         [decoration[@"borderRadius"] isKindOfClass:[NSString class]]) {
        UIEdgeInsets borderRadius = [MPIOSComponentUtils cornerRadiusFromString:decoration[@"borderRadius"]];
        self.frontLayer.cornerRadius = borderRadius.top;
        self.frontLayer.masksToBounds = YES;
    }
    else {
        self.frontLayer.cornerRadius = 0;
        self.frontLayer.masksToBounds = NO;
    }
}

- (void)setBorder:(NSDictionary *)attributes {
    NSDictionary *decoration = attributes[@"decoration"];
    if ([decoration isKindOfClass:[NSDictionary class]] &&
         [decoration[@"border"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *border = decoration[@"border"];
        if ([border[@"topWidth"] isKindOfClass:[NSNumber class]]) {
            self.frontLayer.borderWidth = [border[@"topWidth"] floatValue];
        }
        if ([border[@"topColor"] isKindOfClass:[NSString class]]) {
            self.frontLayer.borderColor = [MPIOSComponentUtils colorFromString:border[@"topColor"]].CGColor;
        }
    }
    else {
        self.frontLayer.borderWidth = 0;
        self.frontLayer.borderColor = NULL;
    }
}

- (void)setShadows:(NSDictionary *)attributes {
    NSDictionary *decoration = attributes[@"decoration"];
    if ([decoration isKindOfClass:[NSDictionary class]]) {
        NSArray *boxShadows = decoration[@"boxShadow"];
        if ([boxShadows isKindOfClass:[NSArray class]] && boxShadows.count > 0) {
            NSDictionary *boxShadow = boxShadows[0];
            if ([boxShadow isKindOfClass:[NSDictionary class]]) {
                if ([boxShadow[@"color"] isKindOfClass:[NSString class]]) {
                    self.frontLayer.shadowColor = [MPIOSComponentUtils
                                              colorFromString:boxShadow[@"color"]].CGColor;
                }
                if ([boxShadow[@"offset"] isKindOfClass:[NSString class]]) {
                    self.frontLayer.shadowOffset = [MPIOSComponentUtils
                                               shadowOffsetFromString:boxShadow[@"offset"]];
                }
                if ([boxShadow[@"blurRadius"] isKindOfClass:[NSNumber class]]) {
                    self.frontLayer.shadowRadius = [(NSNumber *)boxShadow[@"blurRadius"] floatValue];
                }
                self.frontLayer.shadowOpacity = 1.0;
                return;
            }
        }
    }
    self.frontLayer.shadowColor = nil;
    self.frontLayer.shadowOpacity = 0.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frontLayer.frame = self.layer.bounds;
    self.graidentLayer.frame = self.layer.bounds;
}

@end
