//
//  MPIOSMPCircularProgressIndicator.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSMPCircularProgressIndicator.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSProvider.h"

@interface MPIOSMPCircularProgressIndicator ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation MPIOSMPCircularProgressIndicator

- (void)setChildren:(NSArray *)children {
    if (self.contentView == nil) {
        self.contentView = [self.engine.provider.uiProvider createCircularProgressIndicator];
        if ([self.contentView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)self.contentView startAnimating];
        }
        [self addSubview:self.contentView];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ([self.contentView isKindOfClass:[UIActivityIndicatorView class]]) {
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.frame = self.bounds;
        self.contentView.transform = CGAffineTransformMakeScale([self.attributes[@"size"] floatValue] / 40.0,
                                                                [self.attributes[@"size"] floatValue] / 40.0);
    }
    else {
        self.contentView.frame = self.bounds;
    }
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if ([self.contentView isKindOfClass:[UIActivityIndicatorView class]]) {
        [(UIActivityIndicatorView *)self.contentView setColor:[MPIOSComponentUtils colorFromString:attributes[@"color"]]];
    }
}

@end
