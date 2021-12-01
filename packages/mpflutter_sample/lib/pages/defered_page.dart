import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class DeferedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'DeferedPage',
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.blue,
          child: Center(
            child: Text(
              'Hello, Defered Page!',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
