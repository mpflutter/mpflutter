//
//  MPIOSMPDatePicker.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/12/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPDatePicker.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentUtils.h"

@interface MPIOSMPDatePicker ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation MPIOSMPDatePicker

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if (self.tapGesture == nil) {
        self.tapGesture = [[UITapGestureRecognizer alloc] init];
        [self.tapGesture addTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:self.tapGesture];
    }
}

- (void)handleTap {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    if (@available(iOS 13.4, *)) {
        picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [picker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]];
    [picker setDatePickerMode:UIDatePickerModeDate];
    if ([self.attributes[@"start"] isKindOfClass:[NSString class]]) {
        picker.minimumDate = [MPIOSComponentUtils dateFromString:self.attributes[@"start"]];
    }
    if ([self.attributes[@"end"] isKindOfClass:[NSString class]]) {
        picker.maximumDate = [MPIOSComponentUtils dateFromString:self.attributes[@"end"]];
    }
    if ([self.attributes[@"defaultValue"] isKindOfClass:[NSString class]]) {
        picker.date = [MPIOSComponentUtils dateFromString:self.attributes[@"defaultValue"]];
    }
    picker.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 20.0, 0.0);
    [alertController.view addSubview:picker];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSMutableArray *arr = [[[dateFormatter stringFromDate:picker.date]
                                    componentsSeparatedByString:@"-"] mutableCopy];
            [arr setObject:@([arr[0] intValue]) atIndexedSubscript:0];
            [arr setObject:@([arr[1] intValue]) atIndexedSubscript:1];
            [arr setObject:@([arr[2] intValue]) atIndexedSubscript:2];
            [self invokeMethod:@"callbackResult" params:@{@"value": arr}];
        }];
        action;
    })];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
    popoverController.sourceView = [self getViewController].view;
    popoverController.sourceRect = [[self getViewController].view bounds];
    [[self getViewController] presentViewController:alertController
                                           animated:YES completion:nil];
}

@end
