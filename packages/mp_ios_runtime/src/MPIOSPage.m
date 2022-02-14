//
//  MPIOSPage.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/7/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSPage.h"
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSRouter.h"
#import "MPIOSComponentFactory.h"
#import "MPIOSComponentView.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSMPScaffold.h"

@interface MPIOSPage ()<MPIOSDataReceiver>

@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, weak) MPIOSEngine *engine;
@property (nonatomic, copy) NSString *initialRoute;
@property (nonatomic, copy) NSDictionary *initialParams;
@property (nonatomic, strong) NSNumber *viewId;
@property (nonatomic, strong) MPIOSComponentView *scaffoldView;
@property (nonatomic, strong) NSMutableArray *overlaysView;

@end

@implementation MPIOSPage

- (instancetype)initWithRootView:(UIView *)rootView
                          engine:(MPIOSEngine *)engine
                     isFirstPage:(BOOL)isFirstPage
                    initialRoute:(NSString *)initialRoute
                   initialParams:(NSDictionary *)initialParams
{
    self = [super init];
    if (self) {
        _rootView = rootView;
        _engine = engine;
        _isFirstPage = isFirstPage;
        _initialRoute = initialRoute;
        _initialParams = initialParams;
        [self requestRoute:^(NSNumber *viewId) {
            self.viewId = viewId;
            [self.engine.managedViews setObject:self forKey:self.viewId];
        }];
    }
    return self;
}

- (void)requestRoute:(MPIOSRouteResponseBlock)completionBlock {
    MPIOSRouter *router = self.engine.router;
    if (router != nil) {
        [router requestRoute:self.initialRoute
                 routeParams:self.initialParams
                      isRoot:self.isFirstPage
                    viewport:self.rootView.bounds.size
             completionBlock:completionBlock];
    }
}

- (void)didReceivedFrameData:(NSDictionary *)message {
    NSDictionary *scaffold = message[@"scaffold"];
    MPIOSComponentView *scaffoldView = [self.engine.componentFactory create:scaffold];
    if (scaffoldView != nil && scaffoldView.superview != self.rootView) {
        [self.scaffoldView removeFromSuperview];
        scaffoldView.frame = self.rootView.bounds;
        [self.rootView addSubview:scaffoldView];
    }
    self.scaffoldView = scaffoldView;
    NSArray *overlays = message[@"overlays"];
    if ([overlays isKindOfClass:[NSArray class]]) {
        [self setOverlays:overlays];
    }
}

- (void)setOverlays:(NSArray *)overlays {
    if (self.overlaysView != nil) {
        [self.overlaysView enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
    }
    NSMutableArray *overlaysView = [NSMutableArray array];
    [overlays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPIOSComponentView *overlayView = [self.engine.componentFactory create:obj];
        if (overlayView != nil) {
            [overlaysView addObject:overlayView];
        }
    }];
    UIWindow *currentWindow = [self getCurrentWindow];
    if (currentWindow != nil) {
        [overlaysView enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [currentWindow addSubview:obj];
        }];
    }
    self.overlaysView = overlaysView.copy;
}

- (void)onReachBottom {
    if ([self.scaffoldView isKindOfClass:[MPIOSMPScaffold class]]) {
        [(MPIOSMPScaffold *)self.scaffoldView onReachBottom];
    }
}

- (void)onPageScroll:(double)scrollTop {
    if ([self.scaffoldView isKindOfClass:[MPIOSMPScaffold class]]) {
        [(MPIOSMPScaffold *)self.scaffoldView onPageScroll:scrollTop];
    }
}

- (UIWindow *)getCurrentWindow {
    UIResponder *responder = [self.rootView nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:[UIWindow class]]) {
            return (id)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

@end
