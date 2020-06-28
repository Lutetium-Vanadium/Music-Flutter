import 'dart:async' show Completer;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class ApiKeys {
  String youtube;
  String napster;

  ApiKeys(String path) {
    _load(path);
  }

  var _ready = Completer<void>();
  Future<void> get isReady => _ready.future;

  Future<void> _load(String path) =>
      rootBundle.loadStructuredData<void>(path, (jsonStr) async {
        var jsonMap = json.decode(jsonStr);
        print(jsonMap);
        napster = jsonMap["NAPSTER_API_KEY"];
        youtube = jsonMap["YOUTUBE_API_KEY"];
        _ready.complete();
      });
}

var keys = ApiKeys("assets/keys/apiKeys.json");
