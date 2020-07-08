import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart" as url;
import "package:http/http.dart" as http;

import "package:Music/keys.dart";

const napsterDescription =
    "This is used to get data, such as title, artist and the album picture, about every Song and Album.";
const firestoreDescription =
    "This can be used to sync all locally stored metadata about songs up to firebase.";
const firestoreDisclaimer =
    "Make sure the above keys are properly inputed as there is no way to verify. If they are, the app will automatically sync to firestore.";

class RegisterApiKeys extends StatefulWidget {
  @override
  _RegisterApiKeysState createState() => _RegisterApiKeysState();
}

class _RegisterApiKeysState extends State<RegisterApiKeys> {
  final _napsterController = TextEditingController();

  final _appIdController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _napsterErrored = false;

  VerifyState _state = VerifyState.ToVerify;

  @override
  void dispose() {
    _napsterController.dispose();
    _appIdController.dispose();
    _projectIdController.dispose();
    _apiKeyController.dispose();
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
          "Register Api Keys",
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 10),
        Section(
          title: "Napster",
          description: napsterDescription,
          link: "https://developer.napster.com/api/v2.2#getting-started",
          children: [
            TextField(
              controller: _napsterController,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "napster api key",
                errorText: _napsterErrored ? "Invalid API Key" : null,
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
        Section(
          title: "Firestore (optional)",
          description: firestoreDescription,
          link: "https://firebase.google.com/docs/firestore/",
          children: <Widget>[
            TextField(
              controller: _projectIdController,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "firestore project id",
              ),
            ),
            TextField(
              controller: _appIdController,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "firestore app id",
              ),
            ),
            TextField(
              controller: _apiKeyController,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "firestore api key",
              ),
            ),
            SizedBox(height: 15),
            Text(
              firestoreDisclaimer,
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
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
        child = Text("Verify Napster");
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
            Text("Done"),
            SizedBox(width: 5),
          ],
        );
        break;
    }

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonMinWidth: 110,
      children: [
        FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          color: Theme.of(context).buttonColor,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onPressed: () {
            if (_state == VerifyState.ToVerify) {
              _verifyApiKeys();
            } else if (_state == VerifyState.Verified) {
              apiKeys.setKeys(napster: _napsterController.text.trim());
              syncKeys.setKeys(
                apiKey: _apiKeyController.text.trim(),
                appId: _appIdController.text.trim(),
                projectId: _projectIdController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: child,
        ),
      ],
    );
  }

  Future<void> _verifyApiKeys() async {
    setState(() {
      _state = VerifyState.Verifying;
    });
    var success = true;

    var res = await http.get(
        "https://api.napster.com/v2/?apikey=${_napsterController.text.trim()}");
    if (res.statusCode != 200) {
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
        FlatButton(
          onPressed: () {
            url.launch(
              link,
              enableJavaScript: true,
            );
          },
          child: Text(
            "Learn More",
            style: Theme.of(context).accentTextTheme.bodyText2,
          ),
        ),
        ...children,
        SizedBox(height: 20),
      ],
    );
  }
}
