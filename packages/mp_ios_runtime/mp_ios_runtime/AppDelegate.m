//
//  AppDelegate.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//

#import "AppDelegate.h"
#import "MPIOSImage.h"
#import "MPIOSViewController.h"
#import "MPIOSMpkReader.h"
#import "MPIOSPage.h"
#import "MPIOSApp.h"
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
    
//    self.engine = [[MPIOSEngine alloc] initWithDebuggerServerAddr:@"127.0.0.1:9898"];
    NSString *mpkPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"mpk"];
    self.engine = [[MPIOSEngine alloc] initWithMpkData:[NSData dataWithContentsOfFile:mpkPath]];
    self.app = [[MPIOSApp alloc] initWithEngine:self.engine navigationController:navigationController];
    [navigationController.navigationBar setTranslucent:NO];
    [navigationController.view setBackgroundColor:[UIColor whiteColor]];
    [navigationController setViewControllers:@[[self.app createRootViewControllerWithInitialRoute:@"/" initialParams:@{}]]];
    [self.engine start];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
//    NSString *mpkPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"mpk"];
//    self.engine = [[MPIOSEngine alloc] initWithMpkData:[NSData dataWithContentsOfFile:mpkPath]];
//    UINavigationController *navigationController = [[UINavigationController alloc] init];
//    navigationController.view.backgroundColor = [UIColor whiteColor];
//    self.engine.navigator = navigationController;
//    [navigationController setViewControllers:@[
//        [[MPIOSViewController alloc] initWithEngine:self.engine
//                                              route:@"/"
//                                             params:@{
//                                                 @"data": @"中文",
//                                             }],
//    ]];
//    [self.engine start];
//    self.window.rootViewController = navigationController;
//    [self.window makeKeyAndVisible];
    
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.window.rootViewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
//    [self.window makeKeyAndVisible];
//
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.engine = [[MPIOSEngine alloc] initWithDebuggerServerAddr:@"127.0.0.1:9898"];
//    UINavigationController *navigationController = [[UINavigationController alloc] init];
//    navigationController.view.backgroundColor = [UIColor whiteColor];
//    self.engine.navigator = navigationController;
//    [navigationController setViewControllers:@[
//        [[MPIOSViewController alloc] initWithEngine:self.engine
//                                              route:@"/"
//                                             params:@{
//                                                 @"data": @"中文",
//                                             }],
//    ]];
//    [self.engine start];
//    self.window.rootViewController = navigationController;
//    [self.window makeKeyAndVisible];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIViewController *nextViewController = [[MPIOSViewController alloc] initWithEngine:self.engine route:@"/" params:@{}];
//        [navigationController pushViewController:nextViewController animated:YES];
//    });
    return YES;
}

- (void)setupMPImageLoader {
    [[SDImageCodersManager sharedManager] addCoder:[SDImageSVGKCoder sharedCoder]];
    [MPIOSImage setupImageLoader:^(UIImageView * _Nonnull imageView, NSString * _Nonnull url) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                     placeholderImage:nil
                              options:0
                              context:@{SDWebImageContextImageThumbnailPixelSize : @(imageView.bounds.size)}];
    }];
}

@end
