library mpcore;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/ui/src/mock_engine/device_info.dart';
import 'package:flutter/ui/ui.dart' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'channel/channel_io.dart'
    if (dart.library.js) './channel/channel_js.dart';
import './mpkit/mpkit.dart';
import 'mpkit/encoder/mpkit_encoder.dart';
import './mpjs/mpjs.dart' as mpjs;

export './mpkit/mpkit.dart';

part 'document.dart';
part 'plugin.dart';
part 'components/coord.dart';
part './components/absorb_pointer.dart';
part './components/custom_scroll_view.dart';
part './components/gesture_detector.dart';
part './components/opacity.dart';
part './components/sliver_list.dart';
part './components/sliver_grid.dart';
part './components/decorated_box.dart';
part './components/icon.dart';
part './components/overlay.dart';
part './components/clip_oval.dart';
part './components/div_box.dart';
part './components/ignore_pointer.dart';
part './components/clip_r_rect.dart';
part './components/image.dart';
part './components/rich_text.dart';
part './components/transform.dart';
part './components/colored_box.dart';
part './components/list_view.dart';
part './components/grid_view.dart';
part './components/visibility.dart';
part './components/offstage.dart';
part './components/editable_text.dart';
part './components/action.dart';
part './components/sliver_persistent_header.dart';
part './components/web_dialogs.dart';
part './components/custom_paint.dart';
part './channel/channel_base.dart';

class MPCore {
  static NavigatorObserver getNavigationObserver() {
    return MPNavigatorObserver.instance;
  }

  static final _plugins = <MPPlugin>[];

  static void registerPlugin(MPPlugin plugin) {
    _plugins.add(plugin);
  }

  Element get renderView => WidgetsBinding.instance!.renderViewElement!;

  final Set<int> _diffableElements = {};

  void connectToHostChannel() async {
    if (kReleaseMode) {
      injectErrorWidget();
      injectMethodChannelHandler();
      final _ = MPChannel.setupHotReload(this);
      var pass = false;
      while (!pass) {
        await Future.delayed(Duration(milliseconds: 10));
        try {
          markNeedsBuild(renderView);
          clearOldFrameObject();
          pass = true;
          // ignore: empty_catches
        } catch (e) {}
      }
      while (true) {
        try {
          await sendFrame();
        } catch (e) {
          print(e);
        }
      }
    } else {
      await runZonedGuarded(() async {
        injectErrorWidget();
        injectMethodChannelHandler();
        final _ = MPChannel.setupHotReload(this);
        var pass = false;
        while (!pass) {
          await Future.delayed(Duration(milliseconds: 10));
          try {
            markNeedsBuild(renderView);
            clearOldFrameObject();
            pass = true;
            // ignore: empty_catches
          } catch (e) {}
        }
        while (true) {
          try {
            await sendFrame();
          } catch (e) {
            print(e);
          }
        }
      }, (error, stackTrace) {
        print('Unccaught exception: $error, $stackTrace.');
      });
    }
  }

  void injectErrorWidget() {
    ErrorWidget.builder = (error) {
      print(error);
      return MPScaffold(
        backgroundColor: Color.fromARGB(255, 115, 0, 2),
        body: ListView(
          padding: const EdgeInsets.all(12.0),
          children: [
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 14,
              ),
            )
          ],
        ),
      );
    };
  }

  void injectMethodChannelHandler() {
    ui.pluginMessageCallHandler = (method, data, callback) async {
      final uint8Data = data?.buffer.asUint8List();
      final base64Data = uint8Data != null ? base64.encode(uint8Data) : null;
      if (await mpjs.context
          .hasProperty('mp_core_methodChannelHandlerWebOnly')) {
        if (data != null) {
          final methodMessage = StandardMethodCodec().decodeMethodCall(data);
          await mpjs.context.callMethod('mp_core_methodChannelHandlerWebOnly', [
            method,
            methodMessage.method,
            methodMessage.arguments,
            (response) {
              if (callback != null && response is String) {
                if (response == 'NOTIMPLEMENTED' ||
                    response.startsWith('ERROR:')) {
                  callback(
                    StandardMethodCodec().encodeErrorEnvelope(
                      code: response,
                      message: response,
                    ),
                  );
                } else {
                  callback(
                    StandardMethodCodec()
                        .encodeSuccessEnvelope(json.decode(response)),
                  );
                }
              }
            }
          ]);
        } else {
          callback?.call(null);
        }
      } else {
        await mpjs.context.callMethod('mp_core_methodChannelHandler', [
          method,
          base64Data,
          (response) {
            if (callback != null && response is String) {
              callback(base64.decode(response).buffer.asByteData());
            }
          }
        ]);
      }
    };
  }

  Future handleHotReload() async {
    try {
      markNeedsBuild(renderView);
      clearOldFrameObject();
    } catch (e) {
      print(e);
    }
  }

  static void clearOldFrameObject() {
    MPElement._elementCache.clear();
    MPElement._elementCacheNext.clear();
  }

  static void cancelTextMeasureTask(String reason) {
    if (_onMeasureCompleter != null) {
      _onMeasureCompleter!.completeError(reason);
      _onMeasureCompleter = null;
    }
  }

  Future sendFrame() async {
    await nextFrame();
    while (BuildOwner.beingMeasureElements.isNotEmpty) {
      try {
        BuildOwner.beingMeasureElements
            .removeWhere((element) => element.isInactive());
        if (BuildOwner.beingMeasureElements.isEmpty) break;
        await sendTextMeasureFrame();
        WidgetsBinding.instance!.scheduleFrame();
        await nextFrame();
        // ignore: empty_catches
      } catch (e) {}
    }
    final recentDirtyElements = BuildOwner.recentDirtyElements
        .where((element) {
          return element.isInactive() != true &&
              ModalRoute.of(element)?.isCurrent == true;
        })
        .map((e) {
          Element? currentE = e;
          while (currentE != null &&
              (currentE is StatefulElement || currentE is StatelessElement)) {
            currentE = findFirstChild(currentE);
          }
          return currentE;
        })
        .whereType<Element>()
        .toList();
    _Document? diffDoc;
    if (recentDirtyElements.isNotEmpty &&
        recentDirtyElements
            .every((element) => _diffableElements.contains(element.hashCode))) {
      diffDoc = toDiffDocument(recentDirtyElements);
    }
    if (diffDoc != null) {
      final diffFrameData = json.encode({
        'type': 'diff_data',
        'message': diffDoc,
      });
      final frameData = diffFrameData;
      MPChannel.postMesssage(frameData);
    } else {
      final doc = toDocument();
      _diffableElements.clear();
      if (doc != null) {
        _updateDiffableDocument(doc);
      }
      final newFrameData = json.encode({
        'type': 'frame_data',
        'message': doc,
      });
      final frameData = newFrameData;
      MPChannel.postMesssage(frameData);
    }
    BuildOwner.recentDirtyElements.clear();
    MPElement._elementCache.addAll(MPElement._elementCacheNext);
    MPElement._elementCacheNext.clear();
    MPElement.runElementCacheGC();
    if (MPElement._invalidElements.isNotEmpty) {
      final gcData = json.encode({
        'type': 'element_gc',
        'message': MPElement._invalidElements,
      });
      MPChannel.postMesssage(gcData);
      MPElement._invalidElements.clear();
    }
  }

  Future sendTextMeasureFrame() async {
    MPElement.disableElementCache = true;
    final measureFrameData = json.encode({
      'type': 'rich_text',
      'message': {
        'event': 'doMeasure',
        'items': BuildOwner.beingMeasureElements
            .map((e) => MPElement.fromFlutterElement(e))
            .toList(),
      }
    });
    MPElement.disableElementCache = false;
    MPChannel.postMesssage(measureFrameData);
    final completer = Completer();
    _loopCheckMeasureCompleter();
    _onMeasureCompleter = completer;
    return completer.future;
  }

  void _loopCheckMeasureCompleter() async {
    await Future.delayed(Duration(seconds: 2));
    BuildOwner.beingMeasureElements
        .removeWhere((element) => element.isInactive());
    if (_onMeasureCompleter != null &&
        BuildOwner.beingMeasureElements.isEmpty) {
      _onMeasureCompleter!.completeError('No element for text measure.');
    } else if (_onMeasureCompleter != null &&
        BuildOwner.beingMeasureElements.isNotEmpty) {
      _loopCheckMeasureCompleter();
    }
  }

  Future nextFrame() async {
    final completer = Completer();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      completer.complete();
    });
    return completer.future;
  }

  _Document toDiffDocument(List<Element> diffsElement) {
    return _Document(
      routeId: ModalRoute.of(diffsElement[0])?.hashCode ?? 0,
      diffs: diffsElement.map((e) => MPElement.fromFlutterElement(e)).toList(),
    );
  }

  _Document? toDocument() {
    Element? activeScaffoldElement;
    final scaffoldElements = <Element>[];
    final overlays = <MPElement>[];
    ModalRoute? activeOverlayParentRoute;
    scaffoldStates.forEach((state) {
      if (state.mounted && ModalRoute.of(state.context)?.isCurrent == true) {
        if (state.widget is MPOverlayScaffold) {
          activeOverlayParentRoute =
              (state.widget as MPOverlayScaffold).parentRoute;
        }
        scaffoldElements.add(state.context as Element);
      }
    });
    if (activeOverlayParentRoute != null) {
      scaffoldStates.forEach((state) {
        if (state.mounted &&
            ModalRoute.of(state.context) == activeOverlayParentRoute) {
          final el = state.context as Element;
          scaffoldElements.add(el);
        }
      });
    }
    activeOverlayParentRoute = null;
    for (var scaffoldElement in scaffoldElements) {
      if (scaffoldElement.widget is MPOverlayScaffold) {
        overlays.add(_encodeOverlay(scaffoldElement));
      } else if (scaffoldElement.widget is MPScaffold) {
        if (scaffoldElement.findAncestorWidgetOfExactType<MPScaffold>() !=
            null) {
          continue;
        }
        activeScaffoldElement = scaffoldElement;
      }
    }
    if (activeScaffoldElement != null) {
      final vDocument = _Document(
        routeId: ModalRoute.of(activeScaffoldElement)?.hashCode ?? 0,
        scaffold: (() {
          if (activeScaffoldElement == null) return null;
          return MPElement.fromFlutterElement(activeScaffoldElement);
        })(),
        overlays: overlays,
      );
      return vDocument;
    } else {
      return null;
    }
  }

  void _updateDiffableDocument(_Document document) {
    final scaffold = document.scaffold;
    if (scaffold != null) {
      scaffold.attributes?.forEach((key, value) {
        if (value is MPElement) {
          _updateDiffableElement(value);
        }
      });
    }
  }

  void _updateDiffableElement(MPElement element) {
    _diffableElements.add(element.hashCode);
    element.children?.forEach((element) {
      _updateDiffableElement(element);
    });
  }

  static Element? findTarget<T>(
    Element? element, {
    bool findParent = false,
    int? maxDepth,
  }) {
    if (maxDepth != null && maxDepth < 0) {
      return null;
    }
    if (element == null) {
      return null;
    }
    Element? targetElement;
    element.visitChildElements((el) {
      if (targetElement != null) return;
      if (el.widget is T) {
        if (findParent == true) {
          targetElement = element;
        } else {
          targetElement = el;
        }
      } else {
        final next = findTarget<T>(
          el,
          findParent: findParent,
          maxDepth: maxDepth != null ? maxDepth - 1 : null,
        );
        if (next != null) {
          targetElement = next;
        }
      }
    });
    return targetElement;
  }

  static void findTargets<T>(Element element,
      {required List out, bool findParent = false}) {
    element.visitChildElements((el) {
      if (el.widget is T) {
        if (findParent == true) {
          out.add(element);
        } else {
          out.add(el);
        }
      }
      findTargets<T>(el, out: out, findParent: findParent);
    });
  }

  static ModalRoute? activeOverlayParentRoute;

  static void findTargetsTwo<T, U>(
    Element element, {
    required List out,
    bool findParent = false,
    bool mustCurrentRoute = false,
  }) {
    var els = <Element>[];
    element.visitChildElements((el) {
      els.add(el);
    });
    els.reversed.forEach((el) {
      if (el.widget is T || el.widget is U) {
        if (mustCurrentRoute &&
            ModalRoute.of(el)?.isCurrent != true &&
            ModalRoute.of(el) != activeOverlayParentRoute) {
          if (!(el.widget is MPOverlayScaffold)) {
            return;
          }
        }
        if ((el.widget is MPOverlayScaffold)) {
          activeOverlayParentRoute =
              (el.widget as MPOverlayScaffold).parentRoute;
        }
        if (findParent == true) {
          out.add(element);
        } else {
          out.add(el);
        }
      }
      findTargetsTwo<T, U>(
        el,
        out: out,
        findParent: findParent,
        mustCurrentRoute: mustCurrentRoute,
      );
    });
  }

  static Map<int, Element> hashCodeCache = {};

  static void addElementToHashCodeCache(Element element) {
    if (hashCodeCache[element.hashCode] != null) return;
    hashCodeCache[element.hashCode] = element;
    hashCodeCache.removeWhere((key, value) => value.owner == null);
  }

  static Element? findTargetHashCode(
    int? hashCode, {
    Element? element,
  }) {
    if (hashCode == null) return null;
    if (hashCodeCache[hashCode] != null) {
      return hashCodeCache[hashCode];
    }
    element ??= WidgetsBinding.instance?.renderViewElement;
    Element? targetElement;
    element?.visitChildElements((el) {
      if (el.hashCode == hashCode || el.widget.hashCode == hashCode) {
        targetElement = el;
      } else {
        final next = findTargetHashCode(hashCode, element: el);
        if (next != null) {
          targetElement = next;
        }
      }
    });
    return targetElement;
  }

  static TextSpan? findTargetTextSpanHashCode(
    int hashCode, {
    InlineSpan? element,
  }) {
    if (element.hashCode == hashCode && element is TextSpan) {
      return element;
    } else {
      TextSpan? next;
      // ignore: deprecated_member_use
      element?.children?.forEach((span) {
        next ??= findTargetTextSpanHashCode(hashCode, element: span);
      });
      if (next != null) {
        return next;
      } else {
        return null;
      }
    }
  }

  static Element? findTargetKey(
    Key key,
    Element element, {
    bool findParent = false,
    int? maxDepth,
  }) {
    if (maxDepth != null && maxDepth < 0) {
      return null;
    }
    Element? targetElement;
    element.visitChildElements((el) {
      if (el.widget.key == key) {
        if (findParent == true) {
          targetElement = element;
        } else {
          targetElement = el;
        }
      } else {
        final next = findTargetKey(
          key,
          el,
          findParent: findParent,
          maxDepth: maxDepth != null ? maxDepth - 1 : null,
        );
        if (next != null) {
          targetElement = next;
        }
      }
    });
    return targetElement;
  }

  static Element? findFirstChild(Element element) {
    Element? targetElement;
    element.visitChildElements((el) {
      targetElement ??= el;
    });
    return targetElement;
  }

  static void markNeedsBuild(Element element) {
    element.markNeedsBuild();
    element.visitChildElements((el) {
      markNeedsBuild(el);
    });
  }

  static void printElement(Element element, {int level = 0}) {
    element.visitChildElements((el) {
      print(level);
      print(el);
      printElement(el, level: level + 1);
    });
  }
}
