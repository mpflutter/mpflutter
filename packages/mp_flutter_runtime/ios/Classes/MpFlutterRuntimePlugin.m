#import "MpFlutterRuntimePlugin.h"
#import "MPFLTJSRuntime.h"

@implementation MpFlutterRuntimePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [MPFLTJSRuntime registerWithRegistrar:registrar];
}

@end
