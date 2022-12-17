part of '../../mp_flutter_runtime.dart';

class _ScrollControllerManager {
  static final _store = <int, ScrollController>{};

  static ScrollController createController(int? hashCode) {
    if (hashCode == null) return ScrollController();
    _store[hashCode] ??= ScrollController();
    return _store[hashCode]!;
  }

  static ScrollController? findController(int? hashCode) {
    if (hashCode == null) return null;
    return _store[hashCode];
  }
}
