import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mp_file/mp_file.dart';

class FilePage extends StatelessWidget {
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
      name: 'File',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Read file from rootBundle'),
              GestureDetector(
                onTap: () async {
                  final content =
                      await rootBundle.loadString("assets/test_file.cert");

                  MPWebDialogs.alert(message: content);
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
              _renderHeader('Write text to file, and read text from file.'),
              GestureDetector(
                onTap: () async {
                  final baseDir =
                      await FileManager.getFileManager().appSandboxDirectory();
                  final fooFile = File('${baseDir.path}/foo.txt');
                  await fooFile.writeAsString('Hello, World!');
                  final content = await fooFile.readAsString();
                  MPWebDialogs.alert(message: content);
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
              _renderHeader('Check file exists.'),
              GestureDetector(
                onTap: () async {
                  final baseDir =
                      await FileManager.getFileManager().appSandboxDirectory();
                  final fooFile = File('${baseDir.path}/foo.txt');
                  MPWebDialogs.alert(
                      message: 'exists = ${await fooFile.exists()}');
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
              _renderHeader('List dir.'),
              GestureDetector(
                onTap: () async {
                  final baseDir =
                      await FileManager.getFileManager().appSandboxDirectory();
                  final result = await baseDir.listDir();
                  MPWebDialogs.alert(message: 'files = ${result.join(',')}');
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
              _renderHeader('Pick media from device'),
              ChooseMediaWidget(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class ChooseMediaWidget extends StatefulWidget {
  const ChooseMediaWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ChooseMediaWidget> createState() => _ChooseMediaWidgetState();
}

class _ChooseMediaWidgetState extends State<ChooseMediaWidget> {
  Uint8List? imageData;

  @override
  Widget build(BuildContext context) {
    if (MPEnv.envHost() == MPEnvHostType.browser) {
      return Container(
        width: 100,
        height: 100,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                width: 100,
                height: 100,
                color: imageData != null ? Colors.black : Colors.pink,
                child: imageData != null ? Image.memory(imageData!) : null,
              ),
            ),
            Positioned.fill(
              child: FilePickerView(
                fileKey: ValueKey("foo_file_picker"),
                // count: 2,
                mediaType: FilePickerMediaType.image,
                // sourceType: FilePickerSourceType.camera,
                // cameraType: FilePickerCameraType.front,
                onPickFile: (files) async {
                  if (files.isNotEmpty) {
                    final data = await FileManager.getFileManager()
                        .readFile(files.first);
                    setState(() {
                      imageData = data;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          final file = await FilePicker.chooseMedia(
              count: 2,
              compressed: true,
              sourceType: FilePickerSourceType.camera,
              mediaType: FilePickerMediaType.image);
          if (file.isNotEmpty) {
            final data =
                await FileManager.getFileManager().readFile(file.first);
            setState(() {
              imageData = data;
            });
          }
        },
        child: Container(
          width: 100,
          height: 100,
          color: imageData != null ? Colors.black : Colors.pink,
          child: imageData != null ? Image.memory(imageData!) : null,
        ),
      );
    }
  }
}
