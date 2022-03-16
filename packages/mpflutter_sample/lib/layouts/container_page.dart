import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ContainerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      body: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FlexColumnWidth(),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3: FixedColumnWidth(28),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.red),
            children: [
              TableCell(
                child: Text('产品名称',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              TableCell(
                child: Text('产品型号',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              TableCell(
                child: Text('互换型号',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              TableCell(
                child: Text('数量',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          // TableRow(decoration: BoxDecoration(color: Colors.blue), children: [
          //   Text('环保机油滤清器'),
          //   Text('5408103711000', style: TextStyle(color: Colors.blue)),
          //   Text('YG200-1012243B'),
          //   Text('1'),
          // ]),
          // TableRow(children: [
          //   Text('环保机油滤清器'),
          //   GestureDetector(
          //     child:
          //         Text('5408103711000', style: TextStyle(color: Colors.blue)),
          //     onTap: () => Navigator.pushNamed(context, '/oe-model/detail',
          //         arguments: {'id': '5408103711000'}),
          //   ),
          //   Text('YG200-1012243B'),
          //   Text('1'),
          // ]),
        ],
      ),
    );
  }
}

// class ContainerPage extends StatelessWidget {
//   Widget _renderBlock(Widget child) {
//     return Padding(
//       padding: EdgeInsets.all(12),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           color: Colors.white,
//           child: child,
//         ),
//       ),
//     );
//   }

//   Widget _renderHeader(String title) {
//     return Container(
//       height: 48,
//       padding: EdgeInsets.only(left: 12),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MPScaffold(
//       name: 'Container',
//       backgroundColor: Color.fromARGB(255, 236, 236, 236),
//       body: ListView(
//         children: [
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with color and size.'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.pink,
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with Center Container'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.pink,
//                 child: Center(
//                   child: Container(
//                     width: 44,
//                     height: 44,
//                     color: Colors.yellow,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with alignment (topRight)'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.pink,
//                 alignment: Alignment.topRight,
//                 child: Container(
//                   width: 44,
//                   height: 44,
//                   color: Colors.yellow,
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with padding'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.pink,
//                 padding: EdgeInsets.all(12),
//                 child: Container(
//                   width: 44,
//                   height: 44,
//                   color: Colors.yellow,
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with decoration'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.pink,
//                   border: Border.all(width: 4, color: Colors.black),
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with foregroundDecoration'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.pink,
//                   border: Border.all(width: 4, color: Colors.black),
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//                 foregroundDecoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.transparent,
//                       Colors.black,
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//           _renderBlock(Column(
//             children: [
//               _renderHeader('Container with border and center text'),
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.pink,
//                   border: Border.all(width: 4, color: Colors.black),
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Hello',
//                     style: TextStyle(fontSize: 24),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           )),
//         ],
//       ),
//     );
//   }
// }
