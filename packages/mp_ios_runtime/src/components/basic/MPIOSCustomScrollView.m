//
//  MPIOSCustomScrollView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/15.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSCustomScrollView.h"
#import "MPIOSCustomScrollViewLayout.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSCustomScrollView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MPIOSComponentViewDelegate>

@property (nonatomic, assign) BOOL cellCreating;
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, assign) BOOL isHorizontalScroll;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, strong) MPIOSCustomScrollViewLayout *contentViewLayout;
@property (nonatomic, assign) UIEdgeInsets contentViewInsets;
@property (nonatomic, strong) NSArray *listChildren;

@end

@implementation MPIOSCustomScrollView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentViewLayout = [[MPIOSCustomScrollViewLayout alloc] init];
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_contentViewLayout];
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
        if ([obj[@"name"] isKindOfClass:[NSString class]] &&
            [obj[@"name"] isEqualToString:@"sliver_list"] &&
            [obj[@"children"] isKindOfClass:[NSArray class]]) {
            [listChilren addObject:@{
                @"name": @"sliver_grid",
                @"attributes": obj[@"attributes"],
            }];
            [(NSArray *)obj[@"children"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                [listChilren addObject:obj];
            }];
            [listChilren addObject:@"sliver_grid_end"];
        }
        else if ([obj[@"name"] isKindOfClass:[NSString class]] &&
            [obj[@"name"] isEqualToString:@"sliver_grid"] &&
            [obj[@"children"] isKindOfClass:[NSArray class]]) {
            [listChilren addObject:@{
                @"name": @"sliver_grid",
                @"attributes": obj[@"attributes"],
            }];
            [(NSArray *)obj[@"children"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                [listChilren addObject:obj];
            }];
            [listChilren addObject:@"sliver_grid_end"];
        }
        else {
            [listChilren addObject:obj];
        }
        [self.factory create:obj];
    }];
    self.listChildren = listChilren;
    [self.contentViewLayout setItems:self.listChildren];
    [self.contentViewLayout prepareLayout];
    [self.contentView reloadData];
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *scrollDirection = attributes[@"scrollDirection"];
    if ([scrollDirection isKindOfClass:[NSString class]] &&
        [scrollDirection isEqualToString:@"Axis.horizontal"]) {
        self.isHorizontalScroll = YES;
    }
    else {
        self.isHorizontalScroll = NO;
    }
    self.isRoot = [attributes[@"isRoot"] isKindOfClass:[NSNumber class]] ? [attributes[@"isRoot"] boolValue] : NO;
    if ([attributes[@"onRefresh"] isKindOfClass:[NSNumber class]]) {
        [self.contentView addSubview:self.refreshControl];
    }
    else {
        [self.refreshControl removeFromSuperview];
    }
}

- (void)setContentViewInsets:(UIEdgeInsets)contentViewInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, contentViewInsets)) {
        return;
    }
    _contentViewInsets = contentViewInsets;
    [self layoutSubviews];
    [self.contentView reloadData];
}

- (void)setIsHorizontalScroll:(BOOL)isHorizontalScroll {
    if (_isHorizontalScroll == isHorizontalScroll) {
        return;
    }
    _isHorizontalScroll = isHorizontalScroll;
    self.contentViewLayout.isHorizontalScroll = isHorizontalScroll;
    [self.contentViewLayout prepareLayout];
    [self.contentView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.transform = CGAffineTransformIdentity;
    self.contentView.frame = self.bounds;
    self.contentView.contentInset = UIEdgeInsetsMake(self.contentViewInsets.top,
                                                     self.contentViewInsets.left,
                                                     self.contentViewInsets.bottom,
                                                     self.contentViewInsets.right);
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

@end
