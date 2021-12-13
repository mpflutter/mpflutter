//
//  MPIOSAncestorView.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/10/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSComponentView;

@interface MPIOSAncestorView : NSObject

@property (nonatomic, readonly) NSDictionary *constraints;
@property (nonatomic, weak) MPIOSComponentView *target;

- (void)setConstraints:(NSDictionary *)constraints;
- (void)setAttributes:(NSDictionary *)attributes;

@end

NS_ASSUME_NONNULL_END
