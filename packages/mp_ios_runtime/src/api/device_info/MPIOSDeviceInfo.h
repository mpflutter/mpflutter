//
//  MPIOSDeviceInfo.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSDeviceInfo : NSObject

+ (void)setupWithJSContext:(JSContext *)context size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
