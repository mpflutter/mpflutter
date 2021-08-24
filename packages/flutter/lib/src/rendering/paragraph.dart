// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../widgets.dart';
import 'box.dart';
import 'object.dart';

/// How overflowing text should be handled.
///
/// A [TextOverflow] can be passed to [Text] and [RichText] via their
/// [Text.overflow] and [RichText.overflow] properties respectively.
enum TextOverflow {
  /// Clip the overflowing text to fix its container.
  clip,

  /// Fade the overflowing text to transparent.
  fade,

  /// Use an ellipsis to indicate that the text has overflowed.
  ellipsis,

  /// Render overflowing text outside of its container.
  visible,
}

const String _kEllipsis = '\u2026';

/// Parent data for use with [RenderParagraph].
class TextParentData extends ContainerBoxParentData<RenderBox> {
  /// The scaling of the text.
  double? scale;

  @override
  String toString() {
    final List<String> values = <String>[
      if (offset != null) 'offset=$offset',
      if (scale != null) 'scale=$scale',
      super.toString(),
    ];
    return values.join('; ');
  }
}

class RenderParagraph extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, TextParentData> {
  Element? element;
  Size? measuredSize;
  InlineSpan? data;
  TextAlign? textAlign;
  bool? softWrap;
  TextOverflow? overflow;
  int? maxLines;
  BoxConstraints? lastConstraints;

  RenderParagraph({
    this.element,
    this.data,
    this.textAlign,
    this.softWrap,
    this.overflow,
    this.maxLines,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TextParentData)
      child.parentData = TextParentData();
  }

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
    if (lastConstraints != null &&
        lastConstraints != constraints &&
        lastConstraints!.maxWidth < constraints.maxWidth) {
      if (this.element != null) {
        this.measuredSize = null;
        BuildOwner.beingMeasureElements.add(this.element!);
      }
    }
    lastConstraints = constraints;
  }

  Size _sizeForConstraints(BoxConstraints constraints) {
    if (measuredSize != null) {
      return Size(
        math.max(math.min(measuredSize!.width, constraints.biggest.width),
            constraints.smallest.width),
        math.max(math.min(measuredSize!.height, constraints.biggest.height),
            constraints.smallest.height),
      );
    }
    return constraints.smallest;
  }
}
