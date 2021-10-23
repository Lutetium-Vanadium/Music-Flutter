import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:http/http.dart' as http;

import 'package:music/keys.dart';

const napsterDescription =
    'This is used to get data, such as title, artist and the album picture, about every Song and Album.';

class RegisterApiKeys extends StatefulWidget {
  @override
  _RegisterApiKeysState createState() => _RegisterApiKeysState();
}

class _RegisterApiKeysState extends State<RegisterApiKeys> {
  final _napsterController = TextEditingController();

  bool _napsterErrored = false;

  VerifyState _state = VerifyState.ToVerify;

  @override
  void dispose() {
    _napsterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: WillPopScope(
        onWillPop: () async => false,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(child: _buildPage(width10, context)),
        ),
      ),
    );
  }

  ListView _buildPage(double width10, BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: width10 / 2),
      children: [
        Text(
          'Register Api Keys',
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 10),
        Section(
          title: 'Napster',
          description: napsterDescription,
          link:
              'https://github.com/Lutetium-Vanadium/Music-Flutter/blob/master/docs/apikeys.md#napster',
          children: [
            TextField(
              controller: _napsterController,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'napster api key',
                errorText: _napsterErrored ? 'Invalid API Key' : null,
              ),
              onChanged: (_) {
                if (_state == VerifyState.Verified) {
                  setState(() {
                    _state = VerifyState.ToVerify;
                  });
                }
                if (_napsterErrored) {
                  setState(() {
                    _napsterErrored = false;
                  });
                }
              },
              onEditingComplete: _verifyApiKeys,
            ),
          ],
        ),
        _buildButton(context),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    Widget child;

    switch (_state) {
      case VerifyState.ToVerify:
        child = Text('Verify Napster');
        break;
      case VerifyState.Verifying:
        child = SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 2,
          ),
        );
        break;
      case VerifyState.Verified:
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check),
            SizedBox(width: 5),
            Text('Done'),
            SizedBox(width: 5),
          ],
        );
        break;
    }

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonMinWidth: 110,
      children: [
        TextButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ))),
          onPressed: () {
            if (_state == VerifyState.ToVerify) {
              _verifyApiKeys();
            } else if (_state == VerifyState.Verified) {
              apiKeys.setKeys(napster: _napsterController.text.trim());
              Navigator.of(context).pop();
            }
          },
          child: child,
        ),
      ],
    );
  }

  Future<void> _verifyApiKeys() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _state = VerifyState.Verifying;
    });
    var success = true;

    var verifyUri = Uri.parse(
        'https://api.napster.com/v2/?apikey=${_napsterController.text.trim()}');

    if ((await http.get(verifyUri)).statusCode != 200) {
      if (!mounted) return;
      setState(() {
        _napsterErrored = true;
      });
      success = false;
    }

    if (!mounted) return;
    setState(() {
      _state = success ? VerifyState.Verified : VerifyState.ToVerify;
    });
  }
}

enum VerifyState {
  ToVerify,
  Verifying,
  Verified,
}

class Section extends StatelessWidget {
  final String title;
  final String description;
  final String link;
  final List<Widget> children;

  const Section({
    Key key,
    @required this.title,
    @required this.description,
    @required this.link,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 30),
        Text(title, style: Theme.of(context).textTheme.headline5),
        SizedBox(height: 15),
        Text(
          description,
          style: TextStyle(fontSize: 16, color: Colors.grey[300]),
        ),
        TextButton(
          onPressed: () {
            url.launch(
              link,
              enableJavaScript: true,
            );
          },
          child: Text(
            'Learn More',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Color.fromRGBO(71, 135, 231, 1)),
          ),
        ),
        ...children,
        SizedBox(height: 20),
      ],
    );
  }
}
