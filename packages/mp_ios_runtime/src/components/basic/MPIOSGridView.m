//
//  MPIOSGridView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/11.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSGridView.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSWaterfallLayout.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSGridView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MPIOSComponentViewDelegate>

@property (nonatomic, assign) BOOL cellCreating;
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, strong) MPIOSWaterfallLayout *contentViewFlowLayout;
@property (nonatomic, assign) CGFloat crossAxisSpacing;
@property (nonatomic, assign) CGFloat mainAxisSpacing;
@property (nonatomic, strong) NSArray *listChildren;

@end

@implementation MPIOSGridView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentViewFlowLayout = [[MPIOSWaterfallLayout alloc] init];
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_contentViewFlowLayout];
        _contentView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_contentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.dataSource = self;
        _contentView.delegate = self;
        _contentView.allowsSelection = NO;
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)onRefresh {
    __strong MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"scroll_view",
            @"message": @{
                    @"event": @"onRefresh",
                    @"target": self.hashCode ?: [NSNull null],
                    @"isRoot": self.attributes[@"isRoot"] ?: @(NO),
            },
        }];
    }
}

- (void)endRefresh {
    [self.refreshControl endRefreshing];
}

- (void)setChildren:(NSArray *)children {
    NSMutableArray *listChilren = [NSMutableArray array];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        [listChilren addObject:obj];
        [self.factory create:obj];
    }];
    self.listChildren = listChilren;
    if ([self.contentViewFlowLayout isKindOfClass:[MPIOSWaterfallLayout class]]) {
        [(MPIOSWaterfallLayout *)self.contentViewFlowLayout setItems:self.listChildren];
    }
    [self.contentViewFlowLayout prepareLayout];
    [self.contentView reloadData];
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *scrollDirection = attributes[@"scrollDirection"];
    if ([self.contentViewFlowLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        UICollectionViewFlowLayout *flowLayout = (id)self.contentViewFlowLayout;
        if ([scrollDirection isKindOfClass:[NSString class]] &&
            [scrollDirection isEqualToString:@"Axis.horizontal"]) {
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        }
        else {
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        }
    }
    NSString *padding = attributes[@"padding"];
    if ([padding isKindOfClass:[NSString class]]) {
        self.padding = [MPIOSComponentUtils edgeInsetsFromString:padding];
    }
    else {
        self.padding = UIEdgeInsetsZero;
    }
    NSDictionary *gridDelegate = attributes[@"gridDelegate"];
    if ([gridDelegate isKindOfClass:[NSDictionary class]]) {
        if ([gridDelegate[@"mainAxisSpacing"] isKindOfClass:[NSNumber class]]) {
            self.mainAxisSpacing = [gridDelegate[@"mainAxisSpacing"] floatValue];
        }
        else {
            self.mainAxisSpacing = 0;
        }
        if ([gridDelegate[@"crossAxisSpacing"] isKindOfClass:[NSNumber class]]) {
            self.crossAxisSpacing = [gridDelegate[@"crossAxisSpacing"] floatValue];
        }
        else {
            self.crossAxisSpacing = 0;
        }
        if ([gridDelegate[@"classname"] isKindOfClass:[NSString class]]) {
            [self.contentViewFlowLayout setPadding:self.padding];
            [self.contentViewFlowLayout setCrossAxisSpacing:self.crossAxisSpacing];
            [self.contentViewFlowLayout setMainAxisSpacing:self.mainAxisSpacing];
            if ([gridDelegate[@"classname"] isEqualToString:@"SliverWaterfallDelegate"]) {
                if ([gridDelegate[@"crossAxisCount"] isKindOfClass:[NSNumber class]]) {
                    [self.contentViewFlowLayout setCrossAxisCount:[gridDelegate[@"crossAxisCount"] integerValue]];
                }
            }
            else {
                self.contentViewFlowLayout.isPlain = YES;
            }
        }
    }
    self.isRoot = [attributes[@"isRoot"] isKindOfClass:[NSNumber class]] ? [attributes[@"isRoot"] boolValue] : NO;
    if ([attributes[@"onRefresh"] isKindOfClass:[NSNumber class]]) {
        [self.contentView addSubview:self.refreshControl];
    }
    else {
        [self.refreshControl removeFromSuperview];
    }
}

- (void)setMainAxisSpacing:(CGFloat)mainAxisSpacing {
    if (_mainAxisSpacing == mainAxisSpacing) {
        return;
    }
    _mainAxisSpacing = mainAxisSpacing;
    [self.contentView reloadData];
}

- (void)setCrossAxisSpacing:(CGFloat)crossAxisSpacing {
    if (_crossAxisSpacing == crossAxisSpacing) {
        return;
    }
    _crossAxisSpacing = crossAxisSpacing;
    [self.contentView reloadData];
}

- (void)setPadding:(UIEdgeInsets)padding {
    if (UIEdgeInsetsEqualToEdgeInsets(_padding, padding)) {
        return;
    }
    _padding = padding;
    [self layoutSubviews];
    [self.contentView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.transform = CGAffineTransformIdentity;
    self.contentView.frame = self.bounds;
}

#pragma mark - UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isRoot) {
        MPIOSViewController *viewController = [self getViewController];
        if (viewController == nil) {
            return;
        }
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - 1) {
            [viewController onReachBottom];
        }
        [viewController onPageScroll:scrollView.contentOffset.y];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.listChildren == nil) {
        return 0;
    }
    return self.listChildren.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    self.cellCreating = YES;
    if (indexPath.row < self.listChildren.count) {
        NSDictionary *data = self.listChildren[indexPath.row];
        MPIOSComponentView *cellContentView = [self.factory create:data];
        cellContentView.frame = cell.contentView.bounds;
        cellContentView.delegate = self;
        if (cell.contentView.subviews.count == 1 &&
            cell.contentView.subviews[0] == cellContentView) {
        }
        else {
            [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
            if (cellContentView != nil) {
                [cell.contentView addSubview:cellContentView];
            }
        }
    }
    self.cellCreating = NO;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listChildren == nil) {
        return CGSizeMake(0, 0);
    }
    if (indexPath.row < self.listChildren.count) {
        NSDictionary *data = self.listChildren[indexPath.row];
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
    }
    return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.crossAxisSpacing - 0.5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.mainAxisSpacing - 0.5;
}

#pragma mark - MPIOSComponentViewDelegate

- (void)componentViewConstraintDidChanged:(MPIOSComponentView *)view {
    if (self.cellCreating) {
        return;
    }
    [self.contentViewFlowLayout prepareLayout];
    [self.contentView reloadData];
}

@end
