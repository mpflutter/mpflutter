//
//  MPIOSProvider.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2022/1/23.
//  Copyright © 2022 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MPIOSImageProvider, MPIOSDialogProvider, MPIOSUIProvider, MPIOSViewController;

@interface MPIOSProvider : NSObject

@property (nonatomic, strong) MPIOSImageProvider *imageProvider;
@property (nonatomic, strong) MPIOSDialogProvider *dialogProvider;
@property (nonatomic, strong) MPIOSUIProvider *uiProvider;

@end

@interface MPIOSImageProvider : NSObject

- (void)loadImageWithURLString:(NSString *)URLString imageView:(UIImageView *)imageView;
- (void)loadImageWithAssetName:(NSString *)assetName imageView:(UIImageView *)imageView;

@end

typedef void(^MPIOSDialogProviderAlertCompletionBlock)(void);
typedef void(^MPIOSDialogProviderConfirmCompletionBlock)(BOOL);
typedef void(^MPIOSDialogProviderPromptCompletionBlock)(NSString * _Nullable);
typedef void(^MPIOSDialogProviderActionSheetCompletionBlock)(NSInteger);

@interface MPIOSDialogProvider : NSObject

- (void)showAlertWithMessage:(NSString *)message
             completionBlock:(MPIOSDialogProviderAlertCompletionBlock)completionBlock;

- (void)showConfirmWithMessage:(NSString *)message
               completionBlock:(MPIOSDialogProviderConfirmCompletionBlock)completionBlock;

- (void)showPromptWithMessage:(NSString *)message
                 defaultValue:(NSString *)defaultValue
              completionBlock:(MPIOSDialogProviderPromptCompletionBlock)completionBlock;

- (void)showActionSheetWithItems:(NSArray<NSString *> *)items
                 completionBlock:(MPIOSDialogProviderActionSheetCompletionBlock)completionBlock;

- (void)showToastWithIcon:(NSString *)icon
                    title:(NSString *)title
                 duration:(NSNumber *)duration;

- (void)hideToast;

@end

@interface MPIOSUIProvider : NSObject

- (UIView *)loadCircularProgressIndicator;

@end

NS_ASSUME_NONNULL_END
