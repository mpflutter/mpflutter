// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';
import 'binding.dart';
import 'container.dart';
import 'framework.dart';

/// A widget that visualizes the semantics for the child.
///
/// This widget is useful for understand how an app presents itself to
/// accessibility technology.
class SemanticsDebugger extends StatefulWidget {
  /// Creates a widget that visualizes the semantics for the child.
  ///
  /// The [child] argument must not be null.
  ///
  /// [labelStyle] dictates the [TextStyle] used for the semantics labels.
  const SemanticsDebugger({
    Key? key,
    required this.child,
    this.labelStyle = const TextStyle(
      color: Color(0xFF000000),
      fontSize: 10.0,
      height: 0.8,
    ),
  })  : assert(child != null),
        assert(labelStyle != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The [TextStyle] to use when rendering semantics labels.
  final TextStyle labelStyle;

  @override
  _SemanticsDebuggerState createState() => _SemanticsDebuggerState();
}

class _SemanticsDebuggerState extends State<SemanticsDebugger>
    with WidgetsBindingObserver {
  late _SemanticsClient _client;

  @override
  void initState() {
    super.initState();
    // TODO(abarth): We shouldn't reach out to the WidgetsBinding.instance
    // static here because we might not be in a tree that's attached to that
    // binding. Instead, we should find a way to get to the PipelineOwner from
    // the BuildContext.
    _client = _SemanticsClient(WidgetsBinding.instance!.pipelineOwner)
      ..addListener(_update);
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    _client
      ..removeListener(_update)
      ..dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      // The root transform may have changed, we have to repaint.
    });
  }

  void _update() {
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      // Semantic information are only available at the end of a frame and our
      // only chance to paint them on the screen is the next frame. To achieve
      // this, we call setState() in a post-frame callback.
      if (mounted) {
        // If we got disposed this frame, we will still get an update,
        // because the inactive list is flushed after the semantics updates
        // are transmitted to the semantics clients.
        setState(() {
          // The generation of the _SemanticsDebuggerListener has changed.
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SemanticsClient extends ChangeNotifier {
  _SemanticsClient(PipelineOwner pipelineOwner) {}

  @override
  void dispose() {
    super.dispose();
  }

  int generation = 0;

  void _didUpdateSemantics() {
    generation += 1;
    notifyListeners();
  }
}
