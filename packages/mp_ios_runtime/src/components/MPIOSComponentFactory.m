//
//  MPIOSComponentFactory.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSComponentFactory.h"
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSAncestorView.h"
#import "MPIOSRichText.h"
#import "MPIOSColoredBox.h"
#import "MPIOSDecoratedBox.h"
#import "MPIOSForegroundDecoratedBox.h"
#import "MPIOSOpacity.h"
#import "MPIOSClipOval.h"
#import "MPIOSClipRRect.h"
#import "MPIOSGestureDetector.h"
#import "MPIOSIgnorePointer.h"
#import "MPIOSAbsorbPointer.h"
#import "MPIOSOffstage.h"
#import "MPIOSTransform.h"
#import "MPIOSImage.h"
#import "MPIOSListView.h"
#import "MPIOSGridView.h"
#import "MPIOSCustomScrollView.h"
#import "MPIOSCustomPaint.h"
#import "MPIOSEditableText.h"
#import "MPIOSOverlay.h"
#import "MPIOSMPScaffold.h"
#import "MPIOSMPIcon.h"
#import "MPIOSMPWebView.h"
#import "MPIOSMPVideoView.h"
#import "MPIOSMPPageView.h"
#import "MPIOSMPPicker.h"
#import "MPIOSMPDatePicker.h"
#import "MPIOSMPSlider.h"
#import "MPIOSMPSwitch.h"
#import "MPIOSMPCircularProgressIndicator.h"

NSDictionary *components;
NSDictionary *ancestors;

@interface MPIOSComponentFactory ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, MPIOSComponentView *> *cachedView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, MPIOSAncestorView *> *cachedAncestor;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *cachedElement;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSAttributedString *> *cachedAttributedString;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *textMeasureResults;

@end

@implementation MPIOSComponentFactory

+ (void)load {
    [self initializeComponentsIfNeed];
}

+ (void)initializeComponentsIfNeed {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        components = @{
            @"colored_box": [MPIOSColoredBox class],
            @"rich_text": [MPIOSRichText class],
            @"decorated_box": [MPIOSDecoratedBox class],
            @"foreground_decorated_box": [MPIOSForegroundDecoratedBox class],
            @"opacity": [MPIOSOpacity class],
            @"clip_oval": [MPIOSClipOval class],
            @"clip_r_rect": [MPIOSClipRRect class],
            @"gesture_detector": [MPIOSGestureDetector class],
            @"ignore_pointer": [MPIOSIgnorePointer class],
            @"absorb_pointer": [MPIOSAbsorbPointer class],
            @"offstage": [MPIOSOffstage class],
            @"visibility": [MPIOSOffstage class],
            @"transform": [MPIOSTransform class],
            @"image": [MPIOSImage class],
            @"list_view": [MPIOSListView class],
            @"grid_view": [MPIOSGridView class],
            @"custom_scroll_view": [MPIOSCustomScrollView class],
            @"custom_paint": [MPIOSCustomPaint class],
            @"editable_text": [MPIOSEditableText class],
            @"overlay": [MPIOSOverlay class],
            @"mp_scaffold": [MPIOSMPScaffold class],
            @"mp_icon": [MPIOSMPIcon class],
            @"mp_web_view": [MPIOSMPWebView class],
            @"mp_video_view": [MPIOSMPVideoView class],
            @"mp_page_view": [MPIOSMPPageView class],
            @"mp_picker": [MPIOSMPPicker class],
            @"mp_date_picker": [MPIOSMPDatePicker class],
            @"mp_slider": [MPIOSMPSlider class],
            @"mp_switch": [MPIOSMPSwitch class],
            @"mp_circular_progress_indicator": [MPIOSMPCircularProgressIndicator class],
        };
        ancestors = @{
            @"opacity": [MPIOSOpacityAncestor class],
            @"clip_r_rect": [MPIOSClipRRectAncestor class],
        };
    });
}

+ (void)registerPlatformView:(NSString *)name clazz:(Class)clazz {
    [self initializeComponentsIfNeed];
    NSMutableDictionary *c = [components mutableCopy];
    [c setObject:clazz forKey:name];
    components = [c copy];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cachedView = [NSMutableDictionary dictionary];
        _cachedAncestor = [NSMutableDictionary dictionary];
        _cachedElement = [NSMutableDictionary dictionary];
        _cachedAttributedString = [NSMutableDictionary dictionary];
        _textMeasureResults = [NSMutableArray array];
    }
    return self;
}

- (void)callbackTextMeasureResult:(NSNumber *)measureId size:(CGSize)size {
    [self.textMeasureResults addObject:@{
        @"measureId": measureId,
        @"size": @{@"width": @(size.width), @"height": @(size.height)},
    }];
}

- (void)flushTextMeasureResult {
    if (self.textMeasureResults.count > 0) {
        [self.engine sendMessage:@{
            @"type": @"rich_text",
            @"message": @{
                    @"event": @"onMeasured",
                    @"data": self.textMeasureResults.copy,
            },
        }];
        [self.textMeasureResults removeAllObjects];
    }
}

- (void)clear {
    [self.cachedView removeAllObjects];
    [self.cachedElement removeAllObjects];
}

- (MPIOSComponentView *)create:(NSDictionary *)data {
    if (![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSNumber *same = data[@"^"];
    NSString *name = data[@"name"];
    NSNumber *hashCode = data[@"hashCode"];
    if (same != nil &&
        [same isKindOfClass:[NSNumber class]] &&
        [same isEqualToNumber:@(1)] &&
        [hashCode isKindOfClass:[NSNumber class]]) {
        MPIOSComponentView *cachedView = self.cachedView[hashCode];
        return cachedView;
    }
    if (![name isKindOfClass:[NSString class]] ||
        ![hashCode isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    self.cachedElement[hashCode] = data;
    MPIOSComponentView *cachedView = !self.disableCache ? self.cachedView[hashCode] : nil;
    if (cachedView != nil) {
        if ([data[@"ancestors"] isKindOfClass:[NSArray class]]) {
            [cachedView setAncestors:data[@"ancestors"]];
        }
        if ([data[@"constraints"] isKindOfClass:[NSDictionary class]]) {
            [cachedView setConstraints:data[@"constraints"]];
        }
        if ([data[@"attributes"] isKindOfClass:[NSDictionary class]]) {
            [cachedView setAttributes:data[@"attributes"]];
        }
        if ([data[@"children"] isKindOfClass:[NSArray class]]) {
            [cachedView setChildren:[self fetchCachedChildren:data[@"children"]]];
        }
        return cachedView;
    }
    Class clazz = components[name];
    if (clazz == NULL) {
        clazz = [MPIOSComponentView class];
    }
    MPIOSComponentView *view = [[clazz alloc] init];
    if (view == nil) {
        return nil;
    }
    view.factory = self;
    view.engine = self.engine;
    view.hashCode = hashCode;
    if ([data[@"ancestors"] isKindOfClass:[NSArray class]]) {
        [view setAncestors:data[@"ancestors"]];
    }
    if ([data[@"constraints"] isKindOfClass:[NSDictionary class]]) {
        [view setConstraints:data[@"constraints"]];
    }
    if ([data[@"attributes"] isKindOfClass:[NSDictionary class]]) {
        [view setAttributes:data[@"attributes"]];
    }
    if ([data[@"children"] isKindOfClass:[NSArray class]]) {
        if (self.disableCache) {
            [view setChildren:data[@"children"]];
        } else {
            [view setChildren:[self fetchCachedChildren:data[@"children"]]];
        }
    }
    if (!self.disableCache) {
        [self.cachedView setObject:view forKey:hashCode];
    }
    return view;
}

- (MPIOSAncestorView *)createAncestors:(NSDictionary *)data target:(MPIOSComponentView *)target {
    if (![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSNumber *same = data[@"^"];
    NSString *name = data[@"name"];
    NSNumber *hashCode = data[@"hashCode"];
    if (same != nil &&
        [same isKindOfClass:[NSNumber class]] &&
        [same isEqualToNumber:@(1)] &&
        [hashCode isKindOfClass:[NSNumber class]]) {
        MPIOSAncestorView *cachedView = self.cachedAncestor[hashCode];
        return cachedView;
    }
    if (![name isKindOfClass:[NSString class]] ||
        ![hashCode isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    self.cachedElement[hashCode] = data;
    MPIOSAncestorView *cachedAncestor = !self.disableCache ? self.cachedAncestor[hashCode] : nil;
    if (cachedAncestor != nil) {
        if (cachedAncestor.target != nil && cachedAncestor.target != target) {
            [cachedAncestor.target.ownAncestors removeObject:cachedAncestor];
        }
        cachedAncestor.target = target;
        if ([data[@"constraints"] isKindOfClass:[NSDictionary class]]) {
            [cachedAncestor setConstraints:data[@"constraints"]];
        }
        if ([data[@"attributes"] isKindOfClass:[NSDictionary class]]) {
            [cachedAncestor setAttributes:data[@"attributes"]];
        }
        return cachedAncestor;
    }
    Class clazz = ancestors[name];
    if (clazz == NULL) {
        return nil;
    }
    MPIOSAncestorView *view = [[clazz alloc] init];
    if (view == nil) {
        return nil;
    }
    view.target = target;
    if ([data[@"constraints"] isKindOfClass:[NSDictionary class]]) {
        [view setConstraints:data[@"constraints"]];
    }
    if ([data[@"attributes"] isKindOfClass:[NSDictionary class]]) {
        [view setAttributes:data[@"attributes"]];
    }
    if (!self.disableCache) {
        [self.cachedAncestor setObject:view forKey:hashCode];
    }
    return view;
}

- (NSArray *)fetchCachedChildren:(NSArray *)children {
    NSMutableArray *finalChildren = [NSMutableArray array];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSNumber *same = obj[@"^"];
        NSNumber *hashCode = obj[@"hashCode"];
        if (same != nil && self.cachedElement[hashCode] != nil) {
            [finalChildren addObject:self.cachedElement[hashCode]];
        }
        else {
            [finalChildren addObject:obj];
        }
    }];
    return finalChildren.copy;
}

@end
