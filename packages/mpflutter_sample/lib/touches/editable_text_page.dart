import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class EditableTextPage extends StatefulWidget {
  @override
  _EditableTextPageState createState() => _EditableTextPageState();
}

class _EditableTextPageState extends State<EditableTextPage> {
  int sCount = 0;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController comment2Controller =
      TextEditingController(text: "I'm the readonly text.");

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
      name: 'EditableText',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('SingleLine EditableText.'),
              _SingleLineEditableText(editingController: usernameController),
              SizedBox(height: 16),
              _SingleLineEditableText(
                isPassword: true,
                editingController: passwordController,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    sCount++;
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 16),
              _SubmitButton(
                value0Controller: usernameController,
                value1Controller: passwordController,
              ),
              SizedBox(height: 16),
            ]..addAll((() {
                final v = <Widget>[];
                for (var i = 0; i < sCount; i++) {
                  v.add(Container(
                    height: 10,
                    color: Colors.green,
                  ));
                }
                return v;
              })()),
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('MultiLine EditableText.'),
              _MultilineEditableText(
                editingController: commentController,
              ),
              SizedBox(height: 16),
              _SubmitButton(
                value0Controller: commentController,
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('MultiLine EditableText - readonly.'),
              _MultilineEditableText(
                editingController: comment2Controller,
                readonly: true,
              ),
              SizedBox(height: 16),
              _SubmitButton(
                value0Controller: comment2Controller,
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
      bottomBar: _BottomInput(),
      bottomBarWithSafeArea: true,
      bottomBarSafeAreaColor: Colors.white,
    );
  }
}

class _BottomInput extends StatefulWidget {
  @override
  State<_BottomInput> createState() => _BottomInputState();
}

class _BottomInputState extends State<_BottomInput> {
  final editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.yellow,
      child: Center(
        child: Container(
          height: 32,
          width: MediaQuery.of(context).size.width - 16,
          color: Colors.grey.shade100,
          child: MPEditableText(
            controller: editingController,
            focusNode: FocusNode(),
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final TextEditingController? value0Controller;
  final TextEditingController? value1Controller;

  _SubmitButton({
    Key? key,
    this.value0Controller,
    this.value1Controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MPWebDialogs.alert(
          message:
              'Value0 = ${value0Controller?.text}, Value1 = ${value1Controller?.text}',
        );
      },
      child: Container(
        width: 200,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            'Submit',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _SingleLineEditableText extends StatefulWidget {
  final bool isPassword;
  final TextEditingController editingController;

  _SingleLineEditableText({
    Key? key,
    this.isPassword = false,
    required this.editingController,
  }) : super(key: key);

  @override
  _SingleLineEditableTextState createState() => _SingleLineEditableTextState();
}

class _SingleLineEditableTextState extends State<_SingleLineEditableText> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: focusNode.hasFocus ? Colors.black26 : Colors.black12,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 11.0, right: 11.0),
        child: MPEditableText(
          controller: widget.editingController,
          focusNode: focusNode,
          placeholder: widget.isPassword ? 'Password' : 'Username',
          obscureText: widget.isPassword,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

class _MultilineEditableText extends StatefulWidget {
  final TextEditingController editingController;
  final bool readonly;

  _MultilineEditableText({
    required this.editingController,
    this.readonly = false,
  });

  @override
  __MultilineEditableTextState createState() => __MultilineEditableTextState();
}

class __MultilineEditableTextState extends State<_MultilineEditableText> {
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: MPEditableText(
          controller: widget.editingController,
          focusNode: focusNode,
          maxLines: 99999,
          style: TextStyle(fontSize: 16, color: Colors.black),
          readOnly: widget.readonly,
          // placeholder: 'Here enter multiple lines text...',
          // placeholderStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
    );
  }
}
