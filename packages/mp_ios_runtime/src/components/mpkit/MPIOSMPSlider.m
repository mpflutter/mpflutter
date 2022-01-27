//
//  MPIOSMPSlider.m
//  mp_ios_runtime
//
//  Created by ydt on 10.12.21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPSlider.h"

@interface MPIOSMPSlider ()

@property (nonatomic, strong) UISlider *contentView;
@property (nonatomic, assign) BOOL firstSetted;
@property (nonatomic, assign) float stepValue;

@end

@implementation MPIOSMPSlider

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentView = [[UISlider alloc] init];
        _stepValue = -1.0;
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
    if (!self.firstSetted) {
        self.firstSetted = YES;
        [self.contentView addTarget:self
                             action:@selector(handleChange)
                   forControlEvents:UIControlEventValueChanged];
        if ([attributes[@"defaultValue"] isKindOfClass:[NSNumber class]]) {
            self.contentView.value = [attributes[@"defaultValue"] floatValue];
        }
    }
    if ([attributes[@"min"] isKindOfClass:[NSNumber class]]) {
        self.contentView.minimumValue = [attributes[@"min"] floatValue];
    }
    if ([attributes[@"max"] isKindOfClass:[NSNumber class]]) {
        self.contentView.maximumValue = [attributes[@"max"] floatValue];
    }
    if ([attributes[@"step"] isKindOfClass:[NSNumber class]]) {
        self.stepValue = [attributes[@"step"] floatValue];
    }
}

- (void)handleChange {
    if (self.stepValue > 0.0) {
        float newStep = roundf((self.contentView.value) / self.stepValue);
        self.contentView.value = newStep * self.stepValue;
    }
    [self invokeMethod:@"onValueChanged"
                params:@{
                    @"value": @(self.contentView.value),
                }];
}

- (void)onMethodCall:(NSString *)method
              params:(NSDictionary *)params
      resultCallback:(MPIOSPlatformViewCallback)resultCallback {
    if ([@"setValue" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *value = params[@"value"];
        if ([value isKindOfClass:[NSNumber class]]) {
            self.contentView.value = value.floatValue;
        }
    }
}

@end
