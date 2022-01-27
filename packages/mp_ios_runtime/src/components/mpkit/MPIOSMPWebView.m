//
//  MPIOSWebView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPWebView.h"
#import <WebKit/WebKit.h>

@interface MPIOSMPWebView ()

@property (nonatomic, assign) BOOL firstSetted;
@property (nonatomic, strong) WKWebView *contentView;

@end

@implementation MPIOSMPWebView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentView = [[WKWebView alloc] init];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
}

- (void)setChildren:(NSArray *)children {}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *url = attributes[@"url"];
    if ([url isKindOfClass:[NSString class]] && !self.firstSetted) {
        self.firstSetted = YES;
        [self.contentView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

- (void)onMethodCall:(NSString *)method params:(NSDictionary *)params resultCallback:(nonnull MPIOSPlatformViewCallback)resultCallback {
    if ([method isEqualToString:@"reload"]) {
        [self.contentView reload];
    }
    else if ([method isEqualToString:@"loadUrl"]) {
        if ([params[@"url"] isKindOfClass:[NSString class]]) {
            [self.contentView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:params[@"url"]]]];
        }
    }
}


@end
