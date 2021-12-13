//
//  MPIOSCustomScrollViewLayout.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/15.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSCustomScrollViewLayout : UICollectionViewLayout

@property (nonatomic, assign) BOOL isHorizontalScroll;
@property (nonatomic, strong) NSArray *items;

@end

NS_ASSUME_NONNULL_END
