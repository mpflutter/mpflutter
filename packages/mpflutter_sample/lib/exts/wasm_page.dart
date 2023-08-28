import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mp_wasm/mp_wasm.dart';

class WasmPage extends StatefulWidget {
  const WasmPage({Key? key}) : super(key: key);

  @override
  State<WasmPage> createState() => _WasmPageState();
}

class _WasmPageState extends State<WasmPage> {
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
      name: 'Wasm',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Load test.wasm and run, log result.'),
              GestureDetector(
                child: Container(
                  width: 300,
                  height: 100,
                  color: Colors.pink,
                ),
                onTap: () async {
                  final wasmInstance =
                      MPWasmInstance(filePath: "test.wasm", envFunctions: {
                    "displaylog": (args) {
                      print("displaylog = " + (args[0] as int).toString());
                    },
                  });
                  await wasmInstance.load();
                  final result =
                      await wasmInstance.callExport("max", [300, 120]);
                  print(result);
                  wasmInstance.dispose();
                },
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}
