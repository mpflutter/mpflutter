//
//  MPIOSApp.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/7/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSApp : NSObject

@property (nonatomic, readonly) UINavigationController *navigationController;

- (instancetype)initWithEngine:(MPIOSEngine *)engine
          navigationController:(UINavigationController *)navigationController;

- (void)setViewControllerClass:(Class)viewControllerClass;

- (UIViewController *)createRootViewControllerWithInitialRoute:(NSString *)initialRoute initialParams:(NSDictionary *)initialParams;
- (UIViewController *)createPushingViewController;

@end

NS_ASSUME_NONNULL_END
