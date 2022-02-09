//
//  MPIOSListView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/10.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSListView.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSListView ()<UITableViewDelegate, UITableViewDataSource, MPIOSComponentViewDelegate>

@property (nonatomic, assign) BOOL cellCreating;
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, assign) BOOL isHorizontalScroll;
@property (nonatomic, assign) UIEdgeInsets contentViewInsets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableView *contentView;
@property (nonatomic, strong) NSArray *listChildren;

@end

@implementation MPIOSListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentView = [[UITableView alloc] init];
        _contentView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.contentViewInsets.left > 0 && point.x < self.contentViewInsets.left) {
        return self.contentView;
    }
    else if (self.contentViewInsets.top > 0 && point.y < self.contentViewInsets.top) {
        return self.contentView;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
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
            [(NSArray *)obj[@"children"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                [listChilren addObject:obj];
            }];
        }
        else if ([obj[@"name"] isKindOfClass:[NSString class]] &&
            [obj[@"name"] isEqualToString:@"sliver_grid"] &&
            [obj[@"children"] isKindOfClass:[NSArray class]]) {
            
        }
        else {
            [listChilren addObject:obj];
        }
        [self.factory create:obj];
        
    }];
    self.listChildren = listChilren;
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
    NSString *padding = attributes[@"padding"];
    if ([padding isKindOfClass:[NSString class]]) {
        self.contentViewInsets = [MPIOSComponentUtils edgeInsetsFromString:padding];
    }
    else {
        self.contentViewInsets = UIEdgeInsetsZero;
    }
    self.isRoot = [attributes[@"isRoot"] isKindOfClass:[NSNumber class]] ? [attributes[@"isRoot"] boolValue] : NO;
    if ([attributes[@"onRefresh"] isKindOfClass:[NSNumber class]]) {
        [self.contentView addSubview:self.refreshControl];
    }
    else {
        [self.refreshControl removeFromSuperview];
    }
}

- (void)setIsHorizontalScroll:(BOOL)isHorizontalScroll {
    if (_isHorizontalScroll == isHorizontalScroll) {
        return;
    }
    _isHorizontalScroll = isHorizontalScroll;
    [self layoutSubviews];
    [self.contentView reloadData];
}

- (void)setContentViewInsets:(UIEdgeInsets)contentViewInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, contentViewInsets)) {
        return;
    }
    _contentViewInsets = contentViewInsets;
    [self layoutSubviews];
    [self.contentView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isHorizontalScroll) {
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.frame = self.bounds;
        self.contentView.contentInset = UIEdgeInsetsMake(self.contentViewInsets.top,
                                                         0,
                                                         self.contentViewInsets.bottom,
                                                         0);
        self.contentView.transform = CGAffineTransformMakeTranslation(self.contentViewInsets.left, 0);
    }
    else {
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.frame = CGRectMake(
                                            (self.bounds.size.width - self.bounds.size.height) / 2.0,
                                            (self.bounds.size.height - self.bounds.size.width) / 2.0,
                                            self.bounds.size.height,
                                            self.bounds.size.width);
        self.contentView.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, self.contentViewInsets.top), -90.0 * M_PI / 180.0);
        self.contentView.showsVerticalScrollIndicator = NO;
        self.contentView.showsHorizontalScrollIndicator = NO;
        self.contentView.contentInset = UIEdgeInsetsMake(self.contentViewInsets.left,
                                                         0,
                                                         self.contentViewInsets.right,
                                                         0);
    }
}

#pragma mark - UITableViewDataSource

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listChildren == nil) {
        return 0;
    }
    return self.listChildren.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    self.cellCreating = YES;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
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
        if (!self.isHorizontalScroll) {
            cell.contentView.transform = CGAffineTransformIdentity;
        }
        else {
            cell.contentView.transform = CGAffineTransformIdentity;
            cell.contentView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 90.0 * M_PI / 180.0);
        }
    }
    self.cellCreating = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listChildren == nil) {
        return 0;
    }
    if (indexPath.row < self.listChildren.count) {
        NSDictionary *data = self.listChildren[indexPath.row];
        if (!self.isHorizontalScroll) {
            if ([data isKindOfClass:[NSDictionary class]] &&
                [data[@"constraints"] isKindOfClass:[NSDictionary class]] &&
                [data[@"constraints"][@"h"] isKindOfClass:[NSNumber class]]) {
                return [data[@"constraints"][@"h"] floatValue];
            }
        }
        else {
            if ([data isKindOfClass:[NSDictionary class]] &&
                [data[@"constraints"] isKindOfClass:[NSDictionary class]] &&
                [data[@"constraints"][@"w"] isKindOfClass:[NSNumber class]]) {
                return [data[@"constraints"][@"w"] floatValue];
            }
        }
    }
    return 44;
}

#pragma mark - MPIOSComponentViewDelegate

- (void)componentViewConstraintDidChanged:(MPIOSComponentView *)view {
    if (self.cellCreating) {
        return;
    }
    [self.contentView reloadData];
}

@end
