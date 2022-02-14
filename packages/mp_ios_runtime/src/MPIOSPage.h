//
//  MPIOSPage.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/7/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSPage : NSObject

@property (nonatomic, assign) BOOL isFirstPage;
@property (nonatomic, readonly) NSNumber *viewId;

- (instancetype)initWithRootView:(UIView *)rootView
                          engine:(MPIOSEngine *)engine
                     isFirstPage:(BOOL)isFirstPage
                    initialRoute:(NSString *)initialRoute
                   initialParams:(NSDictionary *)initialParams;

- (void)onReachBottom;
- (void)onPageScroll:(double)scrollTop;

@end

NS_ASSUME_NONNULL_END
