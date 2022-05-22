import 'package:flutter/material.dart';
import 'package:flutter/ui/ui.dart';

abstract class Theme {
  static Theme of(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? DarkTheme()
        : LightTheme();
  }

  Color get appBarColor;
  Color get backgroundColor;
  Color get segmentBackgroundColor;
  Color get textColor;
  Color get seperatorColor;
}

class LightTheme implements Theme {
  @override
  Color get appBarColor => Colors.white;

  @override
  Color get backgroundColor => Color.fromARGB(255, 236, 236, 236);

  @override
  Color get textColor => Color(0xff000000);

  @override
  Color get segmentBackgroundColor => Color(0xffffffff);

  @override
  Color get seperatorColor => Colors.black.withOpacity(0.05);
}

class DarkTheme extends Theme {
  @override
  Color get appBarColor => Color(0xff222222);

  @override
  Color get backgroundColor => Color(0xff222222);

  @override
  Color get textColor => Color(0xffffffff);

  @override
  Color get segmentBackgroundColor => Color(0xff333333);

  @override
  Color get seperatorColor => Colors.white.withOpacity(0.05);
}
