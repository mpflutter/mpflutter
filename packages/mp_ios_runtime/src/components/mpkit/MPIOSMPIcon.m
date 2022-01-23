//
//  MPIOSMPIcon.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/16.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPIcon.h"
#import "MPIOSImage.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSProvider.h"
#import <objc/runtime.h>

@interface MPIOSMPIcon ()

@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, assign) BOOL changingColor;
@property (nonatomic, strong) UIColor *color;

@end

@implementation MPIOSMPIcon

- (void)dealloc {
    if (_contentView != nil) {
        [_contentView removeObserver:self forKeyPath:@"image" context:NULL];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (NSClassFromString(@"SVGKImageView") == NULL) {
            NSLog(@"SVGKit not installed, the MPIcon component depends it.");
            return self;
        }
        self.userInteractionEnabled = NO;
        _contentView = [[NSClassFromString(@"SVGKFastImageView") alloc] initWithFrame:CGRectZero];
        _contentView.clipsToBounds = YES;
        [_contentView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (!self.changingColor) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetImageColor];
        });
    }
}

- (void)setChildren:(NSArray *)children {}

- (void)setAttributes:(NSDictionary *)attributes {
    if (self.contentView == nil) {
        return;
    }
    [super setAttributes:attributes];
    NSString *iconUrl = attributes[@"iconUrl"];
    if ([iconUrl isKindOfClass:[NSString class]]) {
        [self.engine.provider.imageProvider loadImageWithURLString:iconUrl
                                                         imageView:self.contentView];
    }
    NSString *color = attributes[@"color"];
    if ([color isKindOfClass:[NSString class]]) {
        self.color = [MPIOSComponentUtils colorFromString:color];
        [self resetImageColor];
    }
}

- (void)resetImageColor {
    id image = [self.contentView image];
    if (image != nil && [NSStringFromClass([image class]) isEqualToString:@"SVGKImage"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self changerLayerFillColor:[image performSelector:@selector(CALayerTree)] tintColor:self.color];
#pragma clang diagnostic pop
        self.changingColor = YES;
        [self.contentView setImage:image];
        [self.contentView setNeedsDisplay];
        self.changingColor = NO;
    }
}

- (void)changerLayerFillColor:(CALayer *)layer tintColor:(UIColor *)tintColor {
    if ([layer isKindOfClass:[CAShapeLayer class]]) {
        CAShapeLayer *shapeLayer = (id)layer;
        if (shapeLayer.strokeColor != nil) {
            [shapeLayer setStrokeColor:tintColor.CGColor];
        }
        if (shapeLayer.fillColor != nil) {
            [shapeLayer setFillColor:tintColor.CGColor];
        }
    }
    for (CALayer *sublayer in layer.sublayers) {
        [self changerLayerFillColor:sublayer tintColor:tintColor];
    }
}

- (void)setFrame:(CGRect)frame {
    if (self.contentView == nil) {
        return;
    }
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews {
    if (self.contentView == nil) {
        return;
    }
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}

@end
