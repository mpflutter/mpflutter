//
//  MPIOSMPSwitch.m
//  mp_ios_runtime
//
//  Created by ydt on 10.12.21.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPSwitch.h"

@interface MPIOSMPSwitch ()

@property (nonatomic, strong) UISwitch *contentView;
@property (nonatomic, assign) BOOL firstSetted;

@end

@implementation MPIOSMPSwitch

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentView = [[UISwitch alloc] init];
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
            self.contentView.on = [attributes[@"defaultValue"] boolValue];
        }
    }
}

- (void)handleChange {
    [self invokeMethod:@"onValueChanged"
                params:@{
                    @"value": @(self.contentView.on),
                }];
}

- (void)onMethodCall:(NSString *)method
              params:(NSDictionary *)params
      resultCallback:(MPIOSPlatformViewCallback)resultCallback {
    if ([@"setValue" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *value = params[@"value"];
        if ([value isKindOfClass:[NSNumber class]]) {
            [self.contentView setOn:value.boolValue animated:YES];
        }
    }
}

@end
