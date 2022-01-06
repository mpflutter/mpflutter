part of '../mp_flutter_runtime.dart';

class _MPComponentFactory extends StatelessWidget {
  final Map? data;

  const _MPComponentFactory({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      String? name = data!['name'];
      if (name != null) {
        switch (name) {
          case 'mp_scaffold':
            return _MPScaffold(data: data);
          default:
        }
      }
    }
    return Container();
  }
}
