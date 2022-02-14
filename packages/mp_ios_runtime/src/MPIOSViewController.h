//
//  MPIOSViewController.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/18.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSEngine.h"
#import "MPIOSPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSViewController : UIViewController

@property (nonatomic, assign) BOOL isFirstPage;
@property (nonatomic, strong) MPIOSEngine *engine;
@property (nonatomic, assign) CGRect initialViewBounds;
@property (nonatomic, copy) NSString *initialRouteName;
@property (nonatomic, copy) NSDictionary *initialRouteParams;

- (void)onReachBottom;
- (void)onPageScroll:(double)scrollTop;

@end

NS_ASSUME_NONNULL_END
