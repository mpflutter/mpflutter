//
//  AppDelegate.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//

#import "AppDelegate.h"
#import "MPIOSRuntime.h"
#import "MPSampleChannels.h"

@interface AppDelegate ()

@property (nonatomic, strong) MPIOSApplet *applet;
@property (nonatomic, strong) MPIOSCardlet *cardlet;

@end

@implementation AppDelegate

+ (void)load {
    [MPIOSPluginRegister registerChannel:@"com.mpflutter.templateMethodChannel"
                                   clazz:[MPTemplateMethodChannel class]];
    [MPIOSPluginRegister registerChannel:@"com.mpflutter.templateEventChannel"
                                   clazz:[MPTemplateEventChannel class]];
    [MPIOSPluginRegister registerPlatformView:@"com.mpflutter.templateFooView"
                                        clazz:[TemplateFooView class]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController.navigationBar setTranslucent:NO];
    [navigationController.view setBackgroundColor:[UIColor whiteColor]];

    MPIOSEngine *engine = [[MPIOSEngine alloc] initWithDebuggerServerAddr:@"127.0.0.1:9898"];
//    NSString *mpkPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"mpk"];
//    self.engine = [[MPIOSEngine alloc] initWithMpkData:[NSData dataWithContentsOfFile:mpkPath]];
    self.applet = [MPIOSApplet createAppletWithEngine:engine initialRoute:@"/" initialParams:@{}];
    [self.applet attachToNavigationController:navigationController asRootViewController:YES];
    [engine start];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    UIViewController *homeViewController = [[UIViewController alloc] init];
//    homeViewController.view.backgroundColor = [UIColor blackColor];
//    UIView *pView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    pView.clipsToBounds = YES;
//    pView.backgroundColor = [UIColor yellowColor];
//    [homeViewController.view addSubview:pView];
//
//    MPIOSEngine *engine = [[MPIOSEngine alloc] initWithDebuggerServerAddr:@"127.0.0.1:9898"];
////    NSString *mpkPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"mpk"];
////    self.engine = [[MPIOSEngine alloc] initWithMpkData:[NSData dataWithContentsOfFile:mpkPath]];
//    self.cardlet = [MPIOSCardlet createCardletWithEngine:engine initialRoute:@"/" initialParams:@{}];
//    [self.cardlet attachToView:pView];
//    [engine start];
//
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.window.rootViewController = homeViewController;
//    [self.window makeKeyAndVisible];
//    return YES;
//}

@end
