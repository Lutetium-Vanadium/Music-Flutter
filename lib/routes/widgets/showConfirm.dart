import 'dart:ui';
import 'package:flutter/material.dart';

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
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.hardEdge,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: ConfirmBox(
                        title: title,
                        text: text,
                      ),
                    ),
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  visualDensity: VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.compact.vertical,
                  ),
                ),
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  visualDensity: VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.compact.vertical,
                  ),
                ),
                child: Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
