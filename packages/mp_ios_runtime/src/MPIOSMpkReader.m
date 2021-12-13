//
//  MPIOSMpkReader.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/23.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMpkReader.h"
#import <zlib.h>

@interface MPIOSMpkReader ()

@property (nonatomic, strong) NSDictionary *fileIndex;
@property (nonatomic, strong) NSData *fileDatas;

@end

@implementation MPIOSMpkReader

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        NSData *inflatedData = [self inflateData:data];
        [self decodeFileIndex:inflatedData];
    }
    return self;
}

- (NSData *)inflateData:(NSData *)data {
    if (data.length < 4) {
        return nil;
    }
    NSString *fileHeader = [[data subdataWithRange:NSMakeRange(0, 4)]
                            base64EncodedStringWithOptions:kNilOptions];
    if (![fileHeader isEqualToString:@"AG1waw=="]) {
        return nil;
    }
    NSData *inflatedData = [self zlibInflate:[data subdataWithRange:NSMakeRange(4, data.length - 4)]];
    return inflatedData;
}

- (void)decodeFileIndex:(NSData *)data {
    NSData *fileIndexSizeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int a = 0, b = 0, c = 0, d = 0;
    [fileIndexSizeData getBytes:&a range:NSMakeRange(0, 1)];
    [fileIndexSizeData getBytes:&b range:NSMakeRange(1, 1)];
    [fileIndexSizeData getBytes:&c range:NSMakeRange(2, 1)];
    [fileIndexSizeData getBytes:&d range:NSMakeRange(3, 1)];
    long fileIndexSize = a * 255 * 255 * 255 + b * 255 * 255 + c * 255 + d;
    NSData *fileIndexData = [data subdataWithRange:NSMakeRange(8, fileIndexSize)];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:fileIndexData
                                                             options:kNilOptions
                                                               error:NULL];
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        self.fileIndex = jsonData;
        self.fileDatas = [data subdataWithRange:NSMakeRange(8 + fileIndexSize,
                                                            data.length - (8 + fileIndexSize))];
    }
}

- (NSData *)dataWithFilePath:(NSString *)filePath {
    NSDictionary *index = self.fileIndex[filePath];
    if (index == nil) {
        return nil;
    }
    NSInteger location = [index[@"location"] integerValue];
    NSInteger length = [index[@"length"] integerValue];
    if (location + length <= self.fileDatas.length) {
        return [self.fileDatas subdataWithRange:NSMakeRange(location, length)];
    }
    return nil;
}

- (NSData *)zlibInflate:(NSData *)data
{
    if ([data length] == 0) return data;
    
    unsigned full_length = (unsigned)[data length];
    unsigned half_length = (unsigned)[data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (unsigned)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit (&strm) != Z_OK) return nil;
    
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

@end
