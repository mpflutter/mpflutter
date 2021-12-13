//
//  MPIOSAbsorbPointer.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/11.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSAbsorbPointer.h"

@interface MPIOSAbsorbPointer ()

@property (nonatomic, assign) BOOL absorbing;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation MPIOSAbsorbPointer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tapGesture = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:_tapGesture];
        _panGesture = [[UIPanGestureRecognizer alloc] init];
        [self addGestureRecognizer:_panGesture];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSNumber *absorbing = attributes[@"absorbing"];
    if ([absorbing isKindOfClass:[NSNumber class]] && [absorbing boolValue]) {
        self.absorbing = YES;
        [self.tapGesture setEnabled:YES];
        [self.panGesture setEnabled:YES];
    }
    else {
        self.absorbing = NO;
        [self.tapGesture setEnabled:NO];
        [self.panGesture setEnabled:NO];
    }
}

@end
