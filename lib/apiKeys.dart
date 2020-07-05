import "dart:async" show Completer;
import "dart:convert" show json;
import "dart:io";
import "package:path_provider/path_provider.dart";

class ApiKeys {
  String youtube;
  String napster;

  var _ready = Completer<void>();
  var _needsApiKeys = Completer<bool>();

  Future<void> get isReady => _ready.future;

  Future<bool> get needsApiKeys => _needsApiKeys.future;

  ApiKeys() {
    _load();
  }

  Future<void> setKeys({String youtube, String napster}) async {
    this.youtube = youtube;
    this.napster = napster;

    var root = await getApplicationDocumentsDirectory();
    var file = File("${root.path}/apiKeys.json");

    await file.writeAsString(json.encode({
      "NAPSTER_API_KEY": napster,
      "YOUTUBE_API_KEY": youtube,
    }));

    _ready.complete();
  }

  Future<void> _load() async {
    var root = await getApplicationDocumentsDirectory();
    var file = File("${root.path}/apiKeys.json");
    if (await file.exists()) {
      var jsonMap = json.decode(await file.readAsString());

      napster = jsonMap["NAPSTER_API_KEY"];
      youtube = jsonMap["YOUTUBE_API_KEY"];

      if (napster != null && youtube != null) {
        _ready.complete();
        return _needsApiKeys.complete(false);
      }
    }
    _needsApiKeys.complete(true);
  }
}

var keys = ApiKeys();
