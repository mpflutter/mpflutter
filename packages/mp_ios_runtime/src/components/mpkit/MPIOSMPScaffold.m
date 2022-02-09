//
//  MPIOSMPScaffold.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPScaffold.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSMPScaffold ()<MPIOSComponentViewDelegate>

@property (nonatomic, strong) NSDictionary *mAttributes;
@property (nonatomic, strong) MPIOSComponentView *appBar;
@property (nonatomic, strong) MPIOSComponentView *body;
@property (nonatomic, strong) MPIOSComponentView *bottomBar;
@property (nonatomic, strong) MPIOSComponentView *floatingBody;

@end

@implementation MPIOSMPScaffold

- (void)setAppBar:(MPIOSComponentView *)appBar {
    if (appBar == nil) {
        [_appBar removeFromSuperview];
        _appBar = nil;
        return;
    }
    if (_appBar != appBar && ![_appBar.hashCode isEqualToNumber:appBar.hashCode]) {
        _appBar = appBar;
        [self readdSubviews];
    }
}

- (void)setBody:(MPIOSComponentView *)body {
    if (body == nil) {
        [_body removeFromSuperview];
        _body = nil;
        return;
    }
    if (_body != body && ![_body.hashCode isEqualToNumber:body.hashCode]) {
        _body = body;
        [self readdSubviews];
    }
}

- (void)setBottomBar:(MPIOSComponentView *)bottomBar {
    if (bottomBar == nil) {
        [_bottomBar removeFromSuperview];
        _bottomBar = nil;
        return;
    }
    if (_bottomBar != bottomBar && ![_bottomBar.hashCode isEqualToNumber:bottomBar.hashCode]) {
        _bottomBar = bottomBar;
        [self readdSubviews];
    }
}

- (void)setFloatingBody:(MPIOSComponentView *)floatingBody {
    if (floatingBody == nil) {
        [_floatingBody removeFromSuperview];
        _floatingBody = nil;
        return;
    }
    if (_floatingBody != floatingBody && ![_floatingBody.hashCode isEqualToNumber:floatingBody.hashCode]) {
        _floatingBody = floatingBody;
        [self readdSubviews];
    }
}

- (void)readdSubviews {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    if (self.body != nil) {
        [self addSubview:self.body];
        [self setNeedsLayout];
    }
    if (self.appBar != nil) {
        [self addSubview:self.appBar];
        [self setNeedsLayout];
    }
    if (self.bottomBar != nil) {
        [self addSubview:self.bottomBar];
        [self setNeedsLayout];
    }
    if (self.floatingBody != nil) {
        [self addSubview:self.floatingBody];
    }
}

- (void)setChildren:(NSArray *)children {}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    self.mAttributes = attributes;
    MPIOSComponentFactory *factory = self.factory;
    if (factory == nil) {
        return;
    }
    self.appBar = [factory create:attributes[@"appBar"]];
    self.appBar.delegate = self;
    self.body = [factory create:attributes[@"body"]];
    self.body.delegate = self;
    self.bottomBar = [factory create:attributes[@"bottomBar"]];
    self.bottomBar.delegate = self;
    self.floatingBody = [factory create:attributes[@"floatingBody"]];
    self.floatingBody.delegate = self;
    if (attributes[@"backgroundColor"] != nil) {
        self.backgroundColor = [MPIOSComponentUtils colorFromString:attributes[@"backgroundColor"]];
    }
    else {
        self.backgroundColor = nil;
    }
    [self setNavigationItems:attributes];
}

- (void)didMoveToWindow {
    [self setNavigationItems:self.mAttributes];
}

- (void)setNavigationItems:(NSDictionary *)attributes {
    MPIOSViewController *viewController = [self getViewController];
    if (viewController == nil) {
        return;
    }
    NSString *name = attributes[@"name"];
    if ([name isKindOfClass:[NSString class]]) {
        viewController.title = name;
    }
    else {
        viewController.title = nil;
    }
}

- (void)onReachBottom {
    [self.engine sendMessage:@{
        @"type": @"scaffold",
        @"message": @{
                @"event": @"onReachBottom",
                @"target": self.hashCode ?: [NSNull null],
        },
    }];
}

- (void)onPageScroll:(double)scrollTop {
    [self.engine sendMessage:@{
        @"type": @"scaffold",
        @"message": @{
                @"event": @"onPageScroll",
                @"target": self.hashCode ?: [NSNull null],
                @"scrollTop": @(scrollTop),
        },
    }];
}

- (void)componentViewConstraintDidChanged:(MPIOSComponentView *)view {
    [self setNeedsLayout];
}

@end
