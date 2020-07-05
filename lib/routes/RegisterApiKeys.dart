import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart" as url;
import "package:http/http.dart" as http;

import "package:Music/apiKeys.dart" show keys;

const napsterDescription =
    "This is used to get data, such as title, artist and the album picture,  about every Song and Album.";
const youtubeDescription =
    "This is used to get the youtube id of the song to download.";

class RegisterApiKeys extends StatefulWidget {
  @override
  _RegisterApiKeysState createState() => _RegisterApiKeysState();
}

class _RegisterApiKeysState extends State<RegisterApiKeys> {
  final _napsterController = TextEditingController();
  final _youtubeController = TextEditingController();

  bool _napsterErrored = false;
  bool _youtubeErrored = false;

  VerifyState _state = VerifyState.ToVerify;

  @override
  void dispose() {
    _napsterController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Material(
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 30, horizontal: width10 / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Register Api Keys",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(height: 50),
                  Text("Napster", style: Theme.of(context).textTheme.headline5),
                  SizedBox(height: 15),
                  Text(
                    napsterDescription,
                    style: TextStyle(fontSize: 17, color: Colors.grey[300]),
                  ),
                  FlatButton(
                    onPressed: () {
                      url.launch(
                        "https://developer.napster.com/api/v2.2#getting-started",
                        enableJavaScript: true,
                      );
                    },
                    child: Text(
                      "Learn More",
                      style: Theme.of(context).accentTextTheme.bodyText2,
                    ),
                  ),
                  TextField(
                    controller: _napsterController,
                    style: Theme.of(context).textTheme.bodyText1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "napster api key",
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
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
                  ),
                  SizedBox(height: 50),
                  Text("Youtube", style: Theme.of(context).textTheme.headline5),
                  SizedBox(height: 15),
                  Text(
                    youtubeDescription,
                    style: TextStyle(fontSize: 17, color: Colors.grey[300]),
                  ),
                  FlatButton(
                    onPressed: () {
                      url.launch(
                        "https://developers.google.com/youtube/v3/getting-started",
                        enableJavaScript: true,
                      );
                    },
                    child: Text(
                      "Learn More",
                      style: Theme.of(context).accentTextTheme.bodyText2,
                    ),
                  ),
                  TextField(
                    controller: _youtubeController,
                    style: Theme.of(context).textTheme.bodyText1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "youtube api key",
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      errorText: _youtubeErrored ? "Invalid API Key" : null,
                    ),
                    onChanged: (_) {
                      if (_state == VerifyState.Verified) {
                        setState(() {
                          _state = VerifyState.ToVerify;
                        });
                      }
                      if (_youtubeErrored) {
                        setState(() {
                          _youtubeErrored = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 50),
                  _buildButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    Widget child;

    switch (_state) {
      case VerifyState.ToVerify:
        child = Text("Verify");
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
      buttonMinWidth: 90,
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
              keys.setKeys(
                napster: _napsterController.text.trim(),
                youtube: _youtubeController.text.trim(),
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

    res = await http.get(
        "https://www.googleapis.com/youtube/v3/search?key=${_youtubeController.text.trim()}");
    if (res.statusCode != 200) {
      setState(() {
        _youtubeErrored = true;
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
