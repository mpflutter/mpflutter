import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class FormsPage extends StatelessWidget {
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
      name: 'Forms',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('SinglePicker'),
              SinglePickerSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('MultiPicker'),
              MultiPickerSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Date Picker'),
              DatePickerSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Regular slider'),
              _SliderSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Regular swtich'),
              _SwitchSample(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class _SliderSample extends StatefulWidget {
  @override
  State<_SliderSample> createState() {
    return _SliderSampleState();
  }
}

class _SliderSampleState extends State<_SliderSample> {
  final sliderController = MPSliderController(currentValue: 120.0);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.amber,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MPSlider(
            width: 240,
            min: 120,
            max: 360,
            step: 1,
            controller: sliderController,
            onValueChanged: (value) {
              setState(() {});
            },
          ),
          GestureDetector(
            onTap: () async {
              final nValue = await MPWebDialogs.prompt(
                message: 'Input value',
                context: context,
              );
              if (nValue != null) {
                sliderController.setValue(double.tryParse(nValue) ?? 120.0);
                setState(() {});
              }
            },
            child: Container(
              width: 200,
              child: Text(
                sliderController.currentValue.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}

class _SwitchSample extends StatefulWidget {
  const _SwitchSample({
    Key? key,
  }) : super(key: key);

  @override
  State<_SwitchSample> createState() => _SwitchSampleState();
}

class _SwitchSampleState extends State<_SwitchSample> {
  final controller = MPSwitchController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: controller.currentValue ? Colors.yellow : Colors.blue,
          alignment: Alignment.center,
          width: 300,
          height: 44,
          child: MPSwitch(
            onValueChanged: (v) {
              setState(() {});
            },
            controller: controller,
          ),
        ),
        GestureDetector(
          onTap: () {
            final nextValue = !controller.currentValue;
            controller.setValue(nextValue);
            setState(() {});
          },
          child: Container(
            width: 100,
            height: 32,
            color: Colors.pink,
          ),
        ),
      ],
    );
  }
}

class SinglePickerSample extends StatefulWidget {
  @override
  _SinglePickerSampleState createState() => _SinglePickerSampleState();
}

class _SinglePickerSampleState extends State<SinglePickerSample> {
  final items = [
    MPPickerItem(label: '飞机票'),
    MPPickerItem(label: '火车票'),
    MPPickerItem(label: '的士票'),
    MPPickerItem(label: '公交票 (disabled)', disabled: true),
    MPPickerItem(label: '其他'),
  ];
  var text = '单列选择器';
  @override
  Widget build(BuildContext context) {
    return MPPicker(
      items: items,
      column: 1,
      defaultValue: [3],
      onResult: (result) {
        setState(() {
          text = result.map((e) => e.label).join(',');
        });
      },
      child: Container(
        height: 100,
        color: Colors.pink,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class MultiPickerSample extends StatefulWidget {
  @override
  _MultiPickerSampleState createState() => _MultiPickerSampleState();
}

class _MultiPickerSampleState extends State<MultiPickerSample> {
  final items = [
    MPPickerItem(
      label: '飞机票',
      subItems: [
        MPPickerItem(
          label: '经济舱',
          subItems: [
            MPPickerItem(label: '包餐'),
            MPPickerItem(label: '不包餐'),
          ],
        ),
        MPPickerItem(
          label: '商务舱',
          subItems: [
            MPPickerItem(label: '超级VIP'),
            MPPickerItem(label: '普通'),
          ],
        ),
      ],
    ),
    MPPickerItem(
      label: '火车票',
      subItems: [
        MPPickerItem(
          label: '卧铺',
          disabled: true,
          subItems: [
            MPPickerItem(label: '一等'),
            MPPickerItem(label: '二等'),
          ],
        ),
        MPPickerItem(
          label: '坐票',
          subItems: [
            MPPickerItem(label: '软座'),
            MPPickerItem(label: '硬座'),
          ],
        ),
        MPPickerItem(
          label: '站票',
          subItems: [
            MPPickerItem(label: '一等'),
            MPPickerItem(label: '二等'),
          ],
        ),
      ],
    ),
    MPPickerItem(
      label: '的士票',
      subItems: [
        MPPickerItem(label: '快班'),
        MPPickerItem(label: '普通'),
      ],
    ),
    MPPickerItem(
      label: '公交票 (disabled)',
      disabled: true,
    ),
  ];
  var text = '多列选择器';
  @override
  Widget build(BuildContext context) {
    return MPPicker(
      items: items,
      column: 3,
      defaultValue: [1, 1, 1],
      onResult: (result) {
        setState(() {
          text = result.map((e) => e.label).join(',');
        });
      },
      child: Container(
        height: 100,
        color: Colors.pink,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class DatePickerSample extends StatefulWidget {
  @override
  _DatePickerSampleState createState() => _DatePickerSampleState();
}

class _DatePickerSampleState extends State<DatePickerSample> {
  var text = '时间选择器';
  @override
  Widget build(BuildContext context) {
    return MPDatePicker(
      start: DateTime(2021, 10, 01),
      end: DateTime(2021, 12, 31),
      defaultValue: DateTime(2021, 10, 21),
      onResult: (result) {
        setState(() {
          text = result.toIso8601String();
        });
      },
      child: Container(
        height: 100,
        color: Colors.pink,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
