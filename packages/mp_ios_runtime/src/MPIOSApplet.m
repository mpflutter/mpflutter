//
//  MPIOSApplet.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/2/14.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSApplet.h"
#import "MPIOSViewController.h"
#import "MPIOSProvider.h"

@interface MPIOSApplet ()

@property (nonatomic, strong) MPIOSEngine *engine;
@property (nonatomic, strong) NSString *initialRoute;
@property (nonatomic, strong) NSDictionary *initialParams;

@end

@implementation MPIOSApplet

+ (MPIOSApplet *)createAppletWithEngine:(MPIOSEngine *)engine
                           initialRoute:(NSString *)initialRoute
                          initialParams:(NSDictionary *)initialParams {
    MPIOSApplet *applet = [[MPIOSApplet alloc] init];
    applet.engine = engine;
    applet.initialRoute = initialRoute;
    applet.initialParams = initialParams;
    return applet;
}

- (UIViewController *)createFirstViewController {
    MPIOSViewController *viewController = [[MPIOSViewController alloc] init];
    viewController.isFirstPage = YES;
    viewController.engine = self.engine;
    viewController.initialRouteName = self.initialRoute;
    viewController.initialRouteParams = self.initialParams;
    return viewController;
}

- (void)attachToNavigationController:(UINavigationController *)navigationController
                asRootViewController:(BOOL)asRootViewController {
    self.engine.provider.navigatorProvider.navigationController = navigationController;
    if (asRootViewController) {
        [navigationController setViewControllers:@[[self createFirstViewController]]];
    }
    else {
        [navigationController pushViewController:[self createFirstViewController] animated:YES];
    }
}

@end
