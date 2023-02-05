import 'package:flutter/widgets.dart';

import 'package:mpcore/mpkit/mpkit.dart';
import 'package:mpflutter_template/contents/charts/barchart_sample_1.dart';
import 'package:mpflutter_template/contents/charts/linechart_sample_1.dart';
import 'package:mpflutter_template/contents/charts/piechart_sample_1.dart';
import 'package:mpflutter_template/contents/charts/piechart_sample_2.dart';
import 'package:mpflutter_template/contents/charts/radar_chart_sample1.dart';
import 'package:mpflutter_template/contents/charts/scatter_chart_sample1.dart';
import 'package:mpflutter_template/contents/charts/scatter_chart_sample2.dart';

import 'charts/barchart_sample_7.dart';
import 'charts/linechart_sample_2.dart';

class ChartPage extends StatelessWidget {
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
      name: 'Chart',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('LineChart Sample 1.'),
              LineChartSample1(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('LineChart Sample 2.'),
              LineChartSample2(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('BarChart Sample 1.'),
              Container(
                color: Color.fromARGB(255, 79, 247, 183),
                child: BarChartSample1(),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('BarChart Sample 7.'),
              Container(
                color: Color.fromARGB(255, 79, 247, 183),
                child: BarChartSample7(),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('PieChart Sample 1.'),
              Container(
                color: Color.fromARGB(255, 23, 28, 36),
                child: PieChartSample1(),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('PieChart Sample 2.'),
              Container(
                color: Color.fromARGB(255, 23, 28, 36),
                child: PieChartSample2(),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('ScatterChart Sample 1.'),
              Container(
                color: Color.fromARGB(255, 23, 28, 36),
                child: ScatterChartSample1(),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('ScatterChart Sample 2.'),
              Container(
                color: Color.fromARGB(255, 23, 28, 36),
                child: ScatterChartSample2(),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('RadarChart Sample 1.'),
              Container(
                color: Color.fromARGB(255, 23, 28, 36),
                child: RadarChartSample1(),
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}
