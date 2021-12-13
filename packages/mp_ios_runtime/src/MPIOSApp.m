//
//  MPIOSApp.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/7/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSApp.h"
#import "MPIOSViewController.h"

@interface MPIOSApp ()

@property (nonatomic, weak) MPIOSEngine *engine;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, assign) Class viewControllerClass;

@end

@implementation MPIOSApp

- (instancetype)initWithEngine:(MPIOSEngine *)engine
          navigationController:(nonnull UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        _engine = engine;
        _engine.app = self;
        _navigationController = navigationController;
    }
    return self;
}

- (void)setViewControllerClass:(Class)viewControllerClass {
    if (![viewControllerClass isSubclassOfClass:[MPIOSViewController class]]) {
        return;
    }
    self.viewControllerClass = viewControllerClass;
}

- (UIViewController *)createRootViewControllerWithInitialRoute:(NSString *)initialRoute
                                                 initialParams:(NSDictionary *)initialParams {
    return [self createViewControllerWithName:initialRoute params:initialParams];
}

- (UIViewController *)createPushingViewController {
    return [self createViewControllerWithName:nil params:nil];
}

- (UIViewController *)createViewControllerWithName:(NSString *)routeName params:(NSDictionary *)params {
    Class clazz = self.viewControllerClass ?: [MPIOSViewController class];
    MPIOSViewController *nextViewController = [clazz new];
    nextViewController.engine = self.engine;
    nextViewController.initialRouteName = routeName;
    nextViewController.initialRouteParams = params;
    return nextViewController;
}

@end
