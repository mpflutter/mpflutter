//
//  MPIOSMpkReader.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIOSMpkReader : NSObject

- (instancetype)initWithData:(NSData *)data;

- (NSData *)dataWithFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
