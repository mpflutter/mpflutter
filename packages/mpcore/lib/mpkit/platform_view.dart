part of 'mpkit.dart';

class MPPlatformView extends StatelessWidget {
  final String viewType;
  final Map<String, dynamic> viewAttributes;

  MPPlatformView({
    required this.viewType,
    this.viewAttributes = const {},
  });

  void onMessageFromPlatform(Map message) {}

  void sendMessageToPlatform(Map message) {}

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
