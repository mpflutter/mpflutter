//
//  MPIOSMPPageView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPPageView.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSMPPageView ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL isHorizontal;
@property (nonatomic, assign) BOOL isLoop;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) BOOL initialPageSetted;
@property (nonatomic, strong) NSArray<UIViewController *> *childrenViewController;

@end

@implementation MPIOSMPPageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetPageViewController];
    }
    return self;
}

- (void)resetPageViewController {
    [self.contentView removeFromSuperview];
    self.pageViewController = [[UIPageViewController alloc]
                           initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:self.isHorizontal ?
                               UIPageViewControllerNavigationOrientationHorizontal :
                               UIPageViewControllerNavigationOrientationVertical
                           options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.contentView = _pageViewController.view;
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

- (void)setupCurrentPage {
    if (self.childrenViewController.count > 0) {
        if (self.currentPage < self.childrenViewController.count) {
            [self.pageViewController setViewControllers:@[self.childrenViewController[self.currentPage]]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
        }
        else {
            [self.pageViewController setViewControllers:@[self.childrenViewController[0]]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
}

- (void)setChildren:(NSArray *)children {
    NSMutableArray *childrenViewController = [NSMutableArray array];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [self.engine.componentFactory create:obj];
        if (view != nil) {
            UIViewController *vc = [[UIViewController alloc] init];
            [vc.view addSubview:view];
            [childrenViewController addObject:vc];
        }
    }];
    self.childrenViewController = childrenViewController.copy;
    [self setupCurrentPage];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.childrenViewController.count <= 1) {
        return nil;
    }
    NSInteger currentIndex = [self.childrenViewController indexOfObject:viewController];
    if (currentIndex >= 0) {
        if (currentIndex - 1 >= 0) {
            return self.childrenViewController[currentIndex - 1];
        }
        else if (self.isLoop) {
            return self.childrenViewController[self.childrenViewController.count - 1];
        }
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.childrenViewController.count <= 1) {
        return nil;
    }
    NSInteger currentIndex = [self.childrenViewController indexOfObject:viewController];
    if (currentIndex >= 0) {
        if (currentIndex + 1 < self.childrenViewController.count) {
            return self.childrenViewController[currentIndex + 1];
        }
        else if (self.isLoop) {
            return self.childrenViewController[0];
        }
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    UIViewController *currentViewController = pageViewController.viewControllers.firstObject;
    NSInteger currentIndex = [self.childrenViewController indexOfObject:currentViewController];
    if (currentIndex >= 0) {
        self.currentPage = (int)currentIndex;
        [self invokeMethod:@"onPageChanged" params:@{@"index": @(self.currentPage)}];
    }
}

- (void)animateToPage:(int)page animated:(BOOL)animated {
    if (page < self.childrenViewController.count) {
        bool forward = YES;
        if (page < self.currentPage) {
            forward = NO;
        }
        if (self.isLoop && page == 0 && self.currentPage + 1 >= self.childrenViewController.count) {
            forward = YES;
        }
        if (self.isLoop && page == self.childrenViewController.count - 1 && self.currentPage - 1 < 0) {
            forward = NO;
        }
        __weak MPIOSMPPageView *welf = self;
        [self.pageViewController setViewControllers:@[self.childrenViewController[page]]
                                          direction:forward ? UIPageViewControllerNavigationDirectionForward: UIPageViewControllerNavigationDirectionReverse
                                           animated:animated
                                         completion:^(BOOL finished) {
            MPIOSMPPageView *self = welf;
            if (self != nil) {
                self.currentPage = page;
                [self invokeMethod:@"onPageChanged" params:@{@"index": @(self.currentPage)}];
            }
        }];
    }
}

- (void)onMethodCall:(NSString *)method
              params:(NSDictionary *)params
      resultCallback:(MPIOSPlatformViewCallback)resultCallback {
    if ([@"animateToPage" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *page = params[@"page"];
        if ([page isKindOfClass:[NSNumber class]]) {
            int thePage = page.intValue;
            [self animateToPage:thePage animated:YES];
        }
    }
    else if ([@"jumpToPage" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *page = params[@"page"];
        if ([page isKindOfClass:[NSNumber class]]) {
            int thePage = page.intValue;
            [self animateToPage:thePage animated:NO];
        }
    }
    else if ([@"nextPage" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        if (self.currentPage + 1 < self.childrenViewController.count) {
            [self animateToPage:self.currentPage + 1 animated:YES];
        }
        else if (self.isLoop) {
            [self animateToPage:0 animated:YES];
        }
    }
    else if ([@"previousPage" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        if (self.currentPage - 1 >= 0) {
            [self animateToPage:self.currentPage - 1 animated:YES];
        }
        else if (self.isLoop) {
            [self animateToPage:(int)self.childrenViewController.count - 1 animated:YES];
        }
    }
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *scrollDirection = attributes[@"scrollDirection"];
    if ([scrollDirection isKindOfClass:[NSString class]] &&
        [scrollDirection isEqualToString:@"Axis.vertical"]) {
        self.isHorizontal = NO;
    }
    else {
        self.isHorizontal = YES;
    }
    if ([attributes[@"loop"] isKindOfClass:[NSNumber class]]) {
        self.isLoop = [attributes[@"loop"] boolValue];
    }
    else {
        self.isLoop = NO;
    }
    if (!self.initialPageSetted && [attributes[@"initialPage"] isKindOfClass:[NSNumber class]]) {
        self.initialPageSetted = YES;
        self.currentPage = [attributes[@"initialPage"] intValue];
    }
}

- (void)setIsHorizontal:(BOOL)isHorizontal {
    _isHorizontal = isHorizontal;
    [self resetPageViewController];
}

@end
