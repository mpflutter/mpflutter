import 'package:flutter/widgets.dart';

class MPFlutterKeyboardObserver extends ChangeNotifier {

  static final shared = MPFlutterKeyboardObserver._();

  MPFlutterKeyboardObserver._();

  bool visible = false;
  double keyboardHeight = 0.0;

  void setKeyboardVisible(bool visible, double keyboardHeight) {
    if (this.visible == visible) {
      return;
    }
    this.visible = visible;
    this.keyboardHeight = keyboardHeight;
    notifyListeners();
  }

}