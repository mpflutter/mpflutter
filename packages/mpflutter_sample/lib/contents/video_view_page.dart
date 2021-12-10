import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class VideoViewPage extends StatelessWidget {
  final _videoController = MPVideoController();

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

  Widget _renderVideoStatusButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 44,
          height: 30,
          alignment: Alignment.center,
          child: Text(
            '状态:',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.play();
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '播放',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.pause();
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '暂停',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.fullscreen();
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '全屏',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderVideoVolumnButtons() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 44,
          height: 30,
          alignment: Alignment.center,
          child: Text(
            '音量:',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.volumeUp();
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '增大',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.volumeDown();
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '减小',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.setMuted(true);
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '静音',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _videoController.setMuted(false);
          },
          child: Container(
            width: 66,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '非静音',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderOtherButton() {
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: [
        Container(
          width: 44,
          height: 30,
          alignment: Alignment.center,
          child: Text(
            '其他:',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () {
            _videoController.setPlaybackRate(0.5);
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              'x0.5',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _videoController.setPlaybackRate(2);
          },
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              'x2',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _videoController.seekTo(20);
          },
          child: Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '跳转到20s',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final s = await _videoController.getCurrentTime();
            print(s);
          },
          child: Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '获取进度',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'VideoView',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('VideoView with controls.'),
              Container(
                width: 200,
                height: 200,
                color: Colors.black,
                child: MPVideoView(
                  url:
                      'https://avideo.yidoutang.com/prod/upload/202105/12anniversary_v3.mp4.w848.mp4',
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('VideoView without controls.'),
              _renderVideoStatusButton(),
              SizedBox(height: 8),
              _renderVideoVolumnButtons(),
              SizedBox(height: 8),
              _renderOtherButton(),
              SizedBox(height: 8),
              Container(
                width: 200,
                height: 200,
                color: Colors.black,
                child: MPVideoView(
                  url:
                      'https://avideo.yidoutang.com/prod/upload/202105/12anniversary_v3.mp4.w848.mp4',
                  controls: false,
                  controller: _videoController,
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
