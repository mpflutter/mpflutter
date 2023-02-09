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
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          child: IndexedStack(
            index: currentPage,
            keepAlive: true,
            children: [
              for (int i = 0; i < 3; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPage++;
                      if (currentPage > 2) {
                        currentPage = 0;
                      }
                    });
                  },
                  child: _XXX(
                    key: Key('_$i'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _XXX extends StatefulWidget {
  const _XXX({
    Key? key,
  }) : super(key: key);

  @override
  State<_XXX> createState() => _XXXState();
}

class _XXXState extends State<_XXX> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemBuilder: ((context, index) {
        return Container(
          height: 44,
          child: Text('text - $index'),
        );
      }),
      itemCount: 100,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
