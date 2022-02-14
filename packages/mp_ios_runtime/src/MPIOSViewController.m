//
//  MPIOSViewController.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/18.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSViewController.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSRouter.h"

@interface MPIOSViewController ()

@property (nonatomic, strong) MPIOSPage *page;
@property (nonatomic, assign) CGRect lastViewBounds;
@property (nonatomic, assign) BOOL firstShowed;

@end

@implementation MPIOSViewController

- (void)dealloc {
    if (self.engine != nil && self.page.viewId != nil) {
        [self.engine.managedViews removeObjectForKey:self.page.viewId];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    if (!CGRectIsEmpty(self.initialViewBounds)) {
        self.view.frame = self.initialViewBounds;
    }
    self.lastViewBounds = self.view.bounds;
    self.page = [[MPIOSPage alloc] initWithRootView:self.view
                                             engine:self.engine
                                        isFirstPage:self.isFirstPage
                                       initialRoute:self.initialRouteName
                                      initialParams:self.initialRouteParams];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.firstShowed) {
        MPIOSEngine *engine = self.engine;
        if (engine != nil) {
            [engine.router triggerPop:self.page.viewId];
        }
    }
    else {
        self.firstShowed = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.parentViewController == nil) {
        MPIOSEngine *engine = self.engine;
        if (engine != nil) {
            [engine.router dispose:self.page.viewId];
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!CGRectEqualToRect(self.lastViewBounds, self.view.bounds) && self.page.viewId != nil) {
        self.lastViewBounds = self.view.bounds;
        [self.engine.router updateRouteViewport:self.page.viewId viewport:self.view.bounds.size];
    }
}

- (void)onReachBottom {
    [self.page onReachBottom];
}

- (void)onPageScroll:(double)scrollTop {
    [self.page onPageScroll:scrollTop];
}

- (id)copy {
    MPIOSViewController *copyInstance = [[self class] new];
    copyInstance.engine = self.engine;
    copyInstance.initialRouteName = self.initialRouteName;
    copyInstance.initialRouteParams = self.initialRouteParams;
    return copyInstance;
}

@end
