import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class TablePage extends StatelessWidget {
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
      name: 'Padding',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Table layout.'),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FixedColumnWidth(55),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.red),
                    children: [
                      Text('产品名称',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('产品型号',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('互换型号',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('数量',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue),
                    children: [
                      Text('环保机油滤清器'),
                      Text('5408103711000',
                          style: TextStyle(color: Colors.blue)),
                      Text('YG200-1012243B'),
                      Text('1'),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('环保机油滤清器'),
                      GestureDetector(
                        child: Text('5408103711000',
                            style: TextStyle(color: Colors.blue)),
                        onTap: () => Navigator.pushNamed(
                            context, '/oe-model/detail',
                            arguments: {'id': '5408103711000'}),
                      ),
                      Text('YG200-1012243B'),
                      Text('1'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}
