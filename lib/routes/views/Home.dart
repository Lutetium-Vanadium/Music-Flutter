import "package:flutter/material.dart";

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Home",
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
