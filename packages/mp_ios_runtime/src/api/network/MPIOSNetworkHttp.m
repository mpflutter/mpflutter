//
//  MPIOSNetworkHttp.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/24.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSNetworkHttp.h"
#import "MPIOSEngine.h"
#import "MPIOSProvider.h"

@protocol MPIOSNetworkHttpTaskJSExport <JSExport>

- (void)abort;

@end

@interface MPIOSNetworkHttpTask : NSObject<MPIOSNetworkHttpTaskJSExport>

@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation MPIOSNetworkHttpTask

- (void)abort {
    [self.task cancel];
}

@end

@implementation MPIOSNetworkHttp

+ (void)setupWithJSContext:(JSContext *)context engine:(nonnull MPIOSEngine *)engine {
    __weak MPIOSEngine *weakEngine = engine;
    context.globalObject[@"wx"][@"request"] = ^(JSValue *options){
        return [MPIOSNetworkHttp request:options engine:weakEngine];
    };
}

+ (MPIOSNetworkHttpTask *)request:(JSValue *)options engine:(nonnull MPIOSEngine *)engine {
    __strong MPIOSEngine *strongEngine = engine;
    if (strongEngine == nil) {
        return nil;
    }
    if (!options.isObject) {
        return nil;
    }
    NSString *url = [options[@"url"] isString] ? [options[@"url"] toString] : nil;
    if (url == nil) {
        return nil;
    }
    NSString *method = [options[@"method"] isString] ? [options[@"method"] toString] : nil;
    NSDictionary *headers = [options[@"headers"] isObject] ? [options[@"headers"] toDictionary] : nil;
    NSString *data = [options[@"data"] isString] ? [options[@"data"] toString] : nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (method != nil) {
        [request setHTTPMethod:method];
    }
    if (headers != nil) {
        [request setAllHTTPHeaderFields:headers];
    }
    if (data != nil) {
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    JSValue *success = [options[@"success"] isObject] ? options[@"success"] : nil;
    JSValue *fail = [options[@"fail"] isObject] ? options[@"fail"] : nil;
    NSURLSessionTask *task = [strongEngine.provider.dataProvider createURLSessionTask:request.copy completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil || error) {
            [fail callWithArguments:@[error.localizedDescription ?: @""]];
        }
        else {
            NSInteger statusCode = 200;
            NSDictionary *header = @{};
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                statusCode = [(NSHTTPURLResponse *)response statusCode];
                header = [(NSHTTPURLResponse *)response allHeaderFields];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [success callWithArguments:@[@{
                                                 @"data": [data base64EncodedStringWithOptions:kNilOptions],
                                                 @"header": header ?: @{},
                                                 @"statusCode": @(statusCode),
                }]];
            });
        }
    }];
    [task resume];
    MPIOSNetworkHttpTask *mpTask = [[MPIOSNetworkHttpTask alloc] init];
    mpTask.task = task;
    return mpTask;
}

@end
