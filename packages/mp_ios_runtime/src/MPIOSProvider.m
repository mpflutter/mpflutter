//
//  MPIOSProvider.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/23.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import "MPIOSProvider.h"
#import "MPIOSMPIcon.h"
#import "MPIOSViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageSVGKitPlugin/SDWebImageSVGKitPlugin.h>
#import <MBProgressHUD/MBProgressHUD.h>

@implementation MPIOSProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageProvider = [[MPIOSImageProvider alloc] init];
        _dialogProvider = [[MPIOSDialogProvider alloc] init];
        _uiProvider = [[MPIOSUIProvider alloc] init];
        _dataProvider = [[MPIOSDataProvider alloc] init];
        _navigatorProvider = [[MPIOSNavigatorProvider alloc] init];
    }
    return self;
}

@end

@implementation MPIOSImageProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[SDImageCodersManager sharedManager] addCoder:[SDImageSVGKCoder sharedCoder]];
    }
    return self;
}

- (void)loadImageWithURLString:(NSString *)URLString imageView:(UIImageView *)imageView {
    [imageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                 placeholderImage:nil
                          options:0
                          context:@{SDWebImageContextImageThumbnailPixelSize : @(imageView.bounds.size)}];
}

- (void)loadImageWithAssetName:(NSString *)assetName imageView:(UIImageView *)imageView {
    [imageView setImage:[UIImage imageNamed:assetName]];
}

@end

@implementation MPIOSDialogProvider

- (void)showAlertWithMessage:(NSString *)message
             completionBlock:(MPIOSDialogProviderAlertCompletionBlock)completionBlock {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"好的"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action) {
        completionBlock();
    }];
    [alertController addAction:action];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

- (void)showConfirmWithMessage:(NSString *)message
               completionBlock:(MPIOSDialogProviderConfirmCompletionBlock)completionBlock {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction
                             actionWithTitle:@"确认"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * _Nonnull action) {
        completionBlock(YES);
    }];
    [alertController addAction:actionConfirm];
    UIAlertAction *actionCancel = [UIAlertAction
                             actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * _Nonnull action) {
        completionBlock(NO);
    }];
    [alertController addAction:actionCancel];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

- (void)showPromptWithMessage:(NSString *)message
                 defaultValue:(NSString *)defaultValue
              completionBlock:(MPIOSDialogProviderPromptCompletionBlock)completionBlock {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:message
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
        completionBlock(alertController.textFields[0].text);
    }];
    [alertController addAction:actionConfirm];
    UIAlertAction *actionCancel = [UIAlertAction
                             actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * _Nonnull action) {
        completionBlock(nil);
    }];
    [alertController addAction:actionCancel];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

- (void)showActionSheetWithItems:(NSArray<NSString *> *)items
                 completionBlock:(MPIOSDialogProviderActionSheetCompletionBlock)completionBlock {
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
                completionBlock(idx);
            }];
            [alertController addAction:action];
        }
    }];
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * _Nonnull action) {
        completionBlock(-1);
    }];
    [alertController addAction:action];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:alertController
     animated:YES
     completion:nil];
}

static MBProgressHUD *activeHUD;

- (void)showToastWithIcon:(NSString *)icon
                    title:(NSString *)title
                 duration:(NSNumber *)duration {
    if (activeHUD != nil) {
        [activeHUD hideAnimated:YES];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    activeHUD = hud;
    hud.square = YES;
    [hud.bezelView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    [hud.bezelView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    if ([icon isKindOfClass:[NSString class]]) {
        if ([@"ToastIcon.success" isEqualToString:icon]) {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [self toastIconSuccess];
        }
        else if ([@"ToastIcon.error" isEqualToString:icon]) {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [self toastIconError];
        }
        else if ([@"ToastIcon.loading" isEqualToString:icon]) {
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.contentColor = [UIColor whiteColor];
        }
        else if ([@"ToastIcon.none" isEqualToString:icon]) {
            hud.mode = MBProgressHUDModeText;
            hud.square = NO;
        }
    }
    if ([title isKindOfClass:[NSString class]]) {
        [hud.label setText:title];
        [hud.label setTextColor:[UIColor whiteColor]];
    }
    if ([duration isKindOfClass:[NSNumber class]]) {
        NSTimeInterval hideDuration = [duration floatValue] / 1000.0;
        [hud hideAnimated:YES afterDelay:hideDuration];
    }
}

- (UIView *)toastIconSuccess {
    MPIOSMPIcon *view = [[MPIOSMPIcon alloc] init];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:44]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:44]];
    [view setAttributes:@{
        @"iconUrl": @"https://dist.mpflutter.com/material-design-icons/src/action/done/materialicons/24px.svg",
        @"color": @"4294967295",
    }];
    return view;
}

- (UIView *)toastIconError {
    MPIOSMPIcon *view = [[MPIOSMPIcon alloc] init];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:44]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:44]];
    [view setAttributes:@{
        @"iconUrl": @"https://dist.mpflutter.com/material-design-icons/src/alert/error/materialicons/24px.svg",
        @"color": @"4294967295",
    }];
    return view;
}

- (void)hideToast {
    if (activeHUD != nil) {
        [activeHUD hideAnimated:YES];
    }
}

@end

@implementation MPIOSUIProvider

- (UIView *)createCircularProgressIndicator {
    return [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

@end

@implementation MPIOSDataProvider

- (NSURLSessionTask *)createURLSessionTask:(NSURLRequest *)request
                         completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    return [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
}

- (NSUserDefaults *)createUserDefaults {
    return [NSUserDefaults standardUserDefaults];
}

@end

@implementation MPIOSNavigatorProvider

- (void)handlePushViewController:(UIViewController *)nextViewController {
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (void)handleReplaceViewController:(UIViewController *)nextViewController {
    UINavigationController *navigationController = self.navigationController;
    if (navigationController != nil) {
        NSMutableArray *viewControllers = navigationController.viewControllers.mutableCopy;
        [viewControllers removeLastObject];
        [viewControllers addObject:nextViewController];
        [navigationController setViewControllers:viewControllers.copy];
    }
}

- (void)handlePop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRestart {
    if (self.navigationController != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MPIOSViewController *firstViewController = self.navigationController.viewControllers.firstObject;
            if ([firstViewController isKindOfClass:[MPIOSViewController class]]) {
                [self.navigationController setViewControllers:@[
                    [firstViewController copy]
                ]];
            }
        });
    }
    else if (self.onRestart != nil) {
        self.onRestart();
    }
}

@end
