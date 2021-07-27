part of dart.ui;

class MockParagraphBuilder implements ParagraphBuilder {
  void pushStyle(TextStyle style) {}
  void pop() {}
  void addText(String text) {}
  Paragraph build() {
    return MockParagraph();
  }

  int get placeholderCount => 0;
  List<double> get placeholderScales => [];
  void addPlaceholder(
    double width,
    double height,
    PlaceholderAlignment alignment, {
    double scale = 1.0,
    double? baselineOffset,
    TextBaseline? baseline,
  }) {}
}

class MockParagraph implements Paragraph {
  double get width => 0.0;
  double get height => 0.0;
  double get longestLine => 0.0;
  double get minIntrinsicWidth => 0.0;
  double get maxIntrinsicWidth => 0.0;
  double get alphabeticBaseline => 0.0;
  double get ideographicBaseline => 0.0;
  bool get didExceedMaxLines => false;

  void layout(ParagraphConstraints constraints) {}

  List<TextBox> getBoxesForRange(int start, int end,
      {BoxHeightStyle boxHeightStyle = BoxHeightStyle.tight,
      BoxWidthStyle boxWidthStyle = BoxWidthStyle.tight}) {
    return [];
  }

  TextPosition getPositionForOffset(Offset offset) {
    return TextPosition(offset: 0);
  }

  TextRange getWordBoundary(TextPosition position) {
    return TextRange(start: 0, end: 0);
  }

  TextRange getLineBoundary(TextPosition position) {
    return TextRange(start: 0, end: 0);
  }

  List<TextBox> getBoxesForPlaceholders() {
    return [];
  }

  List<LineMetrics> computeLineMetrics() {
    return [];
  }
}

class MockTextStyle implements TextStyle {}

class MockParagraphStyle implements ParagraphStyle {}

/// The web implementation of [StrutStyle].
class MockStrutStyle implements StrutStyle {
  /// Creates a new StrutStyle object.
  ///
  /// * `fontFamily`: The name of the font to use when painting the text (e.g.,
  ///   Roboto).
  ///
  /// * `fontFamilyFallback`: An ordered list of font family names that will be searched for when
  ///    the font in `fontFamily` cannot be found.
  ///
  /// * `fontSize`: The size of glyphs (in logical pixels) to use when painting
  ///   the text.
  ///
  /// * `lineHeight`: The minimum height of the line boxes, as a multiple of the
  ///   font size. The lines of the paragraph will be at least
  ///   `(lineHeight + leading) * fontSize` tall when fontSize
  ///   is not null. When fontSize is null, there is no minimum line height. Tall
  ///   glyphs due to baseline alignment or large [TextStyle.fontSize] may cause
  ///   the actual line height after layout to be taller than specified here.
  ///   [fontSize] must be provided for this property to take effect.
  ///
  /// * `leading`: The minimum amount of leading between lines as a multiple of
  ///   the font size. [fontSize] must be provided for this property to take effect.
  ///
  /// * `fontWeight`: The typeface thickness to use when painting the text
  ///   (e.g., bold).
  ///
  /// * `fontStyle`: The typeface variant to use when drawing the letters (e.g.,
  ///   italics).
  ///
  /// * `forceStrutHeight`: When true, the paragraph will force all lines to be exactly
  ///   `(lineHeight + leading) * fontSize` tall from baseline to baseline.
  ///   [TextStyle] is no longer able to influence the line height, and any tall
  ///   glyphs may overlap with lines above. If a [fontFamily] is specified, the
  ///   total ascent of the first line will be the min of the `Ascent + half-leading`
  ///   of the [fontFamily] and `(lineHeight + leading) * fontSize`. Otherwise, it
  ///   will be determined by the Ascent + half-leading of the first text.
  MockStrutStyle({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double? fontSize,
    double? height,
    double? leading,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    bool? forceStrutHeight,
  })  : _fontFamily = fontFamily,
        _fontFamilyFallback = fontFamilyFallback,
        _fontSize = fontSize,
        _height = height,
        _leading = leading,
        _fontWeight = fontWeight,
        _fontStyle = fontStyle,
        _forceStrutHeight = forceStrutHeight;

  final String? _fontFamily;
  final List<String>? _fontFamilyFallback;
  final double? _fontSize;
  final double? _height;
  final double? _leading;
  final FontWeight? _fontWeight;
  final FontStyle? _fontStyle;
  final bool? _forceStrutHeight;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MockStrutStyle &&
        other._fontFamily == _fontFamily &&
        other._fontSize == _fontSize &&
        other._height == _height &&
        other._leading == _leading &&
        other._fontWeight == _fontWeight &&
        other._fontStyle == _fontStyle &&
        other._forceStrutHeight == _forceStrutHeight;
  }

  @override
  int get hashCode => hashValues(
        _fontFamily,
        _fontFamilyFallback,
        _fontSize,
        _height,
        _leading,
        _fontWeight,
        _fontStyle,
        _forceStrutHeight,
      );
}

class MockLineMetrics implements LineMetrics {
  MockLineMetrics({
    required this.hardBreak,
    required this.ascent,
    required this.descent,
    required this.unscaledAscent,
    required this.height,
    required this.width,
    required this.left,
    required this.baseline,
    required this.lineNumber,
  })   : displayText = null,
        startIndex = -1,
        endIndex = -1,
        endIndexWithoutNewlines = -1,
        widthWithTrailingSpaces = 0;

  MockLineMetrics.withText(
    String this.displayText, {
    required this.startIndex,
    required this.endIndex,
    required this.endIndexWithoutNewlines,
    required this.hardBreak,
    required this.width,
    required this.widthWithTrailingSpaces,
    required this.left,
    required this.lineNumber,
  })   : assert(displayText != null), // ignore: unnecessary_null_comparison
        assert(startIndex != null), // ignore: unnecessary_null_comparison
        assert(endIndex != null), // ignore: unnecessary_null_comparison
        assert(endIndexWithoutNewlines !=
            null), // ignore: unnecessary_null_comparison
        assert(hardBreak != null), // ignore: unnecessary_null_comparison
        assert(width != null), // ignore: unnecessary_null_comparison
        assert(left != null), // ignore: unnecessary_null_comparison
        assert(lineNumber != null &&
            lineNumber >= 0), // ignore: unnecessary_null_comparison
        ascent = double.infinity,
        descent = double.infinity,
        unscaledAscent = double.infinity,
        height = double.infinity,
        baseline = double.infinity;

  /// The text to be rendered on the screen representing this line.
  final String? displayText;

  /// The index (inclusive) in the text where this line begins.
  final int startIndex;

  /// The index (exclusive) in the text where this line ends.
  ///
  /// When the line contains an overflow, then [endIndex] goes until the end of
  /// the text and doesn't stop at the overflow cutoff.
  final int endIndex;

  /// The index (exclusive) in the text where this line ends, ignoring newline
  /// characters.
  final int endIndexWithoutNewlines;

  @override
  final bool hardBreak;

  @override
  final double ascent;

  @override
  final double descent;

  @override
  final double unscaledAscent;

  @override
  final double height;

  @override
  final double width;

  /// The full width of the line including all trailing space but not new lines.
  ///
  /// The difference between [width] and [widthWithTrailingSpaces] is that
  /// [widthWithTrailingSpaces] includes trailing spaces in the width
  /// calculation while [width] doesn't.
  ///
  /// For alignment purposes for example, the [width] property is the right one
  /// to use because trailing spaces shouldn't affect the centering of text.
  /// But for placing cursors in text fields, we do care about trailing
  /// spaces so [widthWithTrailingSpaces] is more suitable.
  final double widthWithTrailingSpaces;

  @override
  final double left;

  @override
  final double baseline;

  @override
  final int lineNumber;

  @override
  int get hashCode => hashValues(
        displayText,
        startIndex,
        endIndex,
        hardBreak,
        ascent,
        descent,
        unscaledAscent,
        height,
        width,
        left,
        baseline,
        lineNumber,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MockLineMetrics &&
        other.displayText == displayText &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex &&
        other.hardBreak == hardBreak &&
        other.ascent == ascent &&
        other.descent == descent &&
        other.unscaledAscent == unscaledAscent &&
        other.height == height &&
        other.width == width &&
        other.left == left &&
        other.baseline == baseline &&
        other.lineNumber == lineNumber;
  }

  @override
  String toString() {
    if (assertionsEnabled) {
      return 'LineMetrics(hardBreak: $hardBreak, '
          'ascent: $ascent, '
          'descent: $descent, '
          'unscaledAscent: $unscaledAscent, '
          'height: $height, '
          'width: $width, '
          'left: $left, '
          'baseline: $baseline, '
          'lineNumber: $lineNumber)';
    } else {
      return super.toString();
    }
  }
}
