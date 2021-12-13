//
//  MPIOSMPScaffold.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSMPScaffold : MPIOSComponentView

- (void)onReachBottom;
- (void)onPageScroll:(double)scrollTop;

@end

NS_ASSUME_NONNULL_END
