//
//  MPIOSWXCompat.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSWXCompat : NSObject

+ (void)setupWithJSContext:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
