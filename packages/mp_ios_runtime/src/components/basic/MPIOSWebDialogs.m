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
                [self hideToast];
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
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"好的"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
            },
        }];
    }];
    [alertController addAction:action];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

+ (void)confirm:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSString *alertMessage = message[@"params"][@"message"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![alertMessage isKindOfClass:[NSString class]]) {
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction
                             actionWithTitle:@"确认"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * _Nonnull action) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": @(YES),
            },
        }];
    }];
    [alertController addAction:actionConfirm];
    UIAlertAction *actionCancel = [UIAlertAction
                             actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * _Nonnull action) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": @(NO),
            },
        }];
    }];
    [alertController addAction:actionCancel];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

+ (void)prompt:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSString *alertMessage = message[@"params"][@"message"];
    NSString *defaultValue = message[@"params"][@"defaultValue"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![alertMessage isKindOfClass:[NSString class]]) {
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if ([defaultValue isKindOfClass:[NSString class]]) {
            textField.text = defaultValue;
        }
    }];
    UIAlertAction *actionConfirm = [UIAlertAction
                             actionWithTitle:@"确认"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": alertController.textFields[0].text ?: [NSNull null],
            },
        }];
    }];
    [alertController addAction:actionConfirm];
    UIAlertAction *actionCancel = [UIAlertAction
                             actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * _Nonnull action) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": [NSNull null],
            },
        }];
    }];
    [alertController addAction:actionCancel];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

+ (void)actionSheet:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSString *callbackId = message[@"id"];
    NSArray *items = message[@"params"][@"items"];
    if (![callbackId isKindOfClass:[NSString class]] ||
        ![items isKindOfClass:[NSArray class]]) {
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            UIAlertAction *action = [UIAlertAction
                                     actionWithTitle:obj
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * _Nonnull action) {
                [engine sendMessage:@{
                    @"type": @"action",
                    @"message": @{
                            @"event": @"callback",
                            @"id": callbackId,
                            @"data": @(idx),
                    },
                }];
            }];
            [alertController addAction:action];
        }
    }];
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * _Nonnull action) {
        [engine sendMessage:@{
            @"type": @"action",
            @"message": @{
                    @"event": @"callback",
                    @"id": callbackId,
                    @"data": [NSNull null],
            },
        }];
    }];
    [alertController addAction:action];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

static MBProgressHUD *activeHUD;

+ (void)showToast:(NSDictionary *)message engine:(nonnull MPIOSEngine *)engine {
    NSDictionary *params = message[@"params"];
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (activeHUD != nil) {
        [activeHUD hideAnimated:YES];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    activeHUD = hud;
    hud.square = YES;
    [hud.bezelView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    [hud.bezelView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    if ([params[@"icon"] isKindOfClass:[NSString class]]) {
        if ([@"ToastIcon.success" isEqualToString:params[@"icon"]]) {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [self toastIconSuccess];
        }
        else if ([@"ToastIcon.error" isEqualToString:params[@"icon"]]) {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [self toastIconError];
        }
        else if ([@"ToastIcon.loading" isEqualToString:params[@"icon"]]) {
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.contentColor = [UIColor whiteColor];
        }
        else if ([@"ToastIcon.none" isEqualToString:params[@"icon"]]) {
            hud.mode = MBProgressHUDModeText;
            hud.square = NO;
        }
    }
    if ([params[@"title"] isKindOfClass:[NSString class]]) {
        [hud.label setText:params[@"title"]];
        [hud.label setTextColor:[UIColor whiteColor]];
    }
    if ([params[@"duration"] isKindOfClass:[NSNumber class]]) {
        NSTimeInterval duration = [params[@"duration"] floatValue] / 1000.0;
        [hud hideAnimated:YES afterDelay:duration];
    }
}

+ (UIView *)toastIconSuccess {
    MPIOSMPIcon *view = [[MPIOSMPIcon alloc] init];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:44]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:44]];
    [view setAttributes:@{
        @"iconUrl": @"https://cdn.jsdelivr.net/gh/google/material-design-icons@master/src/action/done/materialicons/24px.svg",
        @"color": @"4294967295",
    }];
    return view;
}

+ (UIView *)toastIconError {
    MPIOSMPIcon *view = [[MPIOSMPIcon alloc] init];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:44]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:44]];
    [view setAttributes:@{
        @"iconUrl": @"https://cdn.jsdelivr.net/gh/google/material-design-icons@master/src/alert/error/materialicons/24px.svg",
        @"color": @"4294967295",
    }];
    return view;
}

+ (void)hideToast {
    if (activeHUD != nil) {
        [activeHUD hideAnimated:YES];
    }
}

@end
