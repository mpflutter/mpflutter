//
//  MPIOSAncestorView.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/10/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSAncestorView.h"
#import "MPIOSComponentView.h"

@interface MPIOSAncestorView ()

@property (nonatomic, strong) NSDictionary *constraints;

@end

@implementation MPIOSAncestorView

- (void)setConstraints:(NSDictionary *)constraints {
    if (![constraints isKindOfClass:[NSDictionary class]]) return;
    _constraints = constraints;
    [self.target updateLayout];
}

- (void)setAttributes:(NSDictionary *)attributes {
    
}

@end
