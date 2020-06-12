import "package:flutter/material.dart";

class Music extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Music",
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
