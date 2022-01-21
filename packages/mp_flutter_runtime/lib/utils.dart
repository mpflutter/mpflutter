part of './mp_flutter_runtime.dart';

class _Utils {
  static dynamic toDouble(dynamic value, [double? defaultValue]) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  static dynamic toInt(dynamic value, [int? defaultValue]) {
    if (value is num) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  static Color toColor(dynamic value) {
    return Color(toInt(value) ?? 0);
  }
}
