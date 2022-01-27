//
//  MPIOSMPVideoView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPVideoView.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MPIOSMPVideoView ()

@property (nonatomic, strong) AVPlayerViewController *contentViewController;
@property (nonatomic, strong) NSString *currentUrl;

@end

@implementation MPIOSMPVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentViewController = [[AVPlayerViewController alloc] init];
        _contentViewController.showsPlaybackControls = YES;
        [self addSubview:_contentViewController.view];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentViewController.view.frame = self.bounds;
}

- (void)setChildren:(NSArray *)children {}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSString *url = attributes[@"url"];
    if ([url isKindOfClass:[NSString class]]) {
        if (self.currentUrl == nil || ![self.currentUrl isEqualToString:url]) {
            self.currentUrl = url;
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
            [self.contentViewController setPlayer:player];
        }
    }
    else {
        [self.contentViewController setPlayer:nil];
    }
    NSNumber *controls = attributes[@"controls"];
    if ([controls isKindOfClass:[NSNumber class]] && [controls boolValue]) {
        [self.contentViewController setShowsPlaybackControls:YES];
    }
    else {
        [self.contentViewController setShowsPlaybackControls:NO];
    }
    NSNumber *autoplay = attributes[@"autoplay"];
    if ([autoplay isKindOfClass:[NSNumber class]] && [autoplay boolValue]) {
        [[self.contentViewController player] play];
    }
    NSNumber *muted = attributes[@"muted"];
    if ([muted isKindOfClass:[NSNumber class]] && [muted boolValue]) {
        self.contentViewController.player.muted = YES;
    }
    else {
        self.contentViewController.player.muted = NO;
    }
}

- (void)onMethodCall:(NSString *)method
              params:(NSDictionary *)params
      resultCallback:(MPIOSPlatformViewCallback)resultCallback {
    if ([@"play" isEqualToString:method]) {
        [[self.contentViewController player] play];
    }
    else if ([@"pause" isEqualToString:method]) {
        [[self.contentViewController player] pause];
    }
    else if ([@"setVolume" isEqualToString:method]) {
    }
    else if ([@"volumeUp" isEqualToString:method]) {
    }
    else if ([@"volumeDown" isEqualToString:method]) {
    }
    else if ([@"setMuted" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *muted = params[@"muted"];
        [[self.contentViewController player] setMuted:muted.boolValue];
    }
    else if ([@"fullscreen" isEqualToString:method]) {
        [[self.contentViewController player] pause];
    }
    else if ([@"setPlaybackRate" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *playbackRate = params[@"playbackRate"];
        if ([playbackRate isKindOfClass:[NSNumber class]]) {
            [[self.contentViewController player] setRate:playbackRate.floatValue];
        }
    }
    else if ([@"seekTo" isEqualToString:method] && [params isKindOfClass:[NSDictionary class]]) {
        NSNumber *seconds = params[@"seekTo"];
        if ([seconds isKindOfClass:[NSNumber class]]) {
            [[self.contentViewController player] seekToTime:CMTimeMake(seconds.intValue, 1)
                                            toleranceBefore:CMTimeMake(0, 1)
                                             toleranceAfter:CMTimeMake(0, 1)];
        }
    }
    else if ([@"getCurrentTime" isEqualToString:method]) {
        CMTime time = [[self.contentViewController player] currentTime];
        resultCallback(@((float)time.value / (float)time.timescale));
    }
}

@end
