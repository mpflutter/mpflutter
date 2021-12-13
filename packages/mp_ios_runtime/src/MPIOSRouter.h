//
//  MPIOSRoute.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MPIOSRouteResponseBlock)(NSNumber *);

@interface MPIOSRouter : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;

- (void)requestRoute:(NSString *)routeName
         routeParams:(NSDictionary *)routeParams
              isRoot:(BOOL)isRoot
            viewport:(CGSize)viewport
     completionBlock:(MPIOSRouteResponseBlock)completionBlock;

- (void)updateRouteViewport:(NSNumber *)routeId viewport:(CGSize)viewport;

- (void)didReceivedRouteData:(NSDictionary *)message;
- (void)dispose:(NSNumber *)viewId;
- (void)triggerPop:(NSNumber *)viewId;

@end

NS_ASSUME_NONNULL_END
