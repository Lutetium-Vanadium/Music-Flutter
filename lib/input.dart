import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String placeholder;
  final void Function(String) onChange;

  Input({Key key, this.placeholder, @required this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // child: Container(
      // color: Colors.red,
      child: TextField(
        style: Theme.of(context).textTheme.bodyText1,
        cursorColor: Theme.of(context).cursorColor,
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: placeholder,
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
        ),
        onChanged: (String value) {
          onChange(value);
        },
        onSubmitted: (String value) {
          onChange(value);
        },
      ),
      // ),
    );
  }
}
