import "package:flutter/material.dart";

class Artists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Artists",
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
