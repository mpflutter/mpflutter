//
//  MPIOSMPPicker.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/12/9.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSMPPicker.h"
#import "MPIOSViewController.h"
#import "MPIOSComponentUtils.h"

@interface MPIOSMPPicker ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) BOOL firstSetted;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) int column;
@property (nonatomic, strong) NSArray *value;

@end

@implementation MPIOSMPPicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _value = @[@(0), @(0), @(0)];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    if (!self.firstSetted) {
        self.firstSetted = YES;
        if (self.tapGesture == nil) {
            self.tapGesture = [[UITapGestureRecognizer alloc] init];
            [self.tapGesture addTarget:self action:@selector(handleTap)];
            [self addGestureRecognizer:self.tapGesture];
        }
        if ([attributes[@"defaultValue"] isKindOfClass:[NSArray class]]) {
            self.value = attributes[@"defaultValue"];
        }
    }
    if ([attributes[@"items"] isKindOfClass:[NSArray class]]) {
        self.items = attributes[@"items"];
    }
    if ([attributes[@"column"] isKindOfClass:[NSNumber class]]) {
        self.column = [attributes[@"column"] intValue];
    }
}

- (void)handleTap {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          [UIScreen mainScreen].bounds.size.width - 16,
                                                                          240)];
    [picker setDelegate:self];
    [picker setDataSource:self];
    [self.value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [picker selectRow:[obj intValue] inComponent:idx animated:NO];
    }];
    [alertController.view addSubview:picker];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSMutableArray *value = [NSMutableArray array];
            for (int i = 0; i < [self numberOfComponentsInPickerView:picker]; i++) {
                if ([self pickerView:picker numberOfRowsInComponent:i] <= 0) {
                    continue;
                }
                [value addObject:@([picker selectedRowInComponent:i])];
            }
            self.value = value.copy;
            [self invokeMethod:@"callbackResult" params:@{@"value": value}];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.column <= 0) {
        return 1;
    }
    return self.column;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.items == nil) {
        return 0;
    }
    if (component == 0) {
        return self.items.count;
    }
    else if (component == 1 && [self.value[0] intValue] < self.items.count) {
        NSDictionary *selectedItem = self.items[[self.value[0] intValue]];
        if ([selectedItem isKindOfClass:[NSDictionary class]] &&
            [selectedItem[@"subItems"] isKindOfClass:[NSArray class]]) {
            return [selectedItem[@"subItems"] count];
        }
    }
    else if (component == 2) {
        NSArray *secondColumnItems;
        if ([self.value[0] intValue] < self.items.count) {
            NSDictionary *firstColumnSelectedItem = self.items[[self.value[0] intValue]];
            if ([firstColumnSelectedItem isKindOfClass:[NSDictionary class]] &&
                [firstColumnSelectedItem[@"subItems"] isKindOfClass:[NSArray class]]) {
                secondColumnItems = firstColumnSelectedItem[@"subItems"];
            }
        }
        if (secondColumnItems != nil && [self.value[1] intValue] < secondColumnItems.count) {
            NSDictionary *selectedItem = secondColumnItems[[self.value[1] intValue]];
            if ([selectedItem isKindOfClass:[NSDictionary class]] &&
                [selectedItem[@"subItems"] isKindOfClass:[NSArray class]]) {
                return [selectedItem[@"subItems"] count];
            }
        }
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    NSArray *currentItems;
    for (int i = 0; i <= component; i++) {
        if (i == 0) {
            currentItems = self.items;
        }
        else {
            int selectedIndex = [self.value[i - 1] intValue];
            if (selectedIndex < currentItems.count) {
                if ([currentItems[selectedIndex] isKindOfClass:[NSDictionary class]] &&
                    [currentItems[selectedIndex][@"subItems"] isKindOfClass:[NSArray class]]) {
                    currentItems = currentItems[selectedIndex][@"subItems"];
                }
            }
        }
    }
    if (row < currentItems.count && [currentItems[row] isKindOfClass:[NSDictionary class]]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width - 30) / [self numberOfComponentsInPickerView:pickerView], 44)];
        label.text = currentItems[row][@"label"];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 44)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSMutableArray *value = [self.value mutableCopy];
    if (component < value.count) {
        value[component] = @(row);
    }
    for (NSInteger i = component + 1; i < [self numberOfComponentsInPickerView:pickerView]; i++) {
        value[i] = @(0);
    }
    self.value = value.copy;
    [pickerView reloadAllComponents];
    [self.value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [pickerView selectRow:[obj intValue] inComponent:idx animated:NO];
    }];
}

@end
