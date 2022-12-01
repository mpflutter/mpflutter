import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class IndexedStackPage extends StatefulWidget {
  @override
  State<IndexedStackPage> createState() => _IndexedStackPageState();
}

class _IndexedStackPageState extends State<IndexedStackPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      body: IndexedStack(
        index: currentPage,
        children: [
          for (int i = 0; i < 3; i++)
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    currentPage++;
                    if (currentPage > 2) {
                      currentPage = 0;
                    }
                  });
                },
                child: Container(
                  key: Key('page$i'),
                  padding: EdgeInsets.all(120),
                  decoration: BoxDecoration(color: Colors.amber),
                  child: Text('Page $i'),
                ),
              ),
            )
        ],
      ),
    );
  }
}
