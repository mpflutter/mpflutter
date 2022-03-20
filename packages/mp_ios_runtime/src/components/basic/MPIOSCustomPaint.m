//
//  MPIOSCustomPaint.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/17.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSCustomPaint.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSEngine.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSDrawableStorage ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *decodedDrawables;

@end

@implementation MPIOSDrawableStorage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _decodedDrawables = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)decodeDrawable:(NSDictionary *)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *type = params[@"type"];
    if (![type isKindOfClass:[NSString class]]) {
        return;
    }
    if ([type isEqualToString:@"networkImage"]) {
        [self decodeNetworkImage:params];
    }
    else if ([type isEqualToString:@"memoryImage"]) {
        [self decodeMemoryImage:params];
    }
    else if ([type isEqualToString:@"dispose"]) {
        [self dispose:params];
    }
}

- (void)decodeNetworkImage:(NSDictionary *)params {
    NSNumber *target = params[@"target"];
    NSString *url = params[@"url"];
    if (![target isKindOfClass:[NSNumber class]] ||
        ![url isKindOfClass:[NSString class]]) {
        return;
    }
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onDecodeError:error target:target];
            });
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image == nil) {
                    [self onDecodeError:[NSError
                                         errorWithDomain:@"mp_drawable"
                                         code:-1
                                         userInfo:nil] target:target];
                    return;
                }
                self.decodedDrawables[target] = image;
                [self onDecodeResult:target
                               width:@(image.size.width)
                              height:@(image.size.height)];
            });
        });
    }] resume];
}

- (void)decodeMemoryImage:(NSDictionary *)params {
    NSNumber *target = params[@"target"];
    NSString *data = params[@"data"];
    if (![target isKindOfClass:[NSNumber class]] ||
        ![data isKindOfClass:[NSString class]]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:data options:kNilOptions]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image == nil) {
                [self onDecodeError:[NSError
                                     errorWithDomain:@"mp_drawable"
                                     code:-1
                                     userInfo:nil] target:target];
                return;
            }
            self.decodedDrawables[target] = image;
            [self onDecodeResult:target
                           width:@(image.size.width)
                          height:@(image.size.height)];
        });
    });
}

- (void)dispose:(NSDictionary *)params {
    NSNumber *target = params[@"target"];
    if (![target isKindOfClass:[NSNumber class]]) {
        return;
    }
    [self.decodedDrawables removeObjectForKey:target];
}

- (void)onDecodeResult:(NSNumber *)target width:(NSNumber *)width height:(NSNumber *)height {
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"decode_drawable",
            @"message": @{
                    @"event": @"onDecode",
                    @"target": target,
                    @"width": width,
                    @"height": height,
            },
        }];
    }
}

- (void)onDecodeError:(NSError *)error target:(NSNumber *)target {
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"decode_drawable",
            @"message": @{
                    @"event": @"onError",
                    @"target": target,
                    @"error": error.localizedDescription ?: @"",
            },
        }];
    }
}

@end

@interface MPIOSCustomPaintState : NSObject

@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, strong) CAShapeLayer *clipPath;

@end

@implementation MPIOSCustomPaintState

- (instancetype)init
{
    self = [super init];
    if (self) {
        _transform = CGAffineTransformIdentity;
    }
    return self;
}

@end

@interface MPIOSCustomPaint ()

@property (nonatomic, strong) NSMutableArray<MPIOSCustomPaintState *> *stateStack;

@end

@implementation MPIOSCustomPaint

+ (void)didReceivedCustomPaintMessage:(NSDictionary *)message engine:(MPIOSEngine *)engine {
    if ([@"fetchImage" isEqualToString:message[@"event"]]) {
        MPIOSCustomPaint *target = (id)engine.componentFactory.cachedView[message[@"target"]];
        if ([target isKindOfClass:[MPIOSCustomPaint class]]) {
            UIGraphicsBeginImageContextWithOptions(target.layer.bounds.size, NO, 0);
            [target.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *data = UIImagePNGRepresentation(outputImage);
            if (data == nil) {
                return;
            }
            NSString *base64EncodedData = [data base64EncodedStringWithOptions:kNilOptions];
            if (base64EncodedData == nil) {
                return;
            }
            [engine sendMessage:@{
                @"type": @"custom_paint",
                @"message": @{
                  @"event": @"onFetchImageResult",
                  @"seqId": message[@"seqId"] ?: [NSNull null],
                  @"data": base64EncodedData,
                },
            }];
        }
    }
}

- (void)resetStateStack {
    self.stateStack = [NSMutableArray array];
    [self.stateStack addObject:[[MPIOSCustomPaintState alloc] init]];
}

- (MPIOSCustomPaintState *)currentState {
    return self.stateStack.lastObject;
}

- (void)setChildren:(NSArray *)children {
    self.layer.masksToBounds = YES;
}

- (void)setAttributes:(NSDictionary *)attributes {
    NSArray *commands = attributes[@"commands"];
    if ([commands isKindOfClass:[NSArray class]]) {
        [self resetStateStack];
        [commands enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull cmd, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![cmd isKindOfClass:[NSDictionary class]]) {
                return;
            }
            NSString *action = cmd[@"action"];
            if (![action isKindOfClass:[NSString class]]) {
                return;
            }
            if ([action isEqualToString:@"drawRect"]) {
                [self mpDrawRect:cmd];
            }
            else if ([action isEqualToString:@"drawDRRect"]) {
                [self drawDRRect:cmd];
            }
            else if ([action isEqualToString:@"drawPath"]) {
                [self drawPath:cmd];
            }
            else if ([action isEqualToString:@"clipPath"]) {
                [self drawPath:cmd];
            }
            else if ([action isEqualToString:@"drawColor"]) {
                [self drawColor:cmd];
            }
            else if ([action isEqualToString:@"drawImage"]) {
                [self drawImage:cmd];
            }
            else if ([action isEqualToString:@"drawImageRect"]) {
                [self drawImageRect:cmd];
            }
            else if ([action isEqualToString:@"save"]) {
                [self.stateStack addObject:[[MPIOSCustomPaintState alloc] init]];
            }
            else if ([action isEqualToString:@"restore"]) {
                if (self.stateStack.count > 1) {
                    [self.stateStack removeLastObject];
                }
            }
            else if ([action isEqualToString:@"rotate"]) {
                [self rotate:cmd];
            }
            else if ([action isEqualToString:@"scale"]) {
                [self scale:cmd];
            }
            else if ([action isEqualToString:@"translate"]) {
                [self translate:cmd];
            }
            else if ([action isEqualToString:@"transform"]) {
                [self transform:cmd];
            }
            else if ([action isEqualToString:@"skew"]) {
                [self skew:cmd];
            }
        }];
    }
}

- (void)rotate:(NSDictionary *)params {
    if ([params[@"radians"] isKindOfClass:[NSNumber class]]) {
        CGAffineTransform t = [self currentState].transform;
        t = CGAffineTransformRotate(t, [params[@"radians"] floatValue]);
        [self currentState].transform = t;
    }
}

- (void)scale:(NSDictionary *)params {
    if ([params[@"sx"] isKindOfClass:[NSNumber class]]) {
        CGFloat sx = [params[@"sx"] floatValue];
        CGFloat sy = [params[@"sy"] isKindOfClass:[NSNumber class]] ? [params[@"sy"] floatValue] : sx;
        CGAffineTransform t = [self currentState].transform;
        t = CGAffineTransformScale(t, sx, sy);
        [self currentState].transform = t;
    }
}

- (void)translate:(NSDictionary *)params {
    if ([params[@"dx"] isKindOfClass:[NSNumber class]]) {
        CGFloat dx = [params[@"dx"] floatValue];
        CGFloat dy = [params[@"dy"] isKindOfClass:[NSNumber class]] ? [params[@"dy"] floatValue] : 0.0;
        CGAffineTransform t = [self currentState].transform;
        t = CGAffineTransformTranslate(t, dx, dy);
        [self currentState].transform = t;
    }
}

- (void)skew:(NSDictionary *)params {
    if ([params[@"sx"] isKindOfClass:[NSNumber class]]) {
        CGFloat sx = [params[@"sx"] floatValue];
        CGFloat sy = [params[@"sy"] isKindOfClass:[NSNumber class]] ? [params[@"sy"] floatValue] : sx;
        CGAffineTransform t = [self currentState].transform;
        CGAffineTransform t2 = CGAffineTransformMake(
                                                     1.0,
                                                     sy,
                                                     sx,
                                                     1.0,
                                                     0.0,
                                                     0.0);
        t = CGAffineTransformConcat(t, t2);
        [self currentState].transform = t;
    }
}

- (void)transform:(NSDictionary *)params {
    if ([params[@"a"] isKindOfClass:[NSNumber class]] &&
        [params[@"b"] isKindOfClass:[NSNumber class]] &&
        [params[@"c"] isKindOfClass:[NSNumber class]] &&
        [params[@"d"] isKindOfClass:[NSNumber class]] &&
        [params[@"tx"] isKindOfClass:[NSNumber class]] &&
        [params[@"ty"] isKindOfClass:[NSNumber class]]) {
        CGAffineTransform t = [self currentState].transform;
        CGAffineTransform t2 = CGAffineTransformMake(
                                                     [params[@"a"] floatValue],
                                                     [params[@"b"] floatValue],
                                                     [params[@"c"] floatValue],
                                                     [params[@"d"] floatValue],
                                                     [params[@"tx"] floatValue],
                                                     [params[@"ty"] floatValue]);
        t = CGAffineTransformConcat(t, t2);
        [self currentState].transform = t;
    }
}

- (void)drawDRRect:(NSDictionary *)params {
    NSDictionary *outer = params[@"outer"];
    NSDictionary *inner = params[@"inner"];
    if (![outer isKindOfClass:[NSDictionary class]] ||
        ![inner isKindOfClass:[NSDictionary class]]) {
        return;
    }
    UIBezierPath *outerPath = [self pathWithParams:outer];
    UIBezierPath *innerPath = [self pathWithParams:inner];
    [outerPath appendPath:innerPath];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    [shapeLayer setPath:outerPath.CGPath];
    [self setPaint:shapeLayer params:params[@"paint"]];
    [self addSublayer:shapeLayer];
}

- (void)mpDrawRect:(NSDictionary *)params {
    NSNumber *x = params[@"x"];
    NSNumber *y = params[@"y"];
    NSNumber *width = params[@"width"];
    NSNumber *height = params[@"height"];
    if (![x isKindOfClass:[NSNumber class]] ||
        ![y isKindOfClass:[NSNumber class]] ||
        ![width isKindOfClass:[NSNumber class]] ||
        ![height isKindOfClass:[NSNumber class]]) {
        return;
    }
    UIBezierPath *bezierPath = [UIBezierPath
                                bezierPathWithRect:CGRectMake(
                                                              x.floatValue,
                                                              y.floatValue,
                                                              width.floatValue,
                                                              height.floatValue)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:bezierPath.CGPath];
    [self setPaint:shapeLayer params:params[@"paint"]];
    [self addSublayer:shapeLayer];
}

- (void)drawPath:(NSDictionary *)params {
    UIBezierPath *bezierPath = [self pathWithParams:params[@"path"]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:bezierPath.CGPath];
    [self setPaint:shapeLayer params:params[@"paint"]];
    if ([params[@"action"] isKindOfClass:[NSString class]] &&
        [params[@"action"] isEqualToString:@"clipPath"]) {
        [self currentState].clipPath = shapeLayer;
    }
    else {
        [self addSublayer:shapeLayer];
    }
}

- (void)drawColor:(NSDictionary *)params {
    NSString *blendMode = params[@"blendMode"];
    if ([blendMode isEqualToString:@"BlendMode.clear"]) {
        for (CALayer *sublayer in self.layer.sublayers.copy) {
            [sublayer removeFromSuperlayer];
        }
    }
    else {
        NSString *color = params[@"color"];
        if (color != nil) {
            CALayer *layer = [CALayer layer];
            layer.frame = self.bounds;
            layer.backgroundColor = [MPIOSComponentUtils colorFromString:color].CGColor;
            [self addSublayer:layer];
        }
    }
}

- (void)drawImage:(NSDictionary *)params {
    NSNumber *drawable = params[@"drawable"];
    if (![drawable isKindOfClass:[NSNumber class]]) {
        return;
    }
    CGFloat x = [params[@"dx"] isKindOfClass:[NSNumber class]] ? [params[@"dx"] floatValue] : 0.0;
    CGFloat y = [params[@"dy"] isKindOfClass:[NSNumber class]] ? [params[@"dy"] floatValue] : 0.0;
    UIImage *image = self.engine.drawableStorage.decodedDrawables[drawable];
    if (image != nil) {
        CALayer *layer = [CALayer layer];
        layer.contents = (__bridge id _Nullable)(image.CGImage);
        layer.frame = CGRectMake(x, y, image.size.width, image.size.height);
        [self addSublayer:layer];
    }
}

- (void)drawImageRect:(NSDictionary *)params {
    NSNumber *drawable = params[@"drawable"];
    if (![drawable isKindOfClass:[NSNumber class]]) {
        return;
    }
    CGFloat srcX = [params[@"srcX"] isKindOfClass:[NSNumber class]] ? [params[@"srcX"] floatValue] : 0.0;
    CGFloat srcY = [params[@"srcY"] isKindOfClass:[NSNumber class]] ? [params[@"srcY"] floatValue] : 0.0;
    CGFloat srcW = [params[@"srcW"] isKindOfClass:[NSNumber class]] ? [params[@"srcW"] floatValue] : 0.0;
    CGFloat srcH = [params[@"srcH"] isKindOfClass:[NSNumber class]] ? [params[@"srcH"] floatValue] : 0.0;
    CGFloat dstX = [params[@"dstX"] isKindOfClass:[NSNumber class]] ? [params[@"dstX"] floatValue] : 0.0;
    CGFloat dstY = [params[@"dstY"] isKindOfClass:[NSNumber class]] ? [params[@"dstY"] floatValue] : 0.0;
    CGFloat dstW = [params[@"dstW"] isKindOfClass:[NSNumber class]] ? [params[@"dstW"] floatValue] : 0.0;
    CGFloat dstH = [params[@"dstH"] isKindOfClass:[NSNumber class]] ? [params[@"dstH"] floatValue] : 0.0;
    UIImage *image = self.engine.drawableStorage.decodedDrawables[drawable];
    if (image != nil && image.size.width > 0 && image.size.height > 0) {
        CALayer *layer = [CALayer layer];
        layer.contents = (__bridge id _Nullable)(image.CGImage);
        layer.contentsRect = CGRectMake(
                                        srcX / image.size.width,
                                        srcY / image.size.height,
                                        (srcX + srcW) / image.size.width,
                                        (srcX + srcH) / image.size.height);
        layer.frame = CGRectMake(dstX, dstY, dstW, dstH);
        [self addSublayer:layer];
    }
}

- (void)addSublayer:(CALayer *)layer {
    if ([self currentState].clipPath != nil) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [self currentState].clipPath.path;
        maskLayer.frame = CGRectMake(-layer.frame.origin.x, -layer.frame.origin.y, 0, 0);
        layer.mask = maskLayer;
    }
    if (!CGAffineTransformIsIdentity([self currentState].transform)) {
        layer.transform = CATransform3DMakeAffineTransform([self currentState].transform);
    }
    [self.layer addSublayer:layer];
}

- (UIBezierPath *)pathWithParams:(NSDictionary *)path {
    __block UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    if (![path isKindOfClass:[NSDictionary class]]) {
        return bezierPath;
    }
    NSArray *commands = path[@"commands"];
    if (![commands isKindOfClass:[NSArray class]]) {
        return bezierPath;
    }
    [commands enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *action = obj[@"action"];
        if (![action isKindOfClass:[NSString class]]) {
            return;
        }
        if ([action isEqualToString:@"moveTo"]) {
            if ([obj[@"x"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y"] isKindOfClass:[NSNumber class]]) {
                [bezierPath moveToPoint:CGPointMake([obj[@"x"] floatValue],
                                                    [obj[@"y"] floatValue])];
            }
        }
        else if ([action isEqualToString:@"lineTo"]) {
            if ([obj[@"x"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y"] isKindOfClass:[NSNumber class]]) {
                [bezierPath addLineToPoint:CGPointMake([obj[@"x"] floatValue],
                                                       [obj[@"y"] floatValue])];
            }
        }
        else if ([action isEqualToString:@"quadraticBezierTo"]) {
            if ([obj[@"x1"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y1"] isKindOfClass:[NSNumber class]] &&
                [obj[@"x2"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y2"] isKindOfClass:[NSNumber class]]) {
                [bezierPath
                 addQuadCurveToPoint:CGPointMake([obj[@"x2"] floatValue],
                                                 [obj[@"y2"] floatValue])
                 controlPoint:CGPointMake([obj[@"x1"] floatValue],
                                          [obj[@"y1"] floatValue])];
            }
        }
        else if ([action isEqualToString:@"cubicTo"]) {
            if ([obj[@"x1"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y1"] isKindOfClass:[NSNumber class]] &&
                [obj[@"x2"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y2"] isKindOfClass:[NSNumber class]] &&
                [obj[@"x3"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y3"] isKindOfClass:[NSNumber class]]) {
                [bezierPath
                 addCurveToPoint:CGPointMake([obj[@"x3"] floatValue],
                                             [obj[@"y3"] floatValue])
                 controlPoint1:CGPointMake([obj[@"x1"] floatValue],
                                           [obj[@"y1"] floatValue])
                 controlPoint2:CGPointMake([obj[@"x2"] floatValue],
                                           [obj[@"y2"] floatValue])];
            }
        }
        else if ([action isEqualToString:@"arcTo"]) {
            if ([obj[@"x"] isKindOfClass:[NSNumber class]] &&
                [obj[@"y"] isKindOfClass:[NSNumber class]] &&
                [obj[@"width"] isKindOfClass:[NSNumber class]] &&
                [obj[@"height"] isKindOfClass:[NSNumber class]] &&
                [obj[@"startAngle"] isKindOfClass:[NSNumber class]] &&
                [obj[@"sweepAngle"] isKindOfClass:[NSNumber class]]) {
                CGPathRef pathRef = bezierPath.CGPath;
                CGMutablePathRef mutablePath = CGPathCreateMutableCopyByTransformingPath(pathRef, NULL);
                CGAffineTransform t = CGAffineTransformIdentity;
                float width = [obj[@"width"] floatValue];
                float height = [obj[@"height"] floatValue];
                if (fabs(width - height) > 0.01) {
                    t = CGAffineTransformScale(t, 1.0, height / width);
                    t = CGAffineTransformTranslate(t, 0.0, (width - height) / 2.0);
                }
                CGPathAddArc(mutablePath,
                             &t,
                             [obj[@"x"] floatValue],
                             [obj[@"y"] floatValue],
                             width / 2.0,
                             [obj[@"startAngle"] floatValue],
                             [obj[@"startAngle"] floatValue] + [obj[@"sweepAngle"] floatValue],
                             [obj[@"sweepAngle"] floatValue] < 0.0);
                bezierPath = [UIBezierPath bezierPathWithCGPath:mutablePath];
                CGPathRelease(mutablePath);

            }
        }
        else if ([action isEqualToString:@"arcToPoint"]) {
            if ([obj[@"arcControlX"] isKindOfClass:[NSNumber class]] &&
                [obj[@"arcControlY"] isKindOfClass:[NSNumber class]] &&
                [obj[@"arcEndX"] isKindOfClass:[NSNumber class]] &&
                [obj[@"arcEndY"] isKindOfClass:[NSNumber class]] &&
                [obj[@"radiusX"] isKindOfClass:[NSNumber class]]) {
                CGPathRef pathRef = bezierPath.CGPath;
                CGMutablePathRef mutablePath = CGPathCreateMutableCopyByTransformingPath(pathRef, NULL);
                CGPathAddArcToPoint(mutablePath,
                                    NULL,
                                    [obj[@"arcControlX"] floatValue],
                                    [obj[@"arcControlY"] floatValue],
                                    [obj[@"arcEndX"] floatValue],
                                    [obj[@"arcEndY"] floatValue],
                                    [obj[@"radiusX"] floatValue]);
                bezierPath = [UIBezierPath bezierPathWithCGPath:mutablePath];
                CGPathRelease(mutablePath);
            }
        }
        else if ([action isEqualToString:@"close"]) {
            [bezierPath closePath];
        }
    }];
    return bezierPath;
}

- (void)setPaint:(CAShapeLayer *)shapeLayer params:(NSDictionary *)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if ([params[@"strokeWidth"] isKindOfClass:[NSNumber class]]) {
        shapeLayer.lineWidth = [params[@"strokeWidth"] floatValue];
    }
    if ([params[@"miterLimit"] isKindOfClass:[NSNumber class]]) {
        shapeLayer.miterLimit = [params[@"miterLimit"] floatValue];
    }
    NSString *strokeCap = params[@"strokeCap"];
    if ([strokeCap isKindOfClass:[NSString class]]) {
        if ([strokeCap isEqualToString:@"StrokeCap.butt"]) {
            shapeLayer.lineCap = @"butt";
        }
        else if ([strokeCap isEqualToString:@"StrokeCap.round"]) {
            shapeLayer.lineCap = @"round";
        }
        else if ([strokeCap isEqualToString:@"StrokeCap.square"]) {
            shapeLayer.lineCap = @"square";
        }
        else {
            shapeLayer.lineCap = @"butt";
        }
    }
    NSString *strokeJoin = params[@"strokeJoin"];
    if ([strokeJoin isKindOfClass:[NSString class]]) {
        if ([strokeJoin isEqualToString:@"StrokeJoin.miter"]) {
            shapeLayer.lineJoin = @"miter";
        }
        else if ([strokeJoin isEqualToString:@"StrokeJoin.round"]) {
            shapeLayer.lineJoin = @"round";
        }
        else if ([strokeJoin isEqualToString:@"StrokeJoin.bevel"]) {
            shapeLayer.lineJoin = @"bevel";
        }
        else {
            shapeLayer.lineJoin = @"miter";
        }
    }
    NSString *style = params[@"style"];
    NSString *color = params[@"color"];
    if ([style isKindOfClass:[NSString class]] &&
        [color isKindOfClass:[NSString class]]) {
        if ([style isEqualToString:@"PaintingStyle.fill"]) {
            shapeLayer.fillColor = [MPIOSComponentUtils colorFromString:color].CGColor;
            shapeLayer.strokeColor = nil;
        }
        else {
            shapeLayer.strokeColor = [MPIOSComponentUtils colorFromString:color].CGColor;
            shapeLayer.fillColor = nil;
        }
    }
    if ([params[@"alpha"] isKindOfClass:[NSNumber class]]) {
        shapeLayer.opacity = [params[@"alpha"] floatValue];
    }
}

@end
