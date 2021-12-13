//
//  MPIOSCustomScrollViewLayout.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/15.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSCustomScrollViewLayout.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSWaterfallLayout.h"

@interface MPIOSCustomScrollViewLayout ()

@property (nonatomic, assign) CGFloat maxVLength;
@property (nonatomic, strong) NSArray<NSValue *> *itemLayouts;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *persistentHeaders;

@end

@implementation MPIOSCustomScrollViewLayout

- (void)prepareLayout {
    CGFloat viewWidth = floor(CGRectGetWidth(self.collectionView.frame));
    CGFloat viewHeight = floor(CGRectGetHeight(self.collectionView.frame));
    if (viewWidth <= 0.01 || viewHeight <= 0.01) {
        return;
    }
    NSMutableArray *layouts = [NSMutableArray array];
    NSMutableDictionary<NSNumber *, NSNumber *> *persistentHeaders = [NSMutableDictionary dictionary];
    __block CGFloat currentVLength = 0.0;
    __block MPIOSWaterfallLayout *currentWaterfallLayout;
    __block NSInteger currentWaterfallItemPos = 0;
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([data isKindOfClass:[NSDictionary class]] &&
            [data[@"name"] isKindOfClass:[NSString class]] &&
            [data[@"name"] isEqualToString:@"sliver_persistent_header"]) {
            persistentHeaders[@(idx)] = @(1);
        }
        if ([data isKindOfClass:[NSDictionary class]] &&
            [data[@"name"] isKindOfClass:[NSString class]] &&
            [data[@"name"] isEqualToString:@"sliver_grid"]) {
            currentWaterfallLayout = [[MPIOSWaterfallLayout alloc] init];
            if ([data[@"attributes"] isKindOfClass:[NSDictionary class]] &&
                [data[@"attributes"][@"padding"] isKindOfClass:[NSString class]]) {
                currentWaterfallLayout.padding = [MPIOSComponentUtils
                                                  edgeInsetsFromString:data[@"attributes"][@"padding"]];
            }
            currentWaterfallLayout.isHorizontalScroll = self.isHorizontalScroll;
            NSMutableArray *waterfallItems = [NSMutableArray array];
            for (NSInteger i = idx + 1; i < self.items.count; i++) {
                if ([self.items[i] isKindOfClass:[NSString class]] &&
                    [self.items[i] isEqualToString:@"sliver_grid_end"]) {
                    break;
                }
                [waterfallItems addObject:self.items[i]];
            }
            [currentWaterfallLayout setClientWidth:floor(CGRectGetWidth(self.collectionView.frame))];
            [currentWaterfallLayout setClientHeight:floor(CGRectGetHeight(self.collectionView.frame))];
            if ([data[@"attributes"] isKindOfClass:[NSDictionary class]]) {
                if ([data[@"attributes"][@"gridDelegate"] isKindOfClass:[NSDictionary class]]) {
                    if ([data[@"attributes"][@"gridDelegate"][@"classname"] isKindOfClass:[NSString class]]) {
                        [currentWaterfallLayout setIsPlain:![data[@"attributes"][@"gridDelegate"][@"classname"] isEqualToString:@"SliverWaterfallDelegate"]];
                    }
                    if ([data[@"attributes"][@"gridDelegate"][@"crossAxisCount"] isKindOfClass:[NSNumber class]]) {
                        [currentWaterfallLayout setCrossAxisCount:[data[@"attributes"][@"gridDelegate"][@"crossAxisCount"] integerValue]];
                    }
                    if ([data[@"attributes"][@"gridDelegate"][@"mainAxisSpacing"] isKindOfClass:[NSNumber class]]) {
                        [currentWaterfallLayout setMainAxisSpacing:[data[@"attributes"][@"gridDelegate"][@"mainAxisSpacing"] floatValue]];
                    }
                    if ([data[@"attributes"][@"gridDelegate"][@"crossAxisSpacing"] isKindOfClass:[NSNumber class]]) {
                        [currentWaterfallLayout setCrossAxisSpacing:[data[@"attributes"][@"gridDelegate"][@"crossAxisSpacing"] floatValue]];
                    }
                }
                else {
                    [currentWaterfallLayout setIsPlain:YES];
                }
            }
            [currentWaterfallLayout setItems:waterfallItems.copy];
            [currentWaterfallLayout prepareLayout];
            currentWaterfallItemPos = 0;
            [layouts addObject:[NSValue valueWithCGRect:CGRectZero]];
            return;
        }
        if ([data isKindOfClass:[NSString class]] &&
            [data isEqualToString:@"sliver_grid_end"]) {
            CGRect lastFrame = [currentWaterfallLayout.itemLayouts.lastObject CGRectValue];
            if (self.isHorizontalScroll) {
                currentVLength += lastFrame.origin.x + lastFrame.size.width + currentWaterfallLayout.padding.right;
            }
            else {
                currentVLength += lastFrame.origin.y + lastFrame.size.height + currentWaterfallLayout.padding.bottom;
            }
            self.maxVLength = currentVLength;
            currentWaterfallLayout = nil;
            [layouts addObject:[NSValue valueWithCGRect:CGRectZero]];
            return;
        }
        if (currentWaterfallLayout != nil) {
            if (currentWaterfallItemPos < currentWaterfallLayout.itemLayouts.count) {
                CGRect absFrame = [currentWaterfallLayout.itemLayouts[currentWaterfallItemPos] CGRectValue];
                if (self.isHorizontalScroll) {
                    absFrame.origin.x += currentVLength;
                }
                else {
                    absFrame.origin.y += currentVLength;
                }
                [layouts addObject:[NSValue valueWithCGRect:absFrame]];
            }
            else {
                [layouts addObject:[NSValue valueWithCGRect:CGRectZero]];
            }
            currentWaterfallItemPos++;
            return;
        }
        CGSize elementSize = [MPIOSComponentUtils sizeFromMPElement:data];
        UIEdgeInsets elementPadding = [MPIOSComponentUtils sliverPaddingFromMPElement:data];
        CGRect itemFrame;
        if (self.isHorizontalScroll) {
            itemFrame = CGRectMake(currentVLength + elementPadding.left, elementPadding.top, elementSize.width, viewHeight);
            currentVLength += elementSize.width + elementPadding.left + elementPadding.right;
        }
        else {
            itemFrame = CGRectMake(elementPadding.left, currentVLength + elementPadding.top, viewWidth, elementSize.height);
            currentVLength += elementSize.height + elementPadding.top + elementPadding.bottom;
        }
        self.maxVLength = currentVLength;
        [layouts addObject:[NSValue valueWithCGRect:itemFrame]];
    }];
    self.itemLayouts = layouts.copy;
    self.persistentHeaders = persistentHeaders.copy;
}

- (CGSize)collectionViewContentSize {
    if (self.isHorizontalScroll) {
        CGFloat viewHeight = CGRectGetHeight(self.collectionView.frame);
        return CGSizeMake(self.maxVLength, viewHeight);
    }
    else {
        CGFloat viewWidth = CGRectGetWidth(self.collectionView.frame);
        return CGSizeMake(viewWidth, self.maxVLength);
    }
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *targetItems = [NSMutableArray array];
    [self.itemLayouts enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect targetRect = obj.CGRectValue;
        if (self.persistentHeaders[@(idx)] != nil) {
            CGRect nextTargetRect = self.persistentHeaders[@(idx + 1)] != nil ? [self.persistentHeaders[@(idx + 1)] CGRectValue] : CGRectZero;
            if (self.isHorizontalScroll) {
                if (!CGRectIsEmpty(nextTargetRect) && nextTargetRect.origin.x < self.collectionView.contentOffset.x) {
                    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                               layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [attrs setFrame:targetRect];
                    [attrs setZIndex:9999 + idx];
                    [targetItems addObject:attrs];
                }
                else if (targetRect.origin.x < self.collectionView.contentOffset.x) {
                    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                               layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    targetRect.origin.x = self.collectionView.contentOffset.x;
                    [attrs setFrame:targetRect];
                    [attrs setZIndex:9999 + idx];
                    [targetItems addObject:attrs];
                }
                else if (CGRectIntersectsRect(rect, targetRect)) {
                    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                               layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [attrs setFrame:targetRect];
                    [attrs setZIndex:9999 + idx];
                    [targetItems addObject:attrs];
                }
            }
            else {
                if (!CGRectIsEmpty(nextTargetRect) && nextTargetRect.origin.y < self.collectionView.contentOffset.y) {
                    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                               layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [attrs setFrame:targetRect];
                    [attrs setZIndex:9999 + idx];
                    [targetItems addObject:attrs];
                }
                else if (targetRect.origin.y < self.collectionView.contentOffset.y) {
                    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                               layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    targetRect.origin.y = self.collectionView.contentOffset.y;
                    [attrs setFrame:targetRect];
                    [attrs setZIndex:9999 + idx];
                    [targetItems addObject:attrs];
                }
                else if (CGRectIntersectsRect(rect, targetRect)) {
                    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                               layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [attrs setFrame:targetRect];
                    [attrs setZIndex:9999 + idx];
                    [targetItems addObject:attrs];
                }
            }
        }
        else if (CGRectIntersectsRect(rect, targetRect)) {
            UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                       layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            [attrs setFrame:targetRect];
            [targetItems addObject:attrs];
        }
    }];
    return targetItems.copy;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return self.persistentHeaders.count > 0;
}

@end
