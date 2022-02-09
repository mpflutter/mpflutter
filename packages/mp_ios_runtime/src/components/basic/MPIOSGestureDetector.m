//
//  MPIOSGestureDetector.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSGestureDetector.h"
#import "MPIOSEngine+Private.h"

@interface MPIOSGestureDetector ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation MPIOSGestureDetector

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    self.userInteractionEnabled = YES;
    if ([attributes[@"onTap"] isKindOfClass:[NSNumber class]]) {
        if (self.tapGesture == nil) {
            self.tapGesture = [[UITapGestureRecognizer alloc]
                                initWithTarget:self
                                action:@selector(onTap)];
            [self addGestureRecognizer:self.tapGesture];
        }
    }
    else {
        if (self.tapGesture != nil) {
            [self removeGestureRecognizer:self.tapGesture];
            self.tapGesture = nil;
        }
    }
    if ([attributes[@"onLongPress"] isKindOfClass:[NSNumber class]] ||
        [attributes[@"onLongPressStart"] isKindOfClass:[NSNumber class]] ||
        [attributes[@"onLongPressMoveUpdate"] isKindOfClass:[NSNumber class]] ||
        [attributes[@"onLongPressEnd"] isKindOfClass:[NSNumber class]]) {
        if (self.longPressGesture == nil) {
            self.longPressGesture = [[UILongPressGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(onLongPress:)];
            [self addGestureRecognizer:self.longPressGesture];
        }
    }
    else {
        if (self.longPressGesture != nil) {
            [self removeGestureRecognizer:self.longPressGesture];
            self.longPressGesture = nil;
        }
    }
    if ([attributes[@"onPanStart"] isKindOfClass:[NSNumber class]] ||
        [attributes[@"onPanUpdate"] isKindOfClass:[NSNumber class]] ||
        [attributes[@"onPanEnd"] isKindOfClass:[NSNumber class]]) {
        if (self.panGesture == nil) {
            self.panGesture = [[UIPanGestureRecognizer alloc]
                               initWithTarget:self
                               action:@selector(onPan:)];
            [self addGestureRecognizer:self.panGesture];
        }
    }
    else {
        if (self.panGesture != nil) {
            [self removeGestureRecognizer:self.panGesture];
            self.panGesture = nil;
        }
    }
}

- (void)onTap {
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        [engine sendMessage:@{
            @"type": @"gesture_detector",
            @"message": @{
                    @"event": @"onTap",
                    @"target": self.hashCode,
            },
        }];
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer *)sender {
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onLongPress",
                        @"target": self.hashCode,
                },
            }];
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onLongPressStart",
                        @"target": self.hashCode,
                        @"globalX": @([sender locationInView:self.window].x),
                        @"globalY": @([sender locationInView:self.window].y),
                        @"localX": @([sender locationInView:self].x),
                        @"localY": @([sender locationInView:self].y),
                },
            }];
        }
        else if (sender.state == UIGestureRecognizerStateChanged) {
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onLongPressMoveUpdate",
                        @"target": self.hashCode,
                        @"globalX": @([sender locationInView:self.window].x),
                        @"globalY": @([sender locationInView:self.window].y),
                        @"localX": @([sender locationInView:self].x),
                        @"localY": @([sender locationInView:self].y),
                },
            }];
        }
        else if (sender.state == UIGestureRecognizerStateEnded) {
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onLongPressEnd",
                        @"target": self.hashCode,
                        @"globalX": @([sender locationInView:self.window].x),
                        @"globalY": @([sender locationInView:self.window].y),
                        @"localX": @([sender locationInView:self].x),
                        @"localY": @([sender locationInView:self].y),
                },
            }];
        }
    }
}

- (void)onPan:(UIPanGestureRecognizer *)sender {
    MPIOSEngine *engine = self.engine;
    if (engine != nil) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onPanStart",
                        @"target": self.hashCode,
                        @"globalX": @([sender locationInView:self.window].x),
                        @"globalY": @([sender locationInView:self.window].y),
                        @"localX": @([sender locationInView:self].x),
                        @"localY": @([sender locationInView:self].y),
                },
            }];
        }
        else if (sender.state == UIGestureRecognizerStateChanged) {
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onPanUpdate",
                        @"target": self.hashCode,
                        @"globalX": @([sender locationInView:self.window].x),
                        @"globalY": @([sender locationInView:self.window].y),
                        @"localX": @([sender locationInView:self].x),
                        @"localY": @([sender locationInView:self].y),
                },
            }];
        }
        else if (sender.state == UIGestureRecognizerStateEnded) {
            [engine sendMessage:@{
                @"type": @"gesture_detector",
                @"message": @{
                        @"event": @"onPanEnd",
                        @"target": self.hashCode,
                        @"globalX": @([sender locationInView:self.window].x),
                        @"globalY": @([sender locationInView:self.window].y),
                        @"localX": @([sender locationInView:self].x),
                        @"localY": @([sender locationInView:self].y),
                },
            }];
        }
    }
}

@end
