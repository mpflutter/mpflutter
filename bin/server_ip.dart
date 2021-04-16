part of 'mpflutter.dart';

Future<String> selectDebugIP() async {
  final allIPs = await NetworkInterface.list(type: InternetAddressType.IPv4);
  if (allIPs.isNotEmpty) {
    if (allIPs.length > 1) {
      print('Pick debug server IP:');
      final menu = Menu(allIPs.map((e) => e.addresses[0].address));
      final result = menu.choose();
      return result.value;
    } else {
      return allIPs[0].addresses[0].address;
    }
  }
  return null;
}
