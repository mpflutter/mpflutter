//
//  MPIOSWebDialogs.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/16.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSWebDialogs.h"
#import "MPIOSEngine+Private.h"
#import "MPIOSMPIcon.h"
#import "MPIOSProvider.h"
#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@implementation MPIOSWebDialogs

+ (void)didReceivedWebDialogsMessage:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    if ([message[@"params"] isKindOfClass:[NSDictionary class]]) {
        if ([message[@"params"][@"dialogType"] isKindOfClass:[NSString class]]) {
            NSString *dialogType = message[@"params"][@"dialogType"];
            if ([dialogType isEqualToString:@"alert"]) {
                [self alert:message engine:engine];
            }
            else if ([dialogType isEqualToString:@"confirm"]) {
                [self confirm:message engine:engine];
            }
            else if ([dialogType isEqualToString:@"prompt"]) {
                [self prompt:message engine:engine];
            }
            else if ([dialogType isEqualToString:@"actionSheet"]) {
                [self actionSheet:message engine:engine];
            }
            else if ([dialogType isEqualToString:@"showToast"]) {
                [self showToast:message engine:engine];
            }
            else if ([dialogType isEqualToString:@"hideToast"]) {
                [self hideToast:engine];
            }
        }
    }
}

+ (void)alert:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSString *alertMessage = message[@"params"][@"message"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![alertMessage isKindOfClass:[NSString class]]) {
        return;
    }
    [engine.provider.dialogProvider showAlertWithMessage:alertMessage
                                         completionBlock:^{
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
            },
        }];
    }];
}

+ (void)confirm:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSString *alertMessage = message[@"params"][@"message"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![alertMessage isKindOfClass:[NSString class]]) {
        return;
    }
    [engine.provider.dialogProvider showConfirmWithMessage:alertMessage
                                          completionBlock:^(BOOL ret) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": @(ret),
            },
        }];
    }];
}

+ (void)prompt:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSString *alertMessage = message[@"params"][@"message"];
    NSString *defaultValue = message[@"params"][@"defaultValue"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![alertMessage isKindOfClass:[NSString class]]) {
        return;
    }
    [engine.provider.dialogProvider showPromptWithMessage:alertMessage
                                             defaultValue:defaultValue
                                          completionBlock:^(NSString * _Nonnull result) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": result ?: [NSNull null],
            },
        }];
    }];
}

+ (void)actionSheet:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSArray *items = message[@"params"][@"items"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![items isKindOfClass:[NSArray class]]) {
        return;
    }
    [engine.provider.dialogProvider showActionSheetWithItems:items
                                             completionBlock:^(NSInteger idx) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": idx >= 0 ? @(idx) : [NSNull null],
            },
        }];
    }];
}

+ (void)showToast:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSDictionary *params = message[@"params"];
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [engine.provider.dialogProvider showToastWithIcon:params[@"icon"]
                                                title:params[@"title"]
                                             duration:params[@"duration"]];
}

+ (void)hideToast:(nonnull MPIOSEngine *)engine {
    [engine.provider.dialogProvider hideToast];
}

@end
