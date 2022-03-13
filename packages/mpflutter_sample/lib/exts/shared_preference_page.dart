import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencePage extends StatelessWidget {
  Widget _renderBlock(Widget child) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title) {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'SharedPreference',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Tap to set value into SharedPreference.'),
              GestureDetector(
                onTap: () async {
                  final result = await MPWebDialogs.prompt(
                    message: 'Input the value',
                    context: context,
                  );
                  if (result != null) {
                    (await SharedPreferences.getInstance()).setString(
                      'testKey',
                      result,
                    );
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Tap to get value from SharedPreference.'),
              GestureDetector(
                onTap: () async {
                  final value =
                      (await SharedPreferences.getInstance()).getString(
                    'testKey',
                  );
                  MPWebDialogs.alert(message: 'The value is = $value');
                },
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}
