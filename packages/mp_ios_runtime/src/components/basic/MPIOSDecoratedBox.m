//
//  MPIOSDecoratedBox.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSDecoratedBox.h"
#import "MPIOSComponentUtils.h"

@interface MPIOSDecoratedBox ()

@property (nonatomic, strong) CAGradientLayer *graidentLayer;

@end

@implementation MPIOSDecoratedBox


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _graidentLayer = [CAGradientLayer layer];
        _graidentLayer.hidden = YES;
        [self.layer addSublayer:_graidentLayer];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if (attributes[@"color"] != nil) {
        self.backgroundColor = [MPIOSComponentUtils colorFromString:attributes[@"color"]];
    }
    else {
        self.backgroundColor = nil;
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

- (void)setChildren:(NSArray *)children {
    [super setChildren:children];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MPIOSComponentView class]]) {
            [(MPIOSComponentView *)obj setBorderOffsetConstraints:CGPointMake(self.layer.borderWidth, self.layer.borderWidth)];
        }
    }];
}

- (void)setBorderRadius:(NSDictionary *)attributes {
    NSDictionary *decoration = attributes[@"decoration"];
    if ([decoration isKindOfClass:[NSDictionary class]] &&
         [decoration[@"borderRadius"] isKindOfClass:[NSString class]]) {
        UIEdgeInsets borderRadius = [MPIOSComponentUtils cornerRadiusFromString:decoration[@"borderRadius"]];
        self.layer.cornerRadius = borderRadius.top;
    }
    else {
        self.layer.cornerRadius = 0;
    }
}

- (void)setBorder:(NSDictionary *)attributes {
    NSDictionary *decoration = attributes[@"decoration"];
    if ([decoration isKindOfClass:[NSDictionary class]] &&
         [decoration[@"border"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *border = decoration[@"border"];
        if ([border[@"topWidth"] isKindOfClass:[NSNumber class]]) {
            self.layer.borderWidth = [border[@"topWidth"] floatValue];
            [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[MPIOSComponentView class]]) {
                    [(MPIOSComponentView *)obj setBorderOffsetConstraints:CGPointMake(self.layer.borderWidth, self.layer.borderWidth)];
                }
            }];
        }
        if ([border[@"topColor"] isKindOfClass:[NSString class]]) {
            self.layer.borderColor = [MPIOSComponentUtils colorFromString:border[@"topColor"]].CGColor;
        }
    }
    else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = NULL;
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
                    self.layer.shadowColor = [MPIOSComponentUtils
                                              colorFromString:boxShadow[@"color"]].CGColor;
                }
                if ([boxShadow[@"offset"] isKindOfClass:[NSString class]]) {
                    self.layer.shadowOffset = [MPIOSComponentUtils
                                               shadowOffsetFromString:boxShadow[@"offset"]];
                }
                if ([boxShadow[@"blurRadius"] isKindOfClass:[NSNumber class]]) {
                    self.layer.shadowRadius = [(NSNumber *)boxShadow[@"blurRadius"] floatValue];
                }
                self.layer.shadowOpacity = 1.0;
                return;
            }
        }
    }
    self.layer.shadowColor = nil;
    self.layer.shadowOpacity = 0.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.graidentLayer.frame = self.layer.bounds;
}


@end
