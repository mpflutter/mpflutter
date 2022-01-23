//
//  MPSampleProvider.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/23.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPSampleProvider.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageSVGKitPlugin/SDWebImageSVGKitPlugin.h>

@implementation MPSampleImageProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[SDImageCodersManager sharedManager] addCoder:[SDImageSVGKCoder sharedCoder]];
    }
    return self;
}

- (void)loadImageWithURLString:(NSString *)URLString imageView:(UIImageView *)imageView {
    [imageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                 placeholderImage:nil
                          options:0
                          context:@{SDWebImageContextImageThumbnailPixelSize : @(imageView.bounds.size)}];
}

@end
