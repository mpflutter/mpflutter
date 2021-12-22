import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class GridViewWaterfallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'GridViewWaterfall',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: WaterfallView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverWaterfallDelegate(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Container(
            height: 100 + 20 * (index % 5),
            color: Colors.blue,
            child: Center(child: Text('Index - $index')),
          );
        },
        itemCount: 100,
      ),
    );
  }
}
