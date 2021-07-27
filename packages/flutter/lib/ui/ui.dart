// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This library defines the web equivalent of the native dart:ui.
///
/// All types in this library are public.

library dart.ui;

import 'dart:async';
import 'dart:collection' as collection;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import './src/mock_engine/request_animation_frame_io.dart'
    if (dart.library.js) './src/mock_engine/request_animation_frame_js.dart';
import 'src/mock_engine/device_info.dart';

part 'src/ui/annotations.dart';
part 'src/ui/canvas.dart';
part 'src/ui/channel_buffers.dart';
part 'src/ui/compositing.dart';
part 'src/ui/geometry.dart';
part 'src/ui/hash_codes.dart';
part 'src/ui/initialization.dart';
part 'src/ui/lerp.dart';
part 'src/ui/natives.dart';
part 'src/ui/painting.dart';
part 'src/ui/path.dart';
part 'src/ui/path_metrics.dart';
part 'src/ui/pointer.dart';
part 'src/ui/test_embedding.dart';
part 'src/ui/text.dart';
part 'src/ui/tile_mode.dart';
part 'src/ui/window.dart';

part 'src/mock_engine/window.dart';
part 'src/mock_engine/path.dart';
part 'src/mock_engine/layer_builder.dart';
part 'src/mock_engine/canvas.dart';
part 'src/mock_engine/text.dart';
part 'src/mock_engine/painting.dart';
part 'src/mock_engine/util.dart';
part 'src/mock_engine/color_filter.dart';
part 'src/mock_engine/vector_math.dart';

/// Provides a compile time constant to customize flutter framework and other
/// users of ui engine for web runtime.
const bool isWeb = true;

/// Web specific SMI. Used by bitfield. The 0x3FFFFFFFFFFFFFFF used on VM
/// is not supported on Web platform.
const int kMaxUnsignedSMI = -1;

void webOnlyInitializeEngine() {}

void webOnlySetPluginHandler(
    Future<void> Function(String, ByteData?, PlatformMessageResponseCallback?)
        handler) {
  pluginMessageCallHandler = handler;
}

// TODO(yjbanov): The code below was temporarily moved from lib/web_ui/lib/src/engine/platform_views.dart
//                during the NNBD migration so that `dart:ui` does not have to export `dart:_engine`. NNBD
//                does not allow exported non-migrated libraries from migrated libraries. When `dart:_engine`
//                is migrated, we can move it back.

/// A registry for factories that create platform views.
class PlatformViewRegistry {
  final Map<String, PlatformViewFactory> registeredFactories =
      <String, PlatformViewFactory>{};

  final Map<int, dynamic> _createdViews = <int, dynamic>{};

  /// Private constructor so this class can be a singleton.
  PlatformViewRegistry._();

  /// Register [viewTypeId] as being creating by the given [factory].
  bool registerViewFactory(String viewTypeId, PlatformViewFactory factory) {
    if (registeredFactories.containsKey(viewTypeId)) {
      return false;
    }
    registeredFactories[viewTypeId] = factory;
    return true;
  }

  /// Returns the view that has been created with the given [id], or `null` if
  /// no such view exists.
  dynamic? getCreatedView(int id) {
    return _createdViews[id];
  }
}

/// A function which takes a unique [id] and creates an HTML element.
typedef PlatformViewFactory = dynamic Function(int viewId);

/// The platform view registry for this app.
final PlatformViewRegistry platformViewRegistry = PlatformViewRegistry._();

/// Handles a platform call to `flutter/platform_views`.
///
/// Used to create platform views.
void handlePlatformViewCall(
  ByteData data,
  PlatformMessageResponseCallback callback,
) {}

void _createPlatformView(
    dynamic methodCall, PlatformMessageResponseCallback callback) {}

void _disposePlatformView(
    dynamic methodCall, PlatformMessageResponseCallback callback) {}

// TODO(yjbanov): remove _Callback, _Callbacker, and _futurize. They are here only
//                because the analyzer wasn't able to infer the correct types during
//                NNBD migration.
typedef _Callback<T> = void Function(T result);
typedef _Callbacker<T> = String? Function(_Callback<T> callback);
Future<T> _futurize<T>(_Callbacker<T> callbacker) {
  final Completer<T> completer = Completer<T>.sync();
  final String? error = callbacker((T t) {
    if (t == null) {
      completer.completeError(Exception('operation failed'));
    } else {
      completer.complete(t);
    }
  });
  if (error != null) {
    throw Exception(error);
  }
  return completer.future;
}
