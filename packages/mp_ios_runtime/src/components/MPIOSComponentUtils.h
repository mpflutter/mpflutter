//
//  MPIOSComponentUtils.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSComponentUtils : NSObject

+ (UIColor *)colorFromString:(NSString *)value;
+ (NSArray *)colorsFromGradient:(NSDictionary *)value;
+ (NSArray *)stopsFromGradient:(NSDictionary *)value;
+ (CGPoint)locationFromGradient:(NSString *)value;
+ (float)floatFromString:(NSString *)value;
+ (CGSize)shadowOffsetFromString:(NSString *)value;
+ (UIEdgeInsets)edgeInsetsFromString:(NSString *)value;
+ (UIEdgeInsets)cornerRadiusFromString:(NSString *)value;
+ (UIBezierPath *)bezierPathWithValue:(UIEdgeInsets)insets size:(CGSize)size;
+ (CGSize)sizeFromMPElement:(NSDictionary *)element;
+ (UIEdgeInsets)sliverPaddingFromMPElement:(NSDictionary *)element;
+ (NSDate *)dateFromString:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
