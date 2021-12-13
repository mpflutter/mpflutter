//
//  MPIOSComponentView.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSComponentFactory.h"
#import "MPIOSEngine.h"
#import "MPIOSEngine+Private.h"

NS_ASSUME_NONNULL_BEGIN

@class MPIOSAncestorView, MPIOSViewController;

@protocol MPIOSComponentViewDelegate <NSObject>

@optional
- (void)componentViewConstraintDidChanged:(MPIOSComponentView *)view;

@end

@interface MPIOSComponentView : UIView

@property (nonatomic, readonly) NSDictionary *constraints;
@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, weak) id<MPIOSComponentViewDelegate> delegate;
@property (nonatomic, weak) MPIOSComponentFactory *factory;
@property (nonatomic, weak) MPIOSEngine *engine;
@property (nonatomic, strong) NSNumber *hashCode;
@property (nonatomic, readonly) NSMutableArray<MPIOSAncestorView *> *ownAncestors;
@property (nonatomic, assign) CGPoint gestureViewConstraints;
@property (nonatomic, assign) CGPoint platformViewConstraints;
@property (nonatomic, assign) CGPoint borderOffsetConstraints;

- (void)setConstraints:(NSDictionary *)constraints;
- (void)updateLayout;
- (void)setAncestors:(NSArray *)ancestors;
- (void)setAttributes:(NSDictionary *)attributes;
- (void)setChildren:(NSArray *)children;
- (MPIOSViewController *)getViewController;

@end

NS_ASSUME_NONNULL_END
