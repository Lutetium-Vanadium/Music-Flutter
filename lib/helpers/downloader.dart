import "dart:async";
import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:youtube_explode_dart/youtube_explode_dart.dart";

import "package:Music/models/models.dart";

Stream<Pair<int, int>> downloadSong(String id, String filename,
    {List<String> backup = const []}) async* {
  try {
    var yt = YoutubeExplode();

    StreamManifest manifest;

    var downloadId = id;
    var i = 0;

    while (manifest == null) {
      try {
        manifest = await yt.videos.streamsClient.getManifest(downloadId);
      } catch (e) {
        print(downloadId + " errored");
        if (i == backup.length) throw "Couldn't get manifest";
        downloadId = backup[i++];
      }
    }

    // -1 to show that its not a percent, but the index of song chosen
    yield Pair(-1, i - 1);

    print("Starting: $downloadId");
    Uri uri;

    if (manifest.audioOnly.length > 0) {
      uri = manifest.audioOnly.firstWhere(
          (element) => element.audioCodec == "mp4a.40.2", orElse: () {
        return manifest.audioOnly.first;
      }).url;
    } else if (manifest.audioOnly.length > 0) {
      uri = manifest.audio.firstWhere(
          (element) => element.audioCodec == "mp4a.40.2", orElse: () {
        return manifest.audioOnly.first;
      }).url;
    } else {
      throw "Couldn't find audio.";
    }

    if (uri == null) {
      return;
    }

    print("Got manifest for $filename");
    var root = await getApplicationDocumentsDirectory();

    var file = File("${root.path}/songs/$filename");

    if (await file.exists())
      return;
    else
      file = await file.create(recursive: true);

    var client = HttpClient();
    var request = await client.getUrl(uri);
    var response = await request.close();

    var progress = 0;
    var length = response.contentLength;
    var _percent = 0;

    var writer = file.openWrite();

    await for (var data in response) {
      writer.add(data);
      progress += data.length;
      var percent = (100 * progress / length).round();
      if (percent != _percent) {
        _percent = percent;
        yield Pair(progress, length);
      }
    }

    await writer.flush();
    await writer.close();

    // Close the YoutubeExplode's http client.
    yt.close();

    print("Finished $filename");
  } catch (err) {
    print(err);
    throw "filename: $filename, id: $id";
  }
}

Future<void> downloadImage(String id) async {
  var root = await getApplicationDocumentsDirectory();

  var file = File("${root.path}/album_images/$id.jpg");

  if (await file.exists())
    return;
  else
    file = await file.create(recursive: true);
  var uri = Uri.parse(
      "https://api.napster.com/imageserver/v2/albums/$id/images/500x500.jpg");

  var client = HttpClient();
  var request = await client.getUrl(uri);
  var response = await request.close();
  var writer = file.openWrite();

  response.listen((data) {
    writer.add(data);
  }, onDone: () {
    writer.close();
    print("Done $id");
  });
}
