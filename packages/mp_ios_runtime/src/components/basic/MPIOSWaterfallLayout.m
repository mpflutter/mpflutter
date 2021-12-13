//
//  MPIOSWaterfallLayout.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/15.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSWaterfallLayout.h"

@interface MPIOSWaterfallLayout ()

@property (nonatomic, assign) CGFloat maxVLength;
@property (nonatomic, strong) NSArray<NSValue *> *itemLayouts;

@end

@implementation MPIOSWaterfallLayout

- (void)prepareLayout {
    if (self.isPlain) {
        [self preparePlainLayout];
    }
    else {
        [self prepareWaterfallLayout];
    }
}

- (void)preparePlainLayout {
    CGFloat clientWidth = self.clientWidth > 0 ? self.clientWidth : floor(CGRectGetWidth(self.collectionView.frame));
    CGFloat clientHeight = self.clientHeight > 0 ? self.clientHeight : floor(CGRectGetHeight(self.collectionView.frame));
    NSMutableArray<NSValue *> *layouts = [NSMutableArray array];
    CGFloat paddingTop = self.padding.top;
    CGFloat paddingLeft = self.padding.left;
    __block CGFloat currentX = paddingLeft;
    __block CGFloat currentY = paddingTop;
    __block float maxVLength = 0.0;
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize itemSize = [self sizeForItem:obj];
        CGFloat itemWidth = itemSize.width;
        CGFloat itemHeight = itemSize.height;
        if (self.isHorizontalScroll) {
            CGRect rect = CGRectMake(currentX,
                                     currentY,
                                     itemWidth,
                                     itemHeight);
            currentY += itemHeight + self.crossAxisSpacing;
            if (currentY + itemHeight - clientHeight > 0.1 && idx + 1 < self.items.count) {
                currentY = paddingTop;
                currentX += itemWidth + self.mainAxisSpacing;
            }
            maxVLength = MAX(currentX + itemWidth, maxVLength);
            [layouts addObject:[NSValue valueWithCGRect:rect]];
        }
        else {
            CGRect rect = CGRectMake(currentX,
                                     currentY,
                                     itemWidth,
                                     itemHeight);
            currentX += itemWidth + self.crossAxisSpacing;
            if (currentX + itemWidth - clientWidth > 0.1 && idx + 1 < self.items.count) {
                currentX = paddingLeft;
                currentY += itemHeight + self.mainAxisSpacing;
            }
            maxVLength = MAX(currentY + itemHeight, maxVLength);
            [layouts addObject:[NSValue valueWithCGRect:rect]];
        }
    }];
    self.itemLayouts = layouts.copy;
    self.maxVLength = maxVLength;
}

- (void)prepareWaterfallLayout {
    if (self.crossAxisCount <= 0) {
        self.itemLayouts = nil;
        return;
    }
    CGFloat paddingTop = self.padding.top;
    CGFloat paddingLeft = self.padding.left;
    __block int currentRowIndex = 0;
    NSMutableDictionary<NSNumber *, NSValue *> *layoutCache = [NSMutableDictionary dictionary];
    NSMutableArray<NSValue *> *layouts = [NSMutableArray array];
    __block float maxVLength = 0.0;
    
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        CGSize itemSize = [self sizeForItem:obj];
        CGFloat itemWidth = itemSize.width;
        CGFloat itemHeight = itemSize.height;
        CGFloat currentVLength = self.isHorizontalScroll ? paddingLeft : paddingTop;
        {
            int index = currentRowIndex;
            int nextIndex = index + 1 >= self.crossAxisCount ? 0 : index + 1;
            if (layoutCache[@(index)] != nil && layoutCache[@(nextIndex)] != nil) {
                CGRect curRect = layoutCache[@(index)].CGRectValue;
                CGRect nextRect = layoutCache[@(nextIndex)].CGRectValue;
                if (self.isHorizontalScroll) {
                    if (nextRect.origin.x + nextRect.size.width < curRect.origin.x + curRect.size.width) {
                        currentRowIndex = nextIndex;
                    }
                    else {
                        currentRowIndex = index;
                    }
                }
                else {
                    if (nextRect.origin.y + nextRect.size.height < curRect.origin.y + curRect.size.height) {
                        currentRowIndex = nextIndex;
                    }
                    else {
                        currentRowIndex = index;
                    }
                }
            }
            else {
                currentRowIndex = index;
            }
        }
        
        if (layoutCache[@(currentRowIndex)] != nil) {
            CGRect curRect = layoutCache[@(currentRowIndex)].CGRectValue;
            if (self.isHorizontalScroll) {
                currentVLength = curRect.origin.x + curRect.size.width;
                if (idx >= self.crossAxisCount) {
                    currentVLength += self.mainAxisSpacing;
                }
            }
            else {
                currentVLength = curRect.origin.y + curRect.size.height;
                if (idx >= self.crossAxisCount) {
                    currentVLength += self.mainAxisSpacing;
                }
            }
        }
        else {
            currentVLength = self.isHorizontalScroll ? paddingLeft : paddingTop;
        }
        
        if (self.isHorizontalScroll) {
            CGRect rect = CGRectMake(currentVLength,
                                     paddingTop + itemHeight * currentRowIndex + currentRowIndex * self.crossAxisSpacing,
                                     itemWidth,
                                     itemHeight);
            layoutCache[@(currentRowIndex)] = [NSValue valueWithCGRect:rect];
            currentRowIndex = (currentRowIndex + 1) % self.crossAxisCount;
            maxVLength = MAX(currentVLength + itemWidth, maxVLength);
            [layouts addObject:[NSValue valueWithCGRect:rect]];
        }
        else {
            CGRect rect = CGRectMake(paddingLeft + itemWidth * currentRowIndex + currentRowIndex * self.crossAxisSpacing,
                                     currentVLength,
                                     itemWidth,
                                     itemHeight);
            layoutCache[@(currentRowIndex)] = [NSValue valueWithCGRect:rect];
            currentRowIndex = (currentRowIndex + 1) % self.crossAxisCount;
            maxVLength = MAX(currentVLength + itemHeight, maxVLength);
            [layouts addObject:[NSValue valueWithCGRect:rect]];
        }
    }];
    self.itemLayouts = layouts.copy;
    self.maxVLength = maxVLength;
}

- (CGSize)collectionViewContentSize {
    if (self.isHorizontalScroll) {
        return CGSizeMake(self.maxVLength + self.padding.right, CGRectGetHeight(self.collectionView.frame));
    }
    else {
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), self.maxVLength + self.padding.bottom);
    }
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *targetItems = [NSMutableArray array];
    [self.itemLayouts enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect targetRect = obj.CGRectValue;
        if (CGRectIntersectsRect(rect, targetRect)) {
            UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes
                                                       layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            [attrs setFrame:targetRect];
            [targetItems addObject:attrs];
        }
    }];
    return targetItems.copy;
}
     
- (CGSize)sizeForItem:(NSDictionary *)data {
    if ([data isKindOfClass:[NSDictionary class]] &&
        [data[@"name"] isKindOfClass:[NSString class]] &&
        [data[@"name"] isEqualToString:@"sliver_waterfall_item"]) {
        NSNumber *width = @(0);
        NSNumber *height = @(0);
        if ([data[@"children"] isKindOfClass:[NSArray class]] &&
            [data[@"children"] count] > 0 &&
            [data[@"children"][0] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *firstChild = data[@"children"][0];
            if ([firstChild[@"constraints"] isKindOfClass:[NSDictionary class]] &&
                [firstChild[@"constraints"][@"w"] isKindOfClass:[NSNumber class]]) {
                width = firstChild[@"constraints"][@"w"];
            }
        }
        if ([data[@"attributes"] isKindOfClass:[NSDictionary class]] &&
            [data[@"attributes"][@"height"] isKindOfClass:[NSNumber class]]) {
            height = data[@"attributes"][@"height"];
        }
        return CGSizeMake(width.floatValue, height.floatValue);
    }
    else if ([data isKindOfClass:[NSDictionary class]] &&
        [data[@"constraints"] isKindOfClass:[NSDictionary class]] &&
        [data[@"constraints"][@"w"] isKindOfClass:[NSNumber class]] &&
        [data[@"constraints"][@"h"] isKindOfClass:[NSNumber class]]) {
        return CGSizeMake([data[@"constraints"][@"w"] floatValue],
                          [data[@"constraints"][@"h"] floatValue]);
    }
    return CGSizeZero;
}

@end
