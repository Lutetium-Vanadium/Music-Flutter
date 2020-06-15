import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String placeholder;
  final void Function(String) onChange;
  final String initialValue;
  final bool autofocus;

  Input({
    Key key,
    this.placeholder,
    @required this.onChange,
    this.initialValue,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        autofocus: widget.autofocus,
        style: Theme.of(context).textTheme.bodyText2,
        cursorColor: Theme.of(context).cursorColor,
        maxLines: 1,
        controller: _textController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.placeholder,
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
        ),
        onChanged: (String value) {
          widget.onChange(value);
        },
        onSubmitted: (String value) {
          widget.onChange(value);
        },
      ),
    );
  }
}
