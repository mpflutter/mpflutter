part of '../../mp_flutter_runtime.dart';

class _RefresherManager {
  static final _store = <int, Completer>{};

  static Completer createCompleter(int? hashCode) {
    if (hashCode == null) return Completer();
    _store[hashCode] = Completer();
    return _store[hashCode]!;
  }

  static Completer? findCompleter(int? hashCode) {
    if (hashCode == null) return null;
    return _store[hashCode];
  }
}
