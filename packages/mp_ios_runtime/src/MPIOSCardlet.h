//
//  MPIOSCardlet.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/2/14.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSCardlet : NSObject

+ (MPIOSCardlet *)createCardletWithEngine:(MPIOSEngine *)engine
                             initialRoute:(NSString *)initialRoute
                            initialParams:(NSDictionary *)initialParams;

- (UIView *)createCardView:(CGRect)bounds;

- (void)attachToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
