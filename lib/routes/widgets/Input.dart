import "package:flutter/material.dart";

class Input extends StatelessWidget {
  final String placeholder;
  final void Function(String) onChange;
  final TextEditingController controller;
  final bool autofocus;

  Input({
    Key key,
    this.placeholder,
    @required this.onChange,
    this.controller,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        autofocus: autofocus,
        style: Theme.of(context).textTheme.bodyText2,
        cursorColor: Theme.of(context).cursorColor,
        maxLines: 1,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          isDense: true,
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
    );
  }
}
