//
//  MPSampleChannels.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/27.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPSampleChannels.h"

@implementation MPTemplateMethodChannel

- (void)onMethodCall:(NSString *)method params:(id)params result:(MPIOSMethodChannelResult)result {
    if ([method isEqualToString:@"getDeviceName"]) {
        [self invokeMethod:@"getCallerName" params:@{} result:^(id  _Nullable caller) {
            result([NSString stringWithFormat:@"%@ on iOS", caller]);
        }];
    }
    else {
        result(MPIOSMethodChannelNOTImplemented);
    }
}

@end

@interface MPTemplateEventChannel ()

@property (nonatomic, strong) NSTimer *intervalHandler;

@end

@implementation MPTemplateEventChannel

- (void)onListen:(id)params eventSink:(MPIOSEventChannelEventSink)eventSink {
    self.intervalHandler = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        eventSink([[NSDate date] description]);
    }];
}

- (void)onCancel:(id)params {
    if (self.intervalHandler != nil) {
        [self.intervalHandler invalidate];
        self.intervalHandler = nil;
    }
}

@end

@interface TemplateFooView ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation TemplateFooView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        self.userInteractionEnabled = YES;
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)setChildren:(NSArray *)children {}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentLabel.frame = self.bounds;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *text = attributes[@"text"];
    if ([text isKindOfClass:[NSString class]]) {
        self.contentLabel.text = text;
    }
}

- (void)onTap {
    [self invokeMethod:@"xxx" params:@{@"yyy": @"kkk"}];
}

@end
