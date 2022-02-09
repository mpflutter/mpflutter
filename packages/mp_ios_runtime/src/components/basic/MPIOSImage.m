//
//  MPIOSImage.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSImage.h"
#import "MPIOSDebugger.h"
#import "MPIOSMpkReader.h"
#import "MPIOSProvider.h"
#import "MPIOSEngine+Private.h"

@interface MPIOSImage ()

@property (nonatomic, strong) UIImageView *contentView;

@end

@implementation MPIOSImage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        _contentView = [[UIImageView alloc] init];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *src = attributes[@"src"];
    NSString *base64 = attributes[@"base64"];
    NSString *assetName = attributes[@"assetName"];
    if ([src isKindOfClass:[NSString class]]) {
        [self.engine.provider.imageProvider loadImageWithURLString:src imageView:self.contentView];
    }
    else if ([base64 isKindOfClass:[NSString class]]) {
        NSData *imgData = [[NSData alloc] initWithBase64EncodedString:base64 options:kNilOptions];
        UIImage *img = [UIImage imageWithData:imgData];
        self.contentView.image = img;
    }
    else if ([assetName isKindOfClass:[NSString class]]) {
        UIImage *bundleImage = [UIImage imageNamed:assetName];
        if (bundleImage != nil) {
            self.contentView.image = bundleImage;
        }
        else if (self.engine.mpkReader != nil) {
            NSData *imageData = [self.engine.mpkReader dataWithFilePath:assetName];
            if (imageData != nil) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.contentView.image = image;
            }
            else {
                [self.engine.provider.imageProvider
                 loadImageWithURLString:assetName
                 imageView:self.contentView];
            }
        }
        else if (self.engine.debugger != nil) {
            NSString *assetUrl = [NSString stringWithFormat:@"http://%@/assets/%@",
                                  self.engine.debugger.serverAddr,
                                  assetName];
            [self.engine.provider.imageProvider
             loadImageWithURLString:assetUrl
             imageView:self.contentView];
        }
        else {
            [self.engine.provider.imageProvider
             loadImageWithURLString:assetName
             imageView:self.contentView];
        }
    }
    else {
        self.contentView.image = nil;
    }
    NSString *fit = attributes[@"fit"];
    if ([fit isKindOfClass:[NSString class]]) {
        if ([fit isEqualToString:@"BoxFit.contain"]) {
            self.contentView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else if ([fit isEqualToString:@"BoxFit.cover"]) {
            self.contentView.contentMode = UIViewContentModeScaleAspectFill;
        }
        else if ([fit isEqualToString:@"BoxFit.fill"]) {
            self.contentView.contentMode = UIViewContentModeScaleToFill;
        }
        else {
            self.contentView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    else {
        self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}

@end
