//
//  MPIOSComponentView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSComponentView.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSAncestorView.h"
#import "MPIOSGestureDetector.h"
#import "MPIOSMPPlatformView.h"
#import "MPIOSDecoratedBox.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSComponentView ()

@property (nonatomic, strong) NSDictionary *constraints;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSMutableArray<MPIOSAncestorView *> *ownAncestors;

@end

@implementation MPIOSComponentView

- (void)setConstraints:(NSDictionary *)constraints {
    if (![constraints isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _constraints = constraints;
    [self updateLayout];
}

- (void)setBorderOffsetConstraints:(CGPoint)borderOffsetConstraints {
    _borderOffsetConstraints = borderOffsetConstraints;
    [self updateLayout];
}

- (void)updateLayout {
    if (self.constraints == nil) {
        return;
    }
    __block NSNumber *x = self.constraints[@"x"];
    __block NSNumber *y = self.constraints[@"y"];
    NSNumber *w = self.constraints[@"w"];
    NSNumber *h = self.constraints[@"h"];
    if (self.ownAncestors != nil) {
        [self.ownAncestors enumerateObjectsUsingBlock:^(MPIOSAncestorView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.constraints != nil) {
                if (x != nil && [obj.constraints[@"x"] isKindOfClass:[NSNumber class]]) {
                    x = @([x floatValue] + [obj.constraints[@"x"] floatValue]);
                }
                if (y != nil && [obj.constraints[@"y"] isKindOfClass:[NSNumber class]]) {
                    y = @([y floatValue] + [obj.constraints[@"y"] floatValue]);
                }
            }
        }];
    }
    if (!CGPointEqualToPoint(self.borderOffsetConstraints, CGPointZero) &&
        [self.superview isKindOfClass:[MPIOSDecoratedBox class]]) {
        if (x != nil) {
            x = @(x.floatValue + self.borderOffsetConstraints.x);
        }
        if (y != nil) {
            y = @(y.floatValue + self.borderOffsetConstraints.y);
        }
    }
    if (x != nil && y != nil && w != nil && h != nil) {
        [self setFrame:CGRectMake(x.floatValue, y.floatValue, w.floatValue, h.floatValue)];
        [self layoutSubviews];
        id<MPIOSComponentViewDelegate> delegate = self.delegate;
        if (delegate != nil) {
            if ([delegate respondsToSelector:@selector(componentViewConstraintDidChanged:)]) {
                [delegate componentViewConstraintDidChanged:self];
            }
        }
    }
}

- (void)setAttributes:(NSDictionary *)attributes {
    _attributes = attributes;
}

- (void)setAncestors:(NSArray *)ancestors {
    if (![ancestors isKindOfClass:[NSArray class]] && [self.ownAncestors count] > 0) {
        [self resetAncestorStyle];
        self.ownAncestors = [NSMutableArray array];
    }
    else {
        [self resetAncestorStyle];
        NSMutableArray *ancestorsView = [NSMutableArray array];
        [ancestors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MPIOSAncestorView *view = [self.factory createAncestors:obj target:self];
            if (view != nil) {
                [ancestorsView addObject:view];
            }
        }];
        self.ownAncestors = ancestorsView;
    }
}

- (void)resetAncestorStyle {
    self.alpha = 1.0;
    self.layer.cornerRadius = 0.0;
    self.layer.mask = nil;
}

- (void)setChildren:(NSArray *)children {
    if (![children isKindOfClass:[NSArray class]]) {
        return;
    }
    NSMutableArray<MPIOSComponentView *> *makeSubviews = [NSMutableArray array];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPIOSComponentFactory *factory = self.factory;
        if (factory == nil) {
            return;
        }
        MPIOSComponentView *view = [factory create:obj];
        if (view != nil) {
            [makeSubviews addObject:view];
        }
    }];
    __block BOOL changed = NO;
    if (makeSubviews.count != self.subviews.count) {
        changed = YES;
    }
    else {
        [makeSubviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != self.subviews[idx]) {
                changed = YES;
            }
        }];
    }
    if (changed) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [makeSubviews enumerateObjectsUsingBlock:^(MPIOSComponentView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
    }
}

- (MPIOSViewController *)getViewController {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:[MPIOSViewController class]]) {
            return (id)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

@end
