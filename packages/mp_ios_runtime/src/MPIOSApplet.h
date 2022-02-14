//
//  MPIOSApplet.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/2/14.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSApplet : NSObject

+ (MPIOSApplet *)createAppletWithEngine:(MPIOSEngine *)engine
                           initialRoute:(NSString *)initialRoute
                          initialParams:(NSDictionary *)initialParams;

- (UIViewController *)createFirstViewController;

- (void)attachToNavigationController:(UINavigationController *)navigationController
                asRootViewController:(BOOL)asRootViewController;

@end

NS_ASSUME_NONNULL_END
