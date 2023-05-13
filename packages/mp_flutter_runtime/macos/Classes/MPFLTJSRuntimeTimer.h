//
//  MPFLTJSRuntimeTimer.h
//  mp_flutter_runtime
//
//  Created by PonyCui on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPFLTJSRuntimeTimer : NSObject

+ (void)setupWithJSContext:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
