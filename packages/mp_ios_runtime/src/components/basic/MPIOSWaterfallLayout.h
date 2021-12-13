//
//  MPIOSWaterfallLayout.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/15.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSWaterfallLayout : UICollectionViewLayout

@property (nonatomic, assign) BOOL isPlain;
@property (nonatomic, assign) BOOL isHorizontalScroll;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, assign) NSInteger clientWidth;
@property (nonatomic, assign) NSInteger clientHeight;
@property (nonatomic, assign) NSInteger crossAxisCount;
@property (nonatomic, assign) CGFloat crossAxisSpacing;
@property (nonatomic, assign) CGFloat mainAxisSpacing;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, readonly) NSArray<NSValue *> *itemLayouts;

@end

NS_ASSUME_NONNULL_END
