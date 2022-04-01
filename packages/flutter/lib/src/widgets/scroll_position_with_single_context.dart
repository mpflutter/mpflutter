// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';
import 'framework.dart';
import 'scroll_activity.dart';
import 'scroll_context.dart';
import 'scroll_notification.dart';
import 'scroll_physics.dart';
import 'scroll_position.dart';

/// A scroll position that manages scroll activities for a single
/// [ScrollContext].
///
/// This class is a concrete subclass of [ScrollPosition] logic that handles a
/// single [ScrollContext], such as a [Scrollable]. An instance of this class
/// manages [ScrollActivity] instances, which change what content is visible in
/// the [Scrollable]'s [Viewport].
///
/// See also:
///
///  * [ScrollPosition], which defines the underlying model for a position
///    within a [Scrollable] but is agnostic as to how that position is
///    changed.
///  * [ScrollView] and its subclasses such as [ListView], which use
///    [ScrollPositionWithSingleContext] to manage their scroll position.
///  * [ScrollController], which can manipulate one or more [ScrollPosition]s,
///    and which uses [ScrollPositionWithSingleContext] as its default class for
///    scroll positions.
class ScrollPositionWithSingleContext extends ScrollPosition
    implements ScrollActivityDelegate {
  /// Create a [ScrollPosition] object that manages its behavior using
  /// [ScrollActivity] objects.
  ///
  /// The `initialPixels` argument can be null, but in that case it is
  /// imperative that the value be set, using [correctPixels], as soon as
  /// [applyNewDimensions] is invoked, before calling the inherited
  /// implementation of that method.
  ///
  /// If [keepScrollOffset] is true (the default), the current scroll offset is
  /// saved with [PageStorage] and restored it if this scroll position's scrollable
  /// is recreated.
  ScrollPositionWithSingleContext({
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        ) {}

  /// Velocity from a previous activity temporarily held by [hold] to potentially
  /// transfer to a next activity.
  double _heldPreviousVelocity = 0.0;

  @override
  AxisDirection get axisDirection =>
      context?.axisDirection ?? AxisDirection.down;

  @override
  void beginActivity(ScrollActivity? newActivity) {}

  @override
  void applyUserOffset(double delta) {}

  @override
  void goIdle() {}

  /// Start a physics-driven simulation that settles the [pixels] position,
  /// starting at a particular velocity.
  ///
  /// This method defers to [ScrollPhysics.createBallisticSimulation], which
  /// typically provides a bounce simulation when the current position is out of
  /// bounds and a friction simulation when the position is in bounds but has a
  /// non-zero velocity.
  ///
  /// The velocity should be in logical pixels per second.
  @override
  void goBallistic(double velocity) {}

  @override
  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  /// Set [userScrollDirection] to the given value.
  ///
  /// If this changes the value, then a [UserScrollNotification] is dispatched.
  @protected
  @visibleForTesting
  void updateUserScrollDirection(ScrollDirection value) {}

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) {
    return Future<void>.value();
  }

  @override
  void jumpTo(double value) {}

  @override
  void pointerScroll(double delta) {}

  @Deprecated(
      'This will lead to bugs.') // ignore: flutter_deprecation_syntax, https://github.com/flutter/flutter/issues/44609
  @override
  void jumpToWithoutSettling(double value) {}

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    final double previousVelocity = activity!.velocity;
    final HoldScrollActivity holdActivity = HoldScrollActivity(
      delegate: this,
      onHoldCanceled: holdCancelCallback,
    );
    beginActivity(holdActivity);
    _heldPreviousVelocity = previousVelocity;
    return holdActivity;
  }

  ScrollDragController? _currentDrag;

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    final ScrollDragController drag = ScrollDragController(
      delegate: this,
      details: details,
      onDragCanceled: dragCancelCallback,
      carriedVelocity: physics.carriedMomentum(_heldPreviousVelocity),
      motionStartDistanceThreshold: physics.dragStartDistanceMotionThreshold,
    );
    beginActivity(DragScrollActivity(this, drag));
    assert(_currentDrag == null);
    _currentDrag = drag;
    return drag;
  }

  @override
  void dispose() {
    _currentDrag?.dispose();
    _currentDrag = null;
    super.dispose();
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('${context.runtimeType}');
    description.add('$physics');
    description.add('$activity');
    description.add('$userScrollDirection');
  }
}
