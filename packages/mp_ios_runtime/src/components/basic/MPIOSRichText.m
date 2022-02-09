//
//  MPIOSRichText.m
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import "MPIOSRichText.h"
#import "MPIOSComponentUtils.h"
#import "MPIOSComponentFactory.h"

@interface MPIOSRichText ()

@property (nonatomic, strong) UILabel *contentView;
@property (nonatomic, strong) NSNumber *measureId;
@property (nonatomic, assign) float maxWidth;
@property (nonatomic, assign) float maxHeight;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSValue *> *attachmentsRange;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIView *> *attachmentsView;

@end

@implementation MPIOSRichText

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentView = [[UILabel alloc] init];
        _attachmentsRange = [NSMutableDictionary dictionary];
        _attachmentsView = [NSMutableDictionary dictionary];
        _contentView.userInteractionEnabled = NO;
        self.userInteractionEnabled = NO;
        [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(onContentViewTap:)]];
        [_contentView setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)onContentViewTap:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.contentView];
    CGSize labelSize = self.contentView.bounds.size;
    NSAttributedString *attributedText = self.contentView.attributedText;
    if (attributedText == nil) {
        return;
    }
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:labelSize];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.contentView.lineBreakMode;
    textContainer.maximumNumberOfLines = self.contentView.numberOfLines;
    
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(touchPoint.x - textContainerOffset.x,
                                                         touchPoint.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                            inTextContainer:textContainer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    NSNumber *onTapEl = [attributedText attribute:@"onTapEl"
                                          atIndex:indexOfCharacter
                                   effectiveRange:nil];
    NSNumber *onTapSpan = [attributedText attribute:@"onTapSpan"
                                          atIndex:indexOfCharacter
                                   effectiveRange:nil];
    if (onTapEl != nil && [onTapEl isKindOfClass:[NSNumber class]] &&
        onTapSpan != nil && [onTapSpan isKindOfClass:[NSNumber class]]) {
        MPIOSEngine *engine = self.engine;
        if (engine != nil) {
            [engine sendMessage:@{
                @"type": @"rich_text",
                @"message": @{
                        @"event": @"onTap",
                        @"target": onTapEl,
                        @"subTarget": onTapSpan,
                }
            }];
        }
    }
}

- (void)setChildren:(NSArray *)children {
    if (children.count == 1 && [children[0] isKindOfClass:[NSDictionary class]] && children[0][@"^"] != nil) {
        return;
    }
    [self.attachmentsRange removeAllObjects];
    NSAttributedString *text = [self attributedStringFromData:children];
    self.contentView.attributedText = text;
    if (self.measureId != nil) {
        [self doMeasure];
    }
    [self addWidgetSpans];
}

- (void)addWidgetSpans {
    for (UIView *subview in self.contentView.subviews.copy) {
        [subview removeFromSuperview];
    }
    if (self.attachmentsRange.count > 0) {
        NSAttributedString *attributedText = self.contentView.attributedText;
        if (attributedText == nil) {
            return;
        }
        CGSize labelSize = CGSizeMake(self.maxWidth, self.maxHeight);
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:labelSize];
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        textContainer.lineFragmentPadding = 0.0;
        textContainer.lineBreakMode = self.contentView.lineBreakMode;
        textContainer.maximumNumberOfLines = self.contentView.numberOfLines;
        [self.attachmentsRange enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSValue * _Nonnull obj, BOOL * _Nonnull stop) {
            NSRange range = [obj rangeValue];
            if (range.location < attributedText.length && range.location + range.length <= attributedText.length) {
                CGRect attachmentRect = [layoutManager boundingRectForGlyphRange:range inTextContainer:textContainer];
                UIView *attachmentView = self.attachmentsView[key];
                if (attachmentView != nil) {
                    attachmentView.frame = attachmentRect;
                }
                [self.contentView addSubview:attachmentView];
            }
        }];
    }
}

- (NSAttributedString *)attributedStringFromData:(NSArray *)children {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    if (![children isKindOfClass:[NSArray class]]) {
        return nil;
    }
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        BOOL same = obj[@"^"] != nil;
        NSNumber *hashCode = obj[@"hashCode"] ?: @(0);
        NSAttributedString *cachedString = self.factory.cachedAttributedString[hashCode];
        if (same && cachedString != nil) {
            if (cachedString.length > 0 && [cachedString containsAttachmentsInRange:NSMakeRange(0, 1)]) {
                self.attachmentsRange[hashCode] = [NSValue valueWithRange:NSMakeRange(text.length, 1)];
            }
            [text appendAttributedString:cachedString];
            return;
        }
        NSString *name = obj[@"name"];
        if (![name isKindOfClass:[NSString class]]) {
            return;
        }
        if ([name isEqualToString:@"text_span"]) {
            NSAttributedString *spanText = [self attributedStringFromTextSpanData:obj];
            if (spanText != nil) {
                [text appendAttributedString:spanText];
            }
        }
        else if ([name isEqualToString:@"widget_span"]) {
            NSAttributedString *spanText = [self attributedStringFromWidgetSpanData:obj];
            if (spanText != nil) {
                NSNumber *hashCode = obj[@"hashCode"] ?: @(0);
                self.attachmentsRange[hashCode] = [NSValue valueWithRange:NSMakeRange(text.length, 1)];
                [text appendAttributedString:spanText];
            }
        }
    }];
    return [text copy];
}

- (NSAttributedString *)attributedStringFromTextSpanData:(NSDictionary *)data {
    NSNumber *hashCode = data[@"hashCode"] ?: @(0);
    if (![data[@"children"] isKindOfClass:[NSArray class]]) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        NSString *fontFamily = data[@"attributes"][@"style"][@"fontFamily"];
        if (![fontFamily isKindOfClass:[NSString class]]) {
            fontFamily = [UIFont systemFontOfSize:10].familyName;
        }
        NSNumber *fontSize = data[@"attributes"][@"style"][@"fontSize"];
        if (![fontSize isKindOfClass:[NSNumber class]]) {
            fontSize = @(14);
        }
        NSString *fontWeight = data[@"attributes"][@"style"][@"fontWeight"];
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
        NSString *fontStyle = data[@"attributes"][@"style"][@"fontStyle"];
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
            @"NSCTFontUIUsageAttribute": data[@"attributes"][@"style"][@"fontStyle"] != nil ? fontStyle : fontWeight,
        }];
        UIFont *font = [UIFont fontWithDescriptor:descriptor size:fontSize.floatValue];
        attrs[NSFontAttributeName] = font;
        NSString *color = data[@"attributes"][@"style"][@"color"];
        if ([color isKindOfClass:[NSString class]]) {
            attrs[NSForegroundColorAttributeName] = [MPIOSComponentUtils colorFromString:color];
        }
        NSNumber *letterSpacing = data[@"attributes"][@"style"][@"letterSpacing"];
        if ([letterSpacing isKindOfClass:[NSNumber class]]) {
            attrs[NSKernAttributeName] = letterSpacing;
        }
        NSNumber *wordSpacing = data[@"attributes"][@"style"][@"wordSpacing"];
        if ([wordSpacing isKindOfClass:[NSNumber class]]) {
            // not support yet.
        }
        NSString *textBaseline = data[@"attributes"][@"style"][@"textBaseline"];
        if ([textBaseline isKindOfClass:[NSString class]]) {
            // not support yet.
        }
        NSNumber *height = data[@"attributes"][@"style"][@"height"];
        if ([height isKindOfClass:[NSNumber class]]) {
            [paragraphStyle setLineHeightMultiple:height.floatValue];
            attrs[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        NSNumber *onTapEl = data[@"attributes"][@"onTap_el"];
        NSNumber *onTapSpan = data[@"attributes"][@"onTap_span"];
        if (onTapEl != nil &&
            [onTapEl isKindOfClass:[NSNumber class]] &&
            onTapSpan != nil &&
            [onTapSpan isKindOfClass:[NSNumber class]]) {
            attrs[@"onTapEl"] = onTapEl;
            attrs[@"onTapSpan"] = onTapSpan;
            self.contentView.userInteractionEnabled = YES;
            self.userInteractionEnabled = YES;
        }
        NSString *decoration = data[@"attributes"][@"style"][@"decoration"];
        if ([decoration isKindOfClass:[NSString class]]) {
            if ([decoration isEqualToString:@"TextDecoration.lineThrough"]) {
                attrs[NSStrikethroughStyleAttributeName] = @(1);
            }
            else if ([decoration isEqualToString:@"TextDecoration.underline"]) {
                attrs[NSUnderlineStyleAttributeName] = @(1);
            }
        }
        NSString *backgroundColor = data[@"attributes"][@"style"][@"backgroundColor"];
        if ([backgroundColor isKindOfClass:[NSString class]]) {
            attrs[NSBackgroundColorAttributeName] = [MPIOSComponentUtils colorFromString:backgroundColor];
        }
        NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                initWithString:data[@"attributes"][@"text"]
                                                attributes:attrs.copy];
        self.factory.cachedAttributedString[hashCode] = attributedString;
        return attributedString;
    }
    else {
        return [self attributedStringFromData:data[@"children"]];
    }
}

- (NSAttributedString *)attributedStringFromWidgetSpanData:(NSDictionary *)data {
    NSNumber *hashCode = data[@"hashCode"] ?: @(0);
    CGSize widgetSize = [MPIOSComponentUtils sizeFromMPElement:data];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    UIView *view = [self.factory create:data];
    if (widgetSize.width == 0 && widgetSize.height == 0) {
        CGSize subSize = view.subviews.firstObject.frame.size;
        if (subSize.width > 0 && subSize.height > 0) {
            widgetSize = subSize;
        }
    }
    self.attachmentsView[hashCode] = view;
    [attachment setBounds:CGRectMake(0, 0, widgetSize.width, widgetSize.height)];
    NSAttributedString *text = [NSAttributedString attributedStringWithAttachment:attachment];
    self.factory.cachedAttributedString[hashCode] = text;
    return text;
}

- (void)setAttributes:(NSDictionary *)attributes {
    [super setAttributes:attributes];
    NSNumber *maxLines = attributes[@"maxLines"];
    if ([maxLines isKindOfClass:[NSNumber class]]) {
        self.contentView.numberOfLines = [maxLines intValue];
    }
    else {
        self.contentView.numberOfLines = 0;
    }
    NSString *textAlign = attributes[@"textAlign"];
    if ([textAlign isKindOfClass:[NSString class]]) {
        if ([textAlign isEqualToString:@"TextAlign.left"]) {
            self.contentView.textAlignment = NSTextAlignmentLeft;
        }
        else if ([textAlign isEqualToString:@"TextAlign.right"]) {
            self.contentView.textAlignment = NSTextAlignmentRight;
        }
        else if ([textAlign isEqualToString:@"TextAlign.center"]) {
            self.contentView.textAlignment = NSTextAlignmentCenter;
        }
        else if ([textAlign isEqualToString:@"TextAlign.justify"]) {
            self.contentView.textAlignment = NSTextAlignmentJustified;
        }
        else if ([textAlign isEqualToString:@"TextAlign.start"]) {
            self.contentView.textAlignment = NSTextAlignmentLeft;
        }
        else if ([textAlign isEqualToString:@"TextAlign.end"]) {
            self.contentView.textAlignment = NSTextAlignmentRight;
        }
        else {
            self.contentView.textAlignment = NSTextAlignmentNatural;
        }
    }
    else {
        self.contentView.textAlignment = NSTextAlignmentNatural;
    }
    NSString *maxWidth = attributes[@"maxWidth"];
    if ([maxWidth isKindOfClass:[NSString class]]) {
        self.maxWidth = [MPIOSComponentUtils floatFromString:maxWidth];
    }
    NSString *maxHeight = attributes[@"maxHeight"];
    if ([maxHeight isKindOfClass:[NSString class]]) {
        self.maxHeight = [MPIOSComponentUtils floatFromString:maxHeight];
    }
    NSNumber *measureId = attributes[@"measureId"];
    if ([measureId isKindOfClass:[NSNumber class]]) {
        self.measureId = measureId;
    }
    else {
        self.measureId = nil;
    }
}

- (void)doMeasure {
    if (self.contentView.attributedText != nil) {
        CGRect textRect = [self.contentView.attributedText boundingRectWithSize:CGSizeMake(self.maxWidth, self.maxHeight)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                        context:NULL];
        MPIOSComponentFactory *factory = self.factory;
        if (factory == nil) {
            return;
        }
        [factory callbackTextMeasureResult:self.measureId
                                      size:CGSizeMake(ceil(textRect.size.width + 2),
                                                      ceil(textRect.size.height))];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.preferredMaxLayoutWidth = self.maxWidth;
    CGSize textSize = [self.contentView intrinsicContentSize];
    self.contentView.frame = CGRectMake(0,
                                        0,
                                        MAX(self.maxWidth, textSize.width),
                                        MAX(self.maxHeight, textSize.height));
}

@end
