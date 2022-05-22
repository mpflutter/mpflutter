import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;

class HTTPNetworkPage extends StatelessWidget {
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
      name: 'HTTPNetwork',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Fetch PonyCui from GitHub API using http.'),
              _FetchUsingLibHTTP(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Fetch PonyCui from GitHub API using dio.'),
              _FetchUsingLibDio(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Post something to httpbin.'),
              _PostUsingLibDio(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class _FetchUsingLibDio extends StatefulWidget {
  const _FetchUsingLibDio({
    Key? key,
  }) : super(key: key);

  @override
  __FetchUsingLibDioState createState() => __FetchUsingLibDioState();
}

class __FetchUsingLibDioState extends State<_FetchUsingLibDio> {
  bool fetching = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          fetching = true;
        });
        try {
          final response = await dio.Dio()
              .getUri(Uri.parse('https://pub.mpflutter.com/test/ponycui'))
              .timeout(Duration(seconds: 15));
          print(response.data);
          MPWebDialogs.alert(
            message: 'PonyCui\'s location is = ${response.data['location']}',
          );
        } catch (e) {
        } finally {
          setState(() {
            fetching = false;
          });
        }
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.pink,
        child: Center(
          child: Text(
            fetching ? 'Fetching' : 'Tap here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _FetchUsingLibHTTP extends StatefulWidget {
  const _FetchUsingLibHTTP({
    Key? key,
  }) : super(key: key);

  @override
  __FetchUsingLibHTTPState createState() => __FetchUsingLibHTTPState();
}

class __FetchUsingLibHTTPState extends State<_FetchUsingLibHTTP> {
  bool fetching = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          fetching = true;
        });
        try {
          final response = await http
              .get(Uri.parse('https://pub.mpflutter.com/test/ponycui'));
          final result = json.decode(response.body);
          MPWebDialogs.alert(
            message: 'PonyCui\'s location is = ${result['location']}',
          );
        } catch (e) {
        } finally {
          setState(() {
            fetching = false;
          });
        }
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.pink,
        child: Center(
          child: Text(
            fetching ? 'Fetching' : 'Tap here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _PostUsingLibDio extends StatefulWidget {
  const _PostUsingLibDio({
    Key? key,
  }) : super(key: key);

  @override
  __PostUsingLibDioState createState() => __PostUsingLibDioState();
}

class __PostUsingLibDioState extends State<_PostUsingLibDio> {
  bool fetching = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          fetching = true;
        });
        try {
          final response = await http.post(
            Uri.parse('https://pub.mpflutter.com/test/post'),
            body: "Hello, World!",
          );
          MPWebDialogs.alert(
            message: 'PostBody is = ${response.body}',
          );
        } catch (e) {
        } finally {
          setState(() {
            fetching = false;
          });
        }
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.pink,
        child: Center(
          child: Text(
            fetching ? 'Fetching' : 'Tap here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
