// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'basic.dart';
import 'binding.dart';
import 'framework.dart';
import 'navigator.dart';
import 'overlay.dart';
import 'pages.dart';
import 'routes.dart';
import 'ticker_provider.dart' show TickerMode;
import 'transitions.dart';

/// Signature for a function that takes two [Rect] instances and returns a
/// [RectTween] that transitions between them.
///
/// This is typically used with a [HeroController] to provide an animation for
/// [Hero] positions that looks nicer than a linear movement. For example, see
/// [MaterialRectArcTween].
typedef CreateRectTween = Tween<Rect?> Function(Rect? begin, Rect? end);

/// Signature for a function that builds a [Hero] placeholder widget given a
/// child and a [Size].
///
/// The child can optionally be part of the returned widget tree. The returned
/// widget should typically be constrained to [heroSize], if it doesn't do so
/// implicitly.
///
/// See also:
///
///  * [TransitionBuilder], which is similar but only takes a [BuildContext]
///    and a child widget.
typedef HeroPlaceholderBuilder = Widget Function(
  BuildContext context,
  Size heroSize,
  Widget child,
);

/// A function that lets [Hero]es self supply a [Widget] that is shown during the
/// hero's flight from one route to another instead of default (which is to
/// show the destination route's instance of the Hero).
typedef HeroFlightShuttleBuilder = Widget Function(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
);

/// Direction of the hero's flight based on the navigation operation.
enum HeroFlightDirection {
  /// A flight triggered by a route push.
  ///
  /// The animation goes from 0 to 1.
  ///
  /// If no custom [HeroFlightShuttleBuilder] is supplied, the top route's
  /// [Hero] child is shown in flight.
  push,

  /// A flight triggered by a route pop.
  ///
  /// The animation goes from 1 to 0.
  ///
  /// If no custom [HeroFlightShuttleBuilder] is supplied, the bottom route's
  /// [Hero] child is shown in flight.
  pop,
}

/// A widget that marks its child as being a candidate for
/// [hero animations](https://flutter.dev/docs/development/ui/animations/hero-animations).
///
/// When a [PageRoute] is pushed or popped with the [Navigator], the entire
/// screen's content is replaced. An old route disappears and a new route
/// appears. If there's a common visual feature on both routes then it can
/// be helpful for orienting the user for the feature to physically move from
/// one page to the other during the routes' transition. Such an animation
/// is called a *hero animation*. The hero widgets "fly" in the Navigator's
/// overlay during the transition and while they're in-flight they're, by
/// default, not shown in their original locations in the old and new routes.
///
/// To label a widget as such a feature, wrap it in a [Hero] widget. When
/// navigation happens, the [Hero] widgets on each route are identified
/// by the [HeroController]. For each pair of [Hero] widgets that have the
/// same tag, a hero animation is triggered.
///
/// If a [Hero] is already in flight when navigation occurs, its
/// flight animation will be redirected to its new destination. The
/// widget shown in-flight during the transition is, by default, the
/// destination route's [Hero]'s child.
///
/// For a Hero animation to trigger, the Hero has to exist on the very first
/// frame of the new page's animation.
///
/// Routes must not contain more than one [Hero] for each [tag].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=Be9UH1kXFDw}
///
/// ## Discussion
///
/// Heroes and the [Navigator]'s [Overlay] [Stack] must be axis-aligned for
/// all this to work. The top left and bottom right coordinates of each animated
/// Hero will be converted to global coordinates and then from there converted
/// to that [Stack]'s coordinate space, and the entire Hero subtree will, for
/// the duration of the animation, be lifted out of its original place, and
/// positioned on that stack. If the [Hero] isn't axis aligned, this is going to
/// fail in a rather ugly fashion. Don't rotate your heroes!
///
/// To make the animations look good, it's critical that the widget tree for the
/// hero in both locations be essentially identical. The widget of the *target*
/// is, by default, used to do the transition: when going from route A to route
/// B, route B's hero's widget is placed over route A's hero's widget. If a
/// [flightShuttleBuilder] is supplied, its output widget is shown during the
/// flight transition instead.
///
/// By default, both route A and route B's heroes are hidden while the
/// transitioning widget is animating in-flight above the 2 routes.
/// [placeholderBuilder] can be used to show a custom widget in their place
/// instead once the transition has taken flight.
///
/// During the transition, the transition widget is animated to route B's hero's
/// position, and then the widget is inserted into route B. When going back from
/// B to A, route A's hero's widget is, by default, placed over where route B's
/// hero's widget was, and then the animation goes the other way.
///
/// ### Nested Navigators
///
/// If either or both routes contain nested [Navigator]s, only [Hero]es
/// contained in the top-most routes (as defined by [Route.isCurrent]) *of those
/// nested [Navigator]s* are considered for animation. Just like in the
/// non-nested case the top-most routes containing these [Hero]es in the nested
/// [Navigator]s have to be [PageRoute]s.
///
/// ## Parts of a Hero Transition
///
/// ![Diagrams with parts of the Hero transition.](https://flutter.github.io/assets-for-api-docs/assets/interaction/heroes.png)
class Hero extends StatefulWidget {
  /// Create a hero.
  ///
  /// The [tag] and [child] parameters must not be null.
  /// The [child] parameter and all of the its descendants must not be [Hero]es.
  const Hero({
    Key? key,
    required this.tag,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
    required this.child,
  })  : assert(tag != null),
        assert(transitionOnUserGestures != null),
        assert(child != null),
        super(key: key);

  /// The identifier for this particular hero. If the tag of this hero matches
  /// the tag of a hero on a [PageRoute] that we're navigating to or from, then
  /// a hero animation will be triggered.
  final Object tag;

  /// Defines how the destination hero's bounds change as it flies from the starting
  /// route to the destination route.
  ///
  /// A hero flight begins with the destination hero's [child] aligned with the
  /// starting hero's child. The [Tween<Rect>] returned by this callback is used
  /// to compute the hero's bounds as the flight animation's value goes from 0.0
  /// to 1.0.
  ///
  /// If this property is null, the default, then the value of
  /// [HeroController.createRectTween] is used. The [HeroController] created by
  /// [MaterialApp] creates a [MaterialRectArcTween].
  final CreateRectTween? createRectTween;

  /// The widget subtree that will "fly" from one route to another during a
  /// [Navigator] push or pop transition.
  ///
  /// The appearance of this subtree should be similar to the appearance of
  /// the subtrees of any other heroes in the application with the same [tag].
  /// Changes in scale and aspect ratio work well in hero animations, changes
  /// in layout or composition do not.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Optional override to supply a widget that's shown during the hero's flight.
  ///
  /// This in-flight widget can depend on the route transition's animation as
  /// well as the incoming and outgoing routes' [Hero] descendants' widgets and
  /// layout.
  ///
  /// When both the source and destination [Hero]es provide a [flightShuttleBuilder],
  /// the destination's [flightShuttleBuilder] takes precedence.
  ///
  /// If none is provided, the destination route's Hero child is shown in-flight
  /// by default.
  ///
  /// ## Limitations
  ///
  /// If a widget built by [flightShuttleBuilder] takes part in a [Navigator]
  /// push transition, that widget or its descendants must not have any
  /// [GlobalKey] that is used in the source Hero's descendant widgets. That is
  /// because both subtrees will be included in the widget tree during the Hero
  /// flight animation, and [GlobalKey]s must be unique across the entire widget
  /// tree.
  ///
  /// If the said [GlobalKey] is essential to your application, consider providing
  /// a custom [placeholderBuilder] for the source Hero, to avoid the [GlobalKey]
  /// collision, such as a builder that builds an empty [SizedBox], keeping the
  /// Hero [child]'s original size.
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  /// Placeholder widget left in place as the Hero's [child] once the flight takes
  /// off.
  ///
  /// By default the placeholder widget is an empty [SizedBox] keeping the Hero
  /// child's original size, unless this Hero is a source Hero of a [Navigator]
  /// push transition, in which case [child] will be a descendant of the placeholder
  /// and will be kept [Offstage] during the Hero's flight.
  final HeroPlaceholderBuilder? placeholderBuilder;

  /// Whether to perform the hero transition if the [PageRoute] transition was
  /// triggered by a user gesture, such as a back swipe on iOS.
  ///
  /// If [Hero]es with the same [tag] on both the from and the to routes have
  /// [transitionOnUserGestures] set to true, a back swipe gesture will
  /// trigger the same hero animation as a programmatically triggered push or
  /// pop.
  ///
  /// The route being popped to or the bottom route must also have
  /// [PageRoute.maintainState] set to true for a gesture triggered hero
  /// transition to work.
  ///
  /// Defaults to false and cannot be null.
  final bool transitionOnUserGestures;

  @override
  _HeroState createState() => _HeroState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('tag', tag));
  }
}

/// The [Hero] widget displays different content based on whether it is in an
/// animated transition ("flight"), from/to another [Hero] with the same tag:
///   * When [startFlight] is called, the real content of this [Hero] will be
///     replaced by a "placeholder" widget.
///   * When the flight ends, the "toHero"'s [endFlight] method must be called
///     by the hero controller, so the real content of that [Hero] becomes
///     visible again when the animation completes.
class _HeroState extends State<Hero> {
  final GlobalKey _key = GlobalKey();
  Size? _placeholderSize;
  // Whether the placeholder widget should wrap the hero's child widget as its
  // own child, when `_placeholderSize` is non-null (i.e. the hero is currently
  // in its flight animation). See `startFlight`.
  bool _shouldIncludeChild = true;

  // The `shouldIncludeChildInPlaceholder` flag dictates if the child widget of
  // this hero should be included in the placeholder widget as a descendant.
  //
  // When a new hero flight animation takes place, a placeholder widget
  // needs to be built to replace the original hero widget. When
  // `shouldIncludeChildInPlaceholder` is set to true and `widget.placeholderBuilder`
  // is null, the placeholder widget will include the original hero's child
  // widget as a descendant, allowing the original element tree to be preserved.
  //
  // It is typically set to true for the *from* hero in a push transition,
  // and false otherwise.
  void startFlight({bool shouldIncludedChildInPlaceholder = false}) {
    _shouldIncludeChild = shouldIncludedChildInPlaceholder;
    assert(mounted);
    final RenderBox box = context.findRenderObject()! as RenderBox;
    assert(box != null && box.hasSize);
    setState(() {
      _placeholderSize = box.size;
    });
  }

  // When `keepPlaceholder` is true, the placeholder will continue to be shown
  // after the flight ends. Otherwise the child of the Hero will become visible
  // and its TickerMode will be re-enabled.
  //
  // This method can be safely called even when this [Hero] is currently not in
  // a flight.
  void endFlight({bool keepPlaceholder = false}) {
    if (keepPlaceholder || _placeholderSize == null) return;

    _placeholderSize = null;
    if (mounted) {
      // Tell the widget to rebuild if it's mounted. _paceholderSize has already
      // been updated.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
