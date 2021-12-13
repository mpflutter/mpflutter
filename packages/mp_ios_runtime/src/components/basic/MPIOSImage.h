//
//  MPIOSImage.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSComponentView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MPIOSImageLoader)(UIImageView *, NSString *);

@interface MPIOSImage : MPIOSComponentView

+ (void)setupImageLoader:(MPIOSImageLoader)imageLoader;
+ (void)loadImageWithView:(UIView *)view src:(NSString *)src;

@end

NS_ASSUME_NONNULL_END
