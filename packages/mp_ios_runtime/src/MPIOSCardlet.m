//
//  MPIOSCardlet.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/2/14.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSCardlet.h"
#import "MPIOSViewController.h"
#import "MPIOSProvider.h"

@interface MPIOSCardlet ()

@property (nonatomic, strong) MPIOSEngine *engine;
@property (nonatomic, strong) MPIOSViewController *rootViewController;
@property (nonatomic, strong) NSString *initialRoute;
@property (nonatomic, strong) NSDictionary *initialParams;

@end

@implementation MPIOSCardlet

+ (MPIOSCardlet *)createCardletWithEngine:(MPIOSEngine *)engine
                             initialRoute:(NSString *)initialRoute
                            initialParams:(NSDictionary *)initialParams {
    MPIOSCardlet *cardlet = [[MPIOSCardlet alloc] init];
    cardlet.engine = engine;
    cardlet.initialRoute = initialRoute;
    cardlet.initialParams = initialParams;
    return cardlet;
}

- (UIView *)createCardView:(CGRect)bounds {
    MPIOSViewController *viewController = [[MPIOSViewController alloc] init];
    viewController.isFirstPage = YES;
    viewController.engine = self.engine;
    viewController.initialViewBounds = bounds;
    viewController.initialRouteName = self.initialRoute;
    viewController.initialRouteParams = self.initialParams;
    self.rootViewController = viewController;
    return viewController.view;
}

- (void)attachToView:(UIView *)view {
    __weak MPIOSCardlet *welf = self;
    [self.engine.provider.navigatorProvider setOnRestart:^{
        MPIOSCardlet *self = welf;
        if (self == nil) {
            return;
        }
        UIView *cardView = [self createCardView:view.bounds];
        cardView.frame = view.bounds;
        [view addSubview:cardView];
    }];
    UIView *cardView = [self createCardView:view.bounds];
    cardView.frame = view.bounds;
    [view addSubview:cardView];
}

@end
