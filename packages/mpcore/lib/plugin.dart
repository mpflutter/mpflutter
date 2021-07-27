part of './mpcore.dart';

abstract class MPPlugin {
  MPElement? encodeElement(Element element);
  void onClientMessage(Map message) {}
}
