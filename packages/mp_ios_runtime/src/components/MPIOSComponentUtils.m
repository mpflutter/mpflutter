//
//  MPIOSComponentUtils.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSComponentUtils.h"

@implementation MPIOSComponentUtils

NSNumberFormatter *numberFormatter;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
}

+ (UIColor *)colorFromString:(NSString *)value {
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    long longValue = [[numberFormatter numberFromString:value] longValue];
    return [UIColor colorWithRed:((longValue >> 16) & 255) / 255.0
                           green:((longValue >> 8) & 255) / 255.0
                            blue:((longValue >> 0) & 255) / 255.0
                           alpha:((longValue >> 24) & 255) / 255.0];
}

+ (NSArray *)colorsFromGradient:(NSDictionary *)value {
    if ([value[@"colors"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [NSMutableArray array];
        [(NSArray *)value[@"colors"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIColor *color = [self colorFromString:obj];
            if (color != nil) {
                [result addObject:(id)color.CGColor];
            }
        }];
        return result.copy;
    }
    return @[];
}

+ (NSArray *)stopsFromGradient:(NSDictionary *)value {
    if ([value[@"stops"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [NSMutableArray array];
        [(NSArray *)value[@"stops"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                [result addObject:obj];
            }
        }];
        return result.copy;
    }
    return nil;
}

+ (CGPoint)locationFromGradient:(NSString *)value {
    if (value == nil) {
        return CGPointZero;
    }
    if ([value isEqualToString:@"centerRight"]) {
        return CGPointMake(1.0, 0.5);
    }
    else if ([value isEqualToString:@"centerLeft"]) {
        return CGPointMake(0.0, 0.5);
    }
    else if ([value isEqualToString:@"topRight"]) {
        return CGPointMake(1.0, 0.0);
    }
    else if ([value isEqualToString:@"bottomRight"]) {
        return CGPointMake(1.0, 1.0);
    }
    else if ([value isEqualToString:@"topLeft"]) {
        return CGPointMake(0.0, 0.0);
    }
    else if ([value isEqualToString:@"bottomLeft"]) {
        return CGPointMake(0.0, 1.0);
    }
    else if ([value isEqualToString:@"topCenter"]) {
        return CGPointMake(0.5, 0.0);
    }
    else if ([value isEqualToString:@"bottomCenter"]) {
        return CGPointMake(0.5, 1.0);
    }
    return CGPointZero;
}

+ (float)floatFromString:(NSString *)value {
    if (![value isKindOfClass:[NSString class]]) {
        return 0.0;
    }
    return [[numberFormatter numberFromString:[value stringByReplacingOccurrencesOfString:@" "
                                                                               withString:@""]]
            floatValue];
}

+ (CGSize)shadowOffsetFromString:(NSString *)value {
    if ([value hasPrefix:@"Offset("]) {
        NSString *trimedValue = [[value stringByReplacingOccurrencesOfString:@"Offset("
                                                                  withString:@""]
                                 stringByReplacingOccurrencesOfString:@")"
                                 withString:@""];
        NSArray *values = [trimedValue componentsSeparatedByString:@","];
        if (values.count == 2) {
            return CGSizeMake([self floatFromString:values[0]],
                              [self floatFromString:values[1]]);
        }
        else {
            return CGSizeZero;
        }
    }
    else {
        return CGSizeZero;
    }
}

+ (UIEdgeInsets)edgeInsetsFromString:(NSString *)value {
    if ([value hasPrefix:@"EdgeInsets.all("]) {
        NSString *trimedValue = [[value stringByReplacingOccurrencesOfString:@"EdgeInsets.all("
                                                                  withString:@""]
                                 stringByReplacingOccurrencesOfString:@")"
                                 withString:@""];
        float value = [self floatFromString:trimedValue];
        return UIEdgeInsetsMake(value, value, value, value);
    }
    else if ([value hasPrefix:@"EdgeInsets("]) {
        NSString *trimedValue = [[value stringByReplacingOccurrencesOfString:@"EdgeInsets("
                                                                  withString:@""]
                                 stringByReplacingOccurrencesOfString:@")"
                                 withString:@""];
        NSArray *components = [trimedValue componentsSeparatedByString:@","];
        if (components.count == 4) {
            return UIEdgeInsetsMake([self floatFromString:components[1]],
                                    [self floatFromString:components[0]],
                                    [self floatFromString:components[3]],
                                    [self floatFromString:components[2]]);
        }
        else {
            return UIEdgeInsetsZero;
        }
    }
    else {
        return UIEdgeInsetsZero;
    }
}

+ (UIEdgeInsets)cornerRadiusFromString:(NSString *)value {
    if ([value hasPrefix:@"BorderRadius.circular("]) {
        NSString *trimedValue = [[value stringByReplacingOccurrencesOfString:@"BorderRadius.circular("
                                                                  withString:@""]
                                 stringByReplacingOccurrencesOfString:@")"
                                 withString:@""];
        float value = [self floatFromString:trimedValue];
        return UIEdgeInsetsMake(value, value, value, value);
    }
    else if ([value hasPrefix:@"BorderRadius.all("]) {
        NSString *trimedValue = [[value stringByReplacingOccurrencesOfString:@"BorderRadius.all("
                                                                  withString:@""]
                                 stringByReplacingOccurrencesOfString:@")"
                                 withString:@""];
        float value = [self floatFromString:trimedValue];
        return UIEdgeInsetsMake(value, value, value, value);
    }
    else if ([value hasPrefix:@"BorderRadius.only("]) {
        NSString *trimedValue = [[[value stringByReplacingOccurrencesOfString:@"BorderRadius.only("
                                                                   withString:@""]
                                  stringByReplacingOccurrencesOfString:@")"
                                  withString:@""]
                                 stringByReplacingOccurrencesOfString:@"Radius.circular("
                                 withString:@""];
        CGFloat tl = [self floatFromRegularFirstObject:@"topLeft: ([0-9|.]+)" text:trimedValue];
        CGFloat bl = [self floatFromRegularFirstObject:@"bottomLeft: ([0-9|.]+)" text:trimedValue];
        CGFloat br = [self floatFromRegularFirstObject:@"bottomRight: ([0-9|.]+)" text:trimedValue];
        CGFloat tr = [self floatFromRegularFirstObject:@"topRight: ([0-9|.]+)" text:trimedValue];
        return UIEdgeInsetsMake(tl, bl, br, tr);
    }
    else {
        return UIEdgeInsetsZero;
    }
}

+ (UIBezierPath *)bezierPathWithValue:(UIEdgeInsets)insets size:(CGSize)size {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat tl = insets.top;
    CGFloat bl = insets.left;
    CGFloat br = insets.bottom;
    CGFloat tr = insets.right;
    [path moveToPoint:CGPointMake(tl, 0)];
    [path addLineToPoint:CGPointMake(size.width - tr, 0)];
    if (tr > 0) {
        [path addArcWithCenter:CGPointMake(size.width - tr, tr)
                        radius:tr
                    startAngle:-M_PI / 2.0
                      endAngle:0.0
                     clockwise:YES];
    }
    [path addLineToPoint:CGPointMake(size.width, size.height - br)];
    if (br > 0) {
        [path addArcWithCenter:CGPointMake(size.width - br, size.height - br)
                        radius:br
                    startAngle:0.0
                      endAngle:M_PI / 2.0
                     clockwise:YES];
    }
    [path addLineToPoint:CGPointMake(bl, size.height)];
    if (bl > 0) {
        [path addArcWithCenter:CGPointMake(bl, size.height - bl)
                        radius:bl
                    startAngle:M_PI / 2.0
                      endAngle:M_PI
                     clockwise:YES];
    }
    [path addLineToPoint:CGPointMake(0.0, tl)];
    if (tl > 0) {
        [path addArcWithCenter:CGPointMake(tl, tl)
                        radius:tl
                    startAngle:M_PI
                      endAngle:-M_PI / 2.0
                     clockwise:YES];
    }
    [path closePath];
    return path;
}

+ (CGFloat)floatFromRegularFirstObject:(NSString *)pattern text:(NSString *)text {
    NSRegularExpression *tlr = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:kNilOptions
                                                                           error:NULL];
    NSArray<NSTextCheckingResult *> *result = [tlr matchesInString:text options:kNilOptions range:NSMakeRange(0, text.length)];
    if (result.count > 0) {
        NSRange resultRange = [result.firstObject rangeAtIndex:1];
        return [self floatFromString:[text substringWithRange:resultRange]];
    }
    return 0.0;
}

+ (CGSize)sizeFromMPElement:(NSDictionary *)element {
    if (![element isKindOfClass:[NSDictionary class]]) {
        return CGSizeZero;
    }
    CGFloat w = 0.0, h = 0.0;
    if ([element isKindOfClass:[NSDictionary class]] &&
        [element[@"constraints"] isKindOfClass:[NSDictionary class]] &&
        [element[@"constraints"][@"w"] isKindOfClass:[NSNumber class]] &&
        [element[@"constraints"][@"h"] isKindOfClass:[NSNumber class]]) {
        w = [element[@"constraints"][@"w"] floatValue];
        h = [element[@"constraints"][@"h"] floatValue];
    }
    else if ([element isKindOfClass:[NSDictionary class]] &&
             [element[@"children"] isKindOfClass:[NSArray class]] &&
             [element[@"children"] count] == 1) {
        return [self sizeFromMPElement:element[@"children"][0]];
    }
    return CGSizeMake(w, h);
}

+ (UIEdgeInsets)sliverPaddingFromMPElement:(NSDictionary *)element {
    if (![element isKindOfClass:[NSDictionary class]]) {
        return UIEdgeInsetsZero;
    }
    if ([element isKindOfClass:[NSDictionary class]] &&
        [element[@"name"] isKindOfClass:[NSString class]] &&
        [element[@"name"] isEqualToString:@"padding"] &&
        [element[@"attributes"] isKindOfClass:[NSDictionary class]] &&
            [element[@"attributes"][@"padding"] isKindOfClass:[NSString class]] &&
            [element[@"attributes"][@"sliver"] isKindOfClass:[NSString class]] &&
            [element[@"attributes"][@"sliver"] isEqualToString:@"1"]) {
        return [self edgeInsetsFromString:element[@"attributes"][@"padding"]];
    }
    
    else if ([element isKindOfClass:[NSDictionary class]] &&
             [element[@"children"] isKindOfClass:[NSArray class]] &&
             [element[@"children"] count] == 1) {
        return [self sliverPaddingFromMPElement:element[@"children"][0]];
    }
    return UIEdgeInsetsZero;
}

+ (NSDate *)dateFromString:(NSString *)value {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    return [dateFormatter dateFromString:value];
}

@end
