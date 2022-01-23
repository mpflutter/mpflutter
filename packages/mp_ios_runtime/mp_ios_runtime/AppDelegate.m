//
//  AppDelegate.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//

#import "AppDelegate.h"
#import "MPIOSRuntime.h"
#import "MPSampleProvider.h"

@interface AppDelegate ()

@property (nonatomic, strong) MPIOSEngine *engine;
@property (nonatomic, strong) MPIOSApp *app;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    
//    self.engine = [[MPIOSEngine alloc] initWithDebuggerServerAddr:@"127.0.0.1:9898"];
    NSString *mpkPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"mpk"];
    self.engine = [[MPIOSEngine alloc] initWithMpkData:[NSData dataWithContentsOfFile:mpkPath]];
    self.engine.provider.imageProvider = [[MPSampleImageProvider alloc] init];
    self.app = [[MPIOSApp alloc] initWithEngine:self.engine navigationController:navigationController];
    [navigationController.navigationBar setTranslucent:NO];
    [navigationController.view setBackgroundColor:[UIColor whiteColor]];
    [navigationController setViewControllers:@[[self.app createRootViewControllerWithInitialRoute:@"/" initialParams:@{}]]];
    [self.engine start];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
