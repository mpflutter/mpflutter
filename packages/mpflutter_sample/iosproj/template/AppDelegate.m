//
//  AppDelegate.m
//  template
//
//  Created by PonyCui on 2021/7/26.
//

#import "AppDelegate.h"
#import <MPIOSRuntime/MPIOSRuntime.h>
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageSVGKitPlugin/SDWebImageSVGKitPlugin.h>

@interface AppDelegate ()

@property (nonatomic, strong) MPIOSEngine *engine;
@property (nonatomic, strong) MPIOSApp *app;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupMPImageLoader];
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController.view setBackgroundColor:[UIColor whiteColor]];
#ifdef DEBUG
    BOOL dev = YES;
#else
    BOOL dev = NO;
#endif
    if (dev) {
        self.engine = [[MPIOSEngine alloc] initWithDebuggerServerAddr:@"127.0.0.1:9898"];
    }
    else {
        NSString *mpkPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"mpk"];
        NSData *mpkData = [NSData dataWithContentsOfFile:mpkPath];
        self.engine = [[MPIOSEngine alloc] initWithMpkData:mpkData];
    }
    self.app = [[MPIOSApp alloc] initWithEngine:self.engine navigationController:navigationController];
    [navigationController setViewControllers:@[[self.app createRootViewControllerWithInitialRoute:@"/" initialParams:@{}]]];
    [self.engine start];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupMPImageLoader {
    [[SDImageCodersManager sharedManager] addCoder:[SDImageSVGKCoder sharedCoder]];
    [MPIOSRuntime setupImageLoader:^(UIImageView * _Nonnull imageView, NSString * _Nonnull url) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                     placeholderImage:nil
                              options:0
                              context:@{SDWebImageContextImageThumbnailPixelSize : @(imageView.bounds.size)}];
    }];
}

@end
