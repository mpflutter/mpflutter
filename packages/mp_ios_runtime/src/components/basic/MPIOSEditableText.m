//
//  MPIOSEditableText.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/18.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSEditableText.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSEngine+Private.h"

@interface MPIOSEditableText ()<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL autoFocus;
@property (nonatomic, strong) NSDictionary *contentAttributes;

@end

@implementation MPIOSEditableText

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView) {
        return;
    }
    if (_contentView != nil) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    if (_contentView != nil) {
        [self addSubview:_contentView];
    }
}

- (void)setChildren:(NSArray *)children {}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSNumber *maxLines = attributes[@"maxLines"];
    if ([maxLines isKindOfClass:[NSNumber class]] && maxLines.integerValue > 1) {
        if (![self.contentView isKindOfClass:[UITextView class]]) {
            self.contentView = [[UITextView alloc] init];
            self.contentView.backgroundColor = [UIColor clearColor];
            [(UITextView *)self.contentView setDelegate:self];
        }
    }
    else {
        if (![self.contentView isKindOfClass:[UITextField class]]) {
            self.contentView = [[UITextField alloc] init];
            [(UITextField *)self.contentView setDelegate:self];
            [(UITextField *)self.contentView setReturnKeyType:UIReturnKeyDone];
        }
    }
    [self setTextStyle:attributes[@"style"]];
    NSNumber *readOnly = attributes[@"readOnly"];
    if ([readOnly isKindOfClass:[NSNumber class]] && [readOnly boolValue]) {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setEnabled:NO];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setEditable:NO];
        }
    }
    else {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setEnabled:YES];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setEditable:YES];
        }
    }
    NSNumber *obscureText = attributes[@"obscureText"];
    if ([obscureText isKindOfClass:[NSNumber class]] && [obscureText boolValue]) {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setSecureTextEntry:YES];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setSecureTextEntry:YES];
        }
    }
    else {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setSecureTextEntry:NO];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setSecureTextEntry:NO];
        }
    }
    NSString *keyboardType = attributes[@"keyboardType"];
    if ([keyboardType isKindOfClass:[NSString class]]) {
        BOOL isNumber = [keyboardType containsString:@"TextInputType.number"];
        if (isNumber) {
            if ([self.contentView isKindOfClass:[UITextField class]]) {
                [(UITextField *)self.contentView setKeyboardType:UIKeyboardTypeNumberPad];
            }
            else if ([self.contentView isKindOfClass:[UITextView class]]) {
                [(UITextView *)self.contentView setKeyboardType:UIKeyboardTypeNumberPad];
            }
        }
        else {
            if ([self.contentView isKindOfClass:[UITextField class]]) {
                [(UITextField *)self.contentView setKeyboardType:UIKeyboardTypeDefault];
            }
            else if ([self.contentView isKindOfClass:[UITextView class]]) {
                [(UITextView *)self.contentView setKeyboardType:UIKeyboardTypeDefault];
            }
        }
    }
    else {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setKeyboardType:UIKeyboardTypeDefault];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setKeyboardType:UIKeyboardTypeDefault];
        }
    }
    NSNumber *autofocus = attributes[@"autofocus"];
    self.autoFocus = [autofocus isKindOfClass:[NSNumber class]] && [autofocus boolValue];
    NSNumber *autoCorrect = attributes[@"autoCorrect"];
    if ([autoCorrect isKindOfClass:[NSNumber class]] && [autoCorrect boolValue]) {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setAutocorrectionType:UITextAutocorrectionTypeYes];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setAutocorrectionType:UITextAutocorrectionTypeYes];
        }
    }
    else {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setAutocorrectionType:UITextAutocorrectionTypeNo];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setAutocorrectionType:UITextAutocorrectionTypeNo];
        }
    }
    NSString *placeholder = attributes[@"placeholder"];
    if ([placeholder isKindOfClass:[NSString class]]) {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setPlaceholder:placeholder];
        }
    }
    else {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setPlaceholder:nil];
        }
    }
    NSString *value = attributes[@"value"];
    if ([value isKindOfClass:[NSString class]]) {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView setText:value];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView setText:value];
        }
    }
    [self layoutSubviews];
}

- (void)setTextStyle:(NSDictionary *)style {
    if (![style isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    NSString *fontFamily = style[@"fontFamily"];
    if (![fontFamily isKindOfClass:[NSString class]]) {
        fontFamily = [UIFont systemFontOfSize:10].familyName;
    }
    NSNumber *fontSize = style[@"fontSize"];
    if (![fontSize isKindOfClass:[NSNumber class]]) {
        fontSize = @(14);
    }
    NSString *fontWeight = style[@"fontWeight"];
    if ([fontWeight isKindOfClass:[NSString class]]) {
        if ([fontWeight isEqualToString:@"FontWeight.w100"]) {
            fontWeight = @"CTFontUltraLightUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w200"]) {
            fontWeight = @"CTFontThinUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w300"]) {
            fontWeight = @"CTFontLightUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w400"]) {
            fontWeight = @"CTFontRegularUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w500"]) {
            fontWeight = @"CTFontMediumUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w600"]) {
            fontWeight = @"CTFontSemiboldUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w700"]) {
            fontWeight = @"CTFontBoldUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w800"]) {
            fontWeight = @"CTFontHeavyUsage";
        }
        else if ([fontWeight isEqualToString:@"FontWeight.w900"]) {
            fontWeight = @"CTFontBlackUsage";
        }
        else {
            fontWeight = @"CTFontRegularUsage";
        }
    }
    else {
        fontWeight = @"CTFontRegularUsage";
    }
    NSString *fontStyle = style[@"fontStyle"];
    if ([fontStyle isKindOfClass:[NSString class]]) {
        if ([fontStyle isEqualToString:@"FontStyle.italic"]) {
            fontStyle = @"CTFontObliqueUsage";
        }
        else {
            fontStyle = @"CTFontRegularUsage";
        }
    }
    else {
        fontStyle = @"CTFontRegularUsage";
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    UIFontDescriptor *descriptor = [[UIFontDescriptor alloc] initWithFontAttributes:@{
        UIFontDescriptorFamilyAttribute: fontFamily,
        @"NSCTFontUIUsageAttribute": style[@"fontStyle"] != nil ? fontStyle : fontWeight,
    }];
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:fontSize.floatValue];
    attrs[NSFontAttributeName] = font;
    NSString *color = style[@"color"];
    if ([color isKindOfClass:[NSString class]]) {
        attrs[NSForegroundColorAttributeName] = [MPIOSComponentUtils colorFromString:color];
    }
    NSNumber *letterSpacing = style[@"letterSpacing"];
    if ([letterSpacing isKindOfClass:[NSNumber class]]) {
        attrs[NSKernAttributeName] = letterSpacing;
    }
    NSNumber *wordSpacing = style[@"wordSpacing"];
    if ([wordSpacing isKindOfClass:[NSNumber class]]) {
        // not support yet.
    }
    NSString *textBaseline = style[@"textBaseline"];
    if ([textBaseline isKindOfClass:[NSString class]]) {
        // not support yet.
    }
    NSNumber *height = style[@"height"];
    if ([height isKindOfClass:[NSNumber class]]) {
        [paragraphStyle setLineHeightMultiple:height.floatValue];
        attrs[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    NSString *decoration = style[@"decoration"];
    if ([decoration isKindOfClass:[NSString class]]) {
        if ([decoration isEqualToString:@"TextDecoration.lineThrough"]) {
            attrs[NSStrikethroughStyleAttributeName] = @(1);
        }
        else if ([decoration isEqualToString:@"TextDecoration.underline"]) {
            attrs[NSUnderlineStyleAttributeName] = @(1);
        }
    }
    NSString *backgroundColor = style[@"backgroundColor"];
    if ([backgroundColor isKindOfClass:[NSString class]]) {
        attrs[NSBackgroundColorAttributeName] = [MPIOSComponentUtils colorFromString:backgroundColor];
    }
    self.contentAttributes = attrs.copy;
    if ([self.contentView isKindOfClass:[UITextField class]]) {
        [(UITextField *)self.contentView setDefaultTextAttributes:self.contentAttributes];
    }
    else if ([self.contentView isKindOfClass:[UITextView class]]) {
        [(UITextView *)self.contentView setTypingAttributes:self.contentAttributes];
    }
}

- (void)didMoveToWindow {
    if (self.window != nil && self.autoFocus) {
        if ([self.contentView isKindOfClass:[UITextField class]]) {
            [(UITextField *)self.contentView becomeFirstResponder];
        }
        else if ([self.contentView isKindOfClass:[UITextView class]]) {
            [(UITextView *)self.contentView becomeFirstResponder];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self onSubmit:textField.text ?: @""];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self onChanged:textField.text ?: @""];
    });
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self onSubmit:textView.text ?: @""];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self onChanged:textView.text ?: @""];
}

#pragma mark - callback

- (void)onSubmit:(NSString *)value {
    MPIOSEngine *engine = self.engine;
    [engine sendMessage:@{
        @"type": @"editable_text",
                  @"message": @{
                    @"event": @"onSubmitted",
                    @"target": self.hashCode ?: @(0),
                    @"data": value ?: @"",
                  },
    }];
}

- (void)onChanged:(NSString *)value {
    MPIOSEngine *engine = self.engine;
    [engine sendMessage:@{
        @"type": @"editable_text",
                  @"message": @{
                    @"event": @"onChanged",
                    @"target": self.hashCode ?: @(0),
                    @"data": value ?: @"",
                  },
    }];
}

@end
