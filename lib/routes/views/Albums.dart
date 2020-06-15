import "package:flutter/material.dart";

class Albums extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Albums",
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
