import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class GridViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'GridView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: MPRefreshIndicator(
        onRefresh: (key) async {
          print('start refresh');
          await Future.delayed(Duration(seconds: 5));
          print('end refresh');
        },
        child: GridView.builder(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.0,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/gridView');
                },
                child: Container(
                  color: Colors.orange,
                ),
              );
            }
            return Container(
              color: Colors.blue,
              child: Center(
                  child: Text(
                'Index - $index',
                style: TextStyle(
                  fontSize: 16,
                ),
              )),
            );
          },
          itemCount: 500,
        ),
      ),
    );
  }
}
