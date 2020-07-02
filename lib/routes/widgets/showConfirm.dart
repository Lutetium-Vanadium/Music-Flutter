import "dart:ui";

import "package:flutter/material.dart";

Future<bool> showConfirm(
    BuildContext context, String title, String text) async {
  var result = await Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 250),
      fullscreenDialog: true,
      opaque: false,
      transitionsBuilder: (context, animation, _, page) {
        return ScaleTransition(
          scale: CurvedAnimation(curve: Curves.easeInOut, parent: animation),
          child: FadeTransition(
            opacity: animation,
            child: page,
          ),
        );
      },
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ConfirmBox(
                    title: title,
                    text: text,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  return result ?? false;
}

class ConfirmBox extends StatelessWidget {
  final String title;
  final String text;

  const ConfirmBox({
    Key key,
    this.title,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                visualDensity: VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.compact.vertical,
                ),
                child: Text("No"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                visualDensity: VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.compact.vertical,
                ),
                child: Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
