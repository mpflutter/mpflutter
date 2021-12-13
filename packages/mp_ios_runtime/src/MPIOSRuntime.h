//
//  MPIOSRuntime.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPIOSEngine.h"
#import "MPIOSPage.h"
#import "MPIOSApp.h"
#import "MPIOSViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MPIOSImageLoader)(UIImageView *, NSString *);

@interface MPIOSRuntime : NSObject

+ (void)setupImageLoader:(MPIOSImageLoader)imageLoader;

@end

NS_ASSUME_NONNULL_END
