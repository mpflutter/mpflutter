//
//  MPIOSConsole.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPIOSConsoleExport <JSExport>

+ (void)log;
+ (void)error;
+ (void)info;
+ (void)warn;
+ (void)debug;

@end

@interface MPIOSConsole : NSObject<MPIOSConsoleExport>

+ (void)setupWithJSContext:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
