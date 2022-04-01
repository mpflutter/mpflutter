// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/ui/ui.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'basic.dart';
import 'focus_manager.dart';
import 'framework.dart';
import 'gesture_detector.dart';
import 'notification_listener.dart';
import 'primary_scroll_controller.dart';
import 'restoration.dart';
import 'restoration_properties.dart';
import 'scroll_configuration.dart';
import 'scroll_context.dart';
import 'scroll_controller.dart';
import 'scroll_metrics.dart';
import 'scroll_physics.dart';
import 'scroll_position.dart';
import 'scroll_position_with_single_context.dart';
import 'ticker_provider.dart';
import 'viewport.dart';

export 'package:flutter/physics.dart' show Tolerance;

/// Signature used by [Scrollable] to build the viewport through which the
/// scrollable content is displayed.
typedef ViewportBuilder = Widget Function(
    BuildContext context, ViewportOffset position);

/// A widget that scrolls.
///
/// [Scrollable] implements the interaction model for a scrollable widget,
/// including gesture recognition, but does not have an opinion about how the
/// viewport, which actually displays the children, is constructed.
///
/// It's rare to construct a [Scrollable] directly. Instead, consider [ListView]
/// or [GridView], which combine scrolling, viewporting, and a layout model. To
/// combine layout models (or to use a custom layout mode), consider using
/// [CustomScrollView].
///
/// The static [Scrollable.of] and [Scrollable.ensureVisible] functions are
/// often used to interact with the [Scrollable] widget inside a [ListView] or
/// a [GridView].
///
/// To further customize scrolling behavior with a [Scrollable]:
///
/// 1. You can provide a [viewportBuilder] to customize the child model. For
///    example, [SingleChildScrollView] uses a viewport that displays a single
///    box child whereas [CustomScrollView] uses a [Viewport] or a
///    [ShrinkWrappingViewport], both of which display a list of slivers.
///
/// 2. You can provide a custom [ScrollController] that creates a custom
///    [ScrollPosition] subclass. For example, [PageView] uses a
///    [PageController], which creates a page-oriented scroll position subclass
///    that keeps the same page visible when the [Scrollable] resizes.
///
/// See also:
///
///  * [ListView], which is a commonly used [ScrollView] that displays a
///    scrolling, linear list of child widgets.
///  * [PageView], which is a scrolling list of child widgets that are each the
///    size of the viewport.
///  * [GridView], which is a [ScrollView] that displays a scrolling, 2D array
///    of child widgets.
///  * [CustomScrollView], which is a [ScrollView] that creates custom scroll
///    effects using slivers.
///  * [SingleChildScrollView], which is a scrollable widget that has a single
///    child.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class Scrollable extends StatefulWidget {
  /// Creates a widget that scrolls.
  ///
  /// The [axisDirection] and [viewportBuilder] arguments must not be null.
  const Scrollable({
    Key? key,
    this.axisDirection = AxisDirection.down,
    this.controller,
    this.physics,
    required this.viewportBuilder,
    this.incrementCalculator,
    this.excludeFromSemantics = false,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.restorationId,
  })  : assert(axisDirection != null),
        assert(dragStartBehavior != null),
        assert(viewportBuilder != null),
        assert(excludeFromSemantics != null),
        assert(semanticChildCount == null || semanticChildCount >= 0),
        super(key: key);

  /// The direction in which this widget scrolls.
  ///
  /// For example, if the [axisDirection] is [AxisDirection.down], increasing
  /// the scroll position will cause content below the bottom of the viewport to
  /// become visible through the viewport. Similarly, if [axisDirection] is
  /// [AxisDirection.right], increasing the scroll position will cause content
  /// beyond the right edge of the viewport to become visible through the
  /// viewport.
  ///
  /// Defaults to [AxisDirection.down].
  final AxisDirection axisDirection;

  /// An object that can be used to control the position to which this widget is
  /// scrolled.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  ///
  /// See also:
  ///
  ///  * [ensureVisible], which animates the scroll position to reveal a given
  ///    [BuildContext].
  final ScrollController? controller;

  /// How the widgets should respond to user input.
  ///
  /// For example, determines how the widget continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions via the physics provided from
  /// the ambient [ScrollConfiguration].
  ///
  /// The physics can be changed dynamically, but new physics will only take
  /// effect if the _class_ of the provided object changes. Merely constructing
  /// a new instance with a different configuration is insufficient to cause the
  /// physics to be reapplied. (This is because the final object used is
  /// generated dynamically, which can be relatively expensive, and it would be
  /// inefficient to speculatively create this object each frame to see if the
  /// physics should be updated.)
  ///
  /// See also:
  ///
  ///  * [AlwaysScrollableScrollPhysics], which can be used to indicate that the
  ///    scrollable should react to scroll requests (and possible overscroll)
  ///    even if the scrollable's contents fit without scrolling being necessary.
  final ScrollPhysics? physics;

  /// Builds the viewport through which the scrollable content is displayed.
  ///
  /// A typical viewport uses the given [ViewportOffset] to determine which part
  /// of its content is actually visible through the viewport.
  ///
  /// See also:
  ///
  ///  * [Viewport], which is a viewport that displays a list of slivers.
  ///  * [ShrinkWrappingViewport], which is a viewport that displays a list of
  ///    slivers and sizes itself based on the size of the slivers.
  final ViewportBuilder viewportBuilder;

  /// An optional function that will be called to calculate the distance to
  /// scroll when the scrollable is asked to scroll via the keyboard using a
  /// [ScrollAction].
  ///
  /// If not supplied, the [Scrollable] will scroll a default amount when a
  /// keyboard navigation key is pressed (e.g. pageUp/pageDown, control-upArrow,
  /// etc.), or otherwise invoked by a [ScrollAction].
  ///
  /// If [incrementCalculator] is null, the default for
  /// [ScrollIncrementType.page] is 80% of the size of the scroll window, and
  /// for [ScrollIncrementType.line], 50 logical pixels.
  final ScrollIncrementCalculator? incrementCalculator;

  /// Whether the scroll actions introduced by this [Scrollable] are exposed
  /// in the semantics tree.
  ///
  /// Text fields with an overflow are usually scrollable to make sure that the
  /// user can get to the beginning/end of the entered text. However, these
  /// scrolling actions are generally not exposed to the semantics layer.
  ///
  /// See also:
  ///
  ///  * [GestureDetector.excludeFromSemantics], which is used to accomplish the
  ///    exclusion.
  final bool excludeFromSemantics;

  /// The number of children that will contribute semantic information.
  ///
  /// The value will be null if the number of children is unknown or unbounded.
  ///
  /// Some subtypes of [ScrollView] can infer this value automatically. For
  /// example [ListView] will use the number of widgets in the child list,
  /// while the [new ListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided.
  ///
  /// See also:
  ///
  ///  * [CustomScrollView], for an explanation of scroll semantics.
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics property.
  final int? semanticChildCount;

  // TODO(jslavitz): Set the DragStartBehavior default to be start across all widgets.
  /// {@template flutter.widgets.scrollable.dragStartBehavior}
  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], scrolling drag behavior will
  /// begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  ///
  /// {@endtemplate}
  final DragStartBehavior dragStartBehavior;

  /// {@template flutter.widgets.scrollable.restorationId}
  /// Restoration ID to save and restore the scroll offset of the scrollable.
  ///
  /// If a restoration id is provided, the scrollable will persist its current
  /// scroll offset and restore it during state restoration.
  ///
  /// The scroll offset is persisted in a [RestorationBucket] claimed from
  /// the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  /// {@endtemplate}
  final String? restorationId;

  /// The axis along which the scroll view scrolls.
  ///
  /// Determined by the [axisDirection].
  Axis get axis => axisDirectionToAxis(axisDirection);

  @override
  ScrollableState createState() => ScrollableState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<AxisDirection>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', physics));
    properties.add(StringProperty('restorationId', restorationId));
  }

  /// The state from the closest instance of this class that encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ScrollableState scrollable = Scrollable.of(context);
  /// ```
  ///
  /// Calling this method will create a dependency on the closest [Scrollable]
  /// in the [context], if there is one.
  static ScrollableState? of(BuildContext context) {
    final _ScrollableScope? widget =
        context.dependOnInheritedWidgetOfExactType<_ScrollableScope>();
    return widget?.scrollable;
  }

  /// Provides a heuristic to determine if expensive frame-bound tasks should be
  /// deferred for the [context] at a specific point in time.
  ///
  /// Calling this method does _not_ create a dependency on any other widget.
  /// This also means that the value returned is only good for the point in time
  /// when it is called, and callers will not get updated if the value changes.
  ///
  /// The heuristic used is determined by the [physics] of this [Scrollable]
  /// via [ScrollPhysics.recommendDeferredLoading]. That method is called with
  /// the current [ScrollPosition.activity]'s [ScrollActivity.velocity].
  ///
  /// If there is no [Scrollable] in the widget tree above the [context], this
  /// method returns false.
  static bool recommendDeferredLoadingForContext(BuildContext context) {
    final _ScrollableScope? widget = context
        .getElementForInheritedWidgetOfExactType<_ScrollableScope>()
        ?.widget as _ScrollableScope?;
    if (widget == null) {
      return false;
    }
    return widget.position.recommendDeferredLoading(context);
  }

  /// Scrolls the scrollables that enclose the given context so as to make the
  /// given context visible.
  static Future<void> ensureVisible(
    BuildContext context, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
  }) {
    return Future.wait<void>([]).then<void>((List<void> _) => null);
  }
}

// Enable Scrollable.of() to work as if ScrollableState was an inherited widget.
// ScrollableState.build() always rebuilds its _ScrollableScope.
class _ScrollableScope extends InheritedWidget {
  const _ScrollableScope({
    Key? key,
    required this.scrollable,
    required this.position,
    required Widget child,
  })  : assert(scrollable != null),
        assert(child != null),
        super(key: key, child: child);

  final ScrollableState scrollable;
  final ScrollPosition position;

  @override
  bool updateShouldNotify(_ScrollableScope old) {
    return position != old.position;
  }
}

/// State object for a [Scrollable] widget.
///
/// To manipulate a [Scrollable] widget's scroll position, use the object
/// obtained from the [position] property.
///
/// To be informed of when a [Scrollable] widget is scrolling, use a
/// [NotificationListener] to listen for [ScrollNotification] notifications.
///
/// This class is not intended to be subclassed. To specialize the behavior of a
/// [Scrollable], provide it with a [ScrollPhysics].
class ScrollableState extends State<Scrollable>
    with TickerProviderStateMixin, RestorationMixin
    implements ScrollContext {
  /// The manager for this [Scrollable] widget's viewport position.
  ///
  /// To control what kind of [ScrollPosition] is created for a [Scrollable],
  /// provide it with custom [ScrollController] that creates the appropriate
  /// [ScrollPosition] in its [ScrollController.createScrollPosition] method.
  ScrollPosition get position => _position!;
  ScrollPosition? _position;

  final _RestorableScrollOffset _persistedScrollOffset =
      _RestorableScrollOffset();

  @override
  AxisDirection get axisDirection => widget.axisDirection;

  late ScrollBehavior _configuration;
  ScrollPhysics? _physics = BouncingScrollPhysics();

  // Only call this from places that will definitely trigger a rebuild.
  void _updatePosition() {
    _configuration = ScrollConfiguration.of(context);
    _position = ScrollPositionWithSingleContext(
      physics: _physics!,
      context: this,
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_persistedScrollOffset, 'offset');
    assert(_position != null);
    if (_persistedScrollOffset.value != null) {
      position.restoreOffset(_persistedScrollOffset.value!,
          initialRestore: initialRestore);
    }
  }

  @override
  void saveOffset(double offset) {
    assert(debugIsSerializableForRestoration(offset));
    _persistedScrollOffset.value = offset;
    // [saveOffset] is called after a scrolling ends and it is usually not
    // followed by a frame. Therefore, manually flush restoration data.
    ServicesBinding.instance!.restorationManager.flushData();
  }

  @override
  void didChangeDependencies() {
    _updatePosition();
    super.didChangeDependencies();
  }

  bool _shouldUpdatePosition(Scrollable oldWidget) {
    return false;
  }

  @override
  void didUpdateWidget(Scrollable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.scrollableState = null;
      widget.controller?.scrollableState = null;
    }

    if (_shouldUpdatePosition(oldWidget)) _updatePosition();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.scrollableState = null;
  }

  @override
  void dispose() {
    widget.controller?.eventEmitter = null;
    widget.controller?.detach(position);
    position.dispose();
    _persistedScrollOffset.dispose();
    super.dispose();
  }

  // GESTURE RECOGNITION AND POINTER IGNORING

  final GlobalKey<RawGestureDetectorState> _gestureDetectorKey =
      GlobalKey<RawGestureDetectorState>();

  @override
  @protected
  void setCanDrag(bool canDrag) {}

  @override
  TickerProvider get vsync => this;

  @override
  @protected
  void setIgnorePointer(bool value) {}

  @override
  BuildContext? get notificationContext => _gestureDetectorKey.currentContext;

  @override
  BuildContext get storageContext => context;

  // DESCRIPTION

  @override
  Widget build(BuildContext context) {
    assert(_position != null);
    // _ScrollableScope must be placed above the BuildContext returned by notificationContext
    // so that we can get this ScrollableState by doing the following:
    //
    // ScrollNotification notification;
    // Scrollable.of(notification.context)
    //
    // Since notificationContext is pointing to _gestureDetectorKey.context, _ScrollableScope
    // must be placed above the widget using it: RawGestureDetector
    Widget result = _ScrollableScope(
      scrollable: this,
      position: position,
      child: widget.viewportBuilder(context, position),
    );

    return _configuration.buildViewportChrome(
        context, result, widget.axisDirection);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollPosition>('position', position));
    properties
        .add(DiagnosticsProperty<ScrollPhysics>('effective physics', _physics));
  }

  @override
  String? get restorationId => widget.restorationId;
}

/// With [_ScrollSemantics] certain child [SemanticsNode]s can be
/// excluded from the scrollable area for semantics purposes.
///
/// Nodes, that are to be excluded, have to be tagged with
/// [RenderViewport.excludeFromScrolling] and the [RenderAbstractViewport] in
/// use has to add the [RenderViewport.useTwoPaneSemantics] tag to its
/// [SemanticsConfiguration] by overriding
/// [RenderObject.describeSemanticsConfiguration].
///
/// If the tag [RenderViewport.useTwoPaneSemantics] is present on the viewport,
/// two semantics nodes will be used to represent the [Scrollable]: The outer
/// node will contain all children, that are excluded from scrolling. The inner
/// node, which is annotated with the scrolling actions, will house the
/// scrollable children.
class _ScrollSemantics extends SingleChildRenderObjectWidget {
  const _ScrollSemantics({
    Key? key,
    required this.position,
    required this.allowImplicitScrolling,
    required this.semanticChildCount,
    Widget? child,
  })  : assert(position != null),
        assert(semanticChildCount == null || semanticChildCount >= 0),
        super(key: key, child: child);

  final ScrollPosition position;
  final bool allowImplicitScrolling;
  final int? semanticChildCount;

  @override
  _RenderScrollSemantics createRenderObject(BuildContext context) {
    return _RenderScrollSemantics(
      position: position,
      allowImplicitScrolling: allowImplicitScrolling,
      semanticChildCount: semanticChildCount,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderScrollSemantics renderObject) {
    renderObject
      ..allowImplicitScrolling = allowImplicitScrolling
      ..position = position
      ..semanticChildCount = semanticChildCount;
  }
}

class _RenderScrollSemantics extends RenderProxyBox {
  _RenderScrollSemantics({
    required ScrollPosition position,
    required bool allowImplicitScrolling,
    required int? semanticChildCount,
    RenderBox? child,
  })  : _position = position,
        _allowImplicitScrolling = allowImplicitScrolling,
        _semanticChildCount = semanticChildCount,
        assert(position != null),
        super(child) {}

  /// Whether this render object is excluded from the semantic tree.
  ScrollPosition get position => _position;
  ScrollPosition _position;
  set position(ScrollPosition value) {
    assert(value != null);
    if (value == _position) return;
    _position = value;
  }

  /// Whether this node can be scrolled implicitly.
  bool get allowImplicitScrolling => _allowImplicitScrolling;
  bool _allowImplicitScrolling;
  set allowImplicitScrolling(bool value) {
    if (value == _allowImplicitScrolling) return;
    _allowImplicitScrolling = value;
  }

  int? get semanticChildCount => _semanticChildCount;
  int? _semanticChildCount;
  set semanticChildCount(int? value) {
    if (value == semanticChildCount) return;
    _semanticChildCount = value;
  }

  @override
  void clearSemantics() {
    super.clearSemantics();
  }
}

/// A typedef for a function that can calculate the offset for a type of scroll
/// increment given a [ScrollIncrementDetails].
///
/// This function is used as the type for [Scrollable.incrementCalculator],
/// which is called from a [ScrollAction].
typedef ScrollIncrementCalculator = double Function(
    ScrollIncrementDetails details);

/// Describes the type of scroll increment that will be performed by a
/// [ScrollAction] on a [Scrollable].
///
/// This is used to configure a [ScrollIncrementDetails] object to pass to a
/// [ScrollIncrementCalculator] function on a [Scrollable].
///
/// {@template flutter.widgets.ScrollIncrementType.intent}
/// This indicates the *intent* of the scroll, not necessarily the size. Not all
/// scrollable areas will have the concept of a "line" or "page", but they can
/// respond to the different standard key bindings that cause scrolling, which
/// are bound to keys that people use to indicate a "line" scroll (e.g.
/// control-arrowDown keys) or a "page" scroll (e.g. pageDown key). It is
/// recommended that at least the relative magnitudes of the scrolls match
/// expectations.
/// {@endtemplate}
enum ScrollIncrementType {
  /// Indicates that the [ScrollIncrementCalculator] should return the scroll
  /// distance it should move when the user requests to scroll by a "line".
  ///
  /// The distance a "line" scrolls refers to what should happen when the key
  /// binding for "scroll down/up by a line" is triggered. It's up to the
  /// [ScrollIncrementCalculator] function to decide what that means for a
  /// particular scrollable.
  line,

  /// Indicates that the [ScrollIncrementCalculator] should return the scroll
  /// distance it should move when the user requests to scroll by a "page".
  ///
  /// The distance a "page" scrolls refers to what should happen when the key
  /// binding for "scroll down/up by a page" is triggered. It's up to the
  /// [ScrollIncrementCalculator] function to decide what that means for a
  /// particular scrollable.
  page,
}

/// A details object that describes the type of scroll increment being requested
/// of a [ScrollIncrementCalculator] function, as well as the current metrics
/// for the scrollable.
class ScrollIncrementDetails {
  /// A const constructor for a [ScrollIncrementDetails].
  ///
  /// All of the arguments must not be null, and are required.
  const ScrollIncrementDetails({
    required this.type,
    required this.metrics,
  })  : assert(type != null),
        assert(metrics != null);

  /// The type of scroll this is (e.g. line, page, etc.).
  ///
  /// {@macro flutter.widgets.ScrollIncrementType.intent}
  final ScrollIncrementType type;

  /// The current metrics of the scrollable that is being scrolled.
  final ScrollMetrics metrics;
}

// Not using a RestorableDouble because we want to allow null values and override
// [enabled].
class _RestorableScrollOffset extends RestorableValue<double?> {
  @override
  double? createDefaultValue() => null;

  @override
  void didUpdateValue(double? oldValue) {
    notifyListeners();
  }

  @override
  double fromPrimitives(Object? data) {
    return data! as double;
  }

  @override
  Object? toPrimitives() {
    return value;
  }

  @override
  bool get enabled => value != null;
}
