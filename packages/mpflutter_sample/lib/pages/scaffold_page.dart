import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ScaffoldPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'Scaffold',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      appBar: MPAppBar(
        context: context,
        title: Text(
          'AppBar',
          style: TextStyle(color: Colors.black),
        ),
        trailing: Container(
          width: 44,
          height: 44,
          child: Center(child: MPIcon(MaterialIcons.ac_unit)),
        ),
      ),
      body: Container(
        color: Colors.pink,
        child: Center(
          child: Text(
            'Body',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottomBar: Container(
        height: 44,
        color: Colors.blue,
        child: Center(
          child: Text(
            'BottomBar',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      floatingBody: Positioned(
        right: 20,
        bottom: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () {
              // Tap to show mpDialog
              showMPDialog(
                  barrierColor: Colors.black.withOpacity(0.5),
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return Stack(
                      children: [
                        Positioned(
                          top: 88,
                          right: 44,
                          child: ClipOval(
                            child: Container(
                              width: 44,
                              height: 44,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    );
                  });
            },
            child: Container(
              height: 44,
              width: 120,
              color: Colors.yellow,
              child: Center(
                child: Text(
                  'FloatingBody',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
