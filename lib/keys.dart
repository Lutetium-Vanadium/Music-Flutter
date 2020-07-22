import 'dart:async' show Completer;
import 'dart:convert' show json;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ApiKeys {
  String napster;

  var _ready = Completer<void>();
  var _needsApiKeys = Completer<bool>();

  Future<void> get isReady => _ready.future;

  Future<bool> get needsApiKeys => _needsApiKeys.future;

  ApiKeys() {
    _load();
  }

  Future<void> setKeys({String napster}) async {
    this.napster = napster;

    var root = await getApplicationDocumentsDirectory();
    var file = File('${root.path}/apiKeys.json');

    await file.writeAsString(json.encode({
      'NAPSTER_API_KEY': napster,
    }));

    _ready.complete();
  }

  Future<void> _load() async {
    var root = await getApplicationDocumentsDirectory();
    var file = File('${root.path}/apiKeys.json');
    if (await file.exists()) {
      var jsonMap = json.decode(await file.readAsString());

      napster = jsonMap['NAPSTER_API_KEY'];

      if (napster != null) {
        _ready.complete();
        return _needsApiKeys.complete(false);
      }
    }
    _needsApiKeys.complete(true);
  }
}

class SyncKeys {
  String appId;
  String projectId;
  String apiKey;

  var _ready = Completer<void>();

  Future<void> get isReady => _ready.future;
  bool get hasKeys => appId != null && projectId != null && apiKey != null;

  SyncKeys() {
    _load();
  }

  Future<void> setKeys({String appId, String projectId, String apiKey}) async {
    this.appId = appId;
    this.projectId = projectId;
    this.apiKey = apiKey;

    var root = await getApplicationDocumentsDirectory();
    var file = File('${root.path}/syncKeys.json');

    _ready.complete();

    await file.writeAsString(json.encode({
      'APP_ID': appId,
      'PROJECT_ID': projectId,
      'API_KEY': apiKey,
    }));
  }

  Future<void> _load() async {
    var root = await getApplicationDocumentsDirectory();
    var file = File('${root.path}/syncKeys.json');
    if (await file.exists()) {
      var jsonMap = json.decode(await file.readAsString());

      appId = jsonMap['APP_ID'];
      projectId = jsonMap['PROJECT_ID'];
      apiKey = jsonMap['API_KEY'];

      if (hasKeys) {
        _ready.complete();
      }
    }
  }
}

var apiKeys = ApiKeys();
var syncKeys = SyncKeys();
