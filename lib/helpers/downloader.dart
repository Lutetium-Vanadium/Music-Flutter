import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;

import 'package:music/models/models.dart';
import 'package:music/constants.dart';

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
        print(e);
        print(downloadId + ' errored');
        if (i == backup.length) throw "Couldn't get manifest";
        downloadId = backup[i++];
      }
    }

    print('Got manifest for $filename');

    // -1 to show that its not a percent, but the index of song chosen
    yield Pair(-1, i - 1);

    Uri uri;

    if (manifest.audioOnly.length > 0) {
      uri = manifest.audioOnly.firstWhere(
          (element) => element.audioCodec == 'mp4a.40.2', orElse: () {
        return manifest.audioOnly.first;
      }).url;
    } else if (manifest.audioOnly.length > 0) {
      uri = manifest.audio.firstWhere(
          (element) => element.audioCodec == 'mp4a.40.2', orElse: () {
        return manifest.audioOnly.first;
      }).url;
    } else {
      throw "Couldn't find audio.";
    }

    if (uri == null) {
      return;
    }

    var root = await getApplicationDocumentsDirectory();

    var file = File('${root.path}/songs/$filename');

    print('Starting: $downloadId');

    if (!(await file.exists())) file = await file.create(recursive: true);

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

    print('Finished $filename');
  } catch (err) {
    print(err);
    throw 'filename: $filename, id: $id';
  }
}

Future<void> downloadNapsterImage(String id) async {
  var root = await getApplicationDocumentsDirectory();
  var file = File('${root.path}/album_images/$id.jpg');

  if (await file.exists()) return;

  file = await file.create(recursive: true);

  var uri = Uri.parse(
      'https://api.napster.com/imageserver/v2/albums/$id/images/500x500.jpg');

  var client = HttpClient();
  var request = await client.getUrl(uri);
  var response = await request.close();
  var writer = file.openWrite();

  await for (var data in response) {
    writer.add(data);
  }

  await writer.close();
  print('Done $id');
}

Future<void> downloadYoutubeImage(YoutubeSongData vid) async {
  var id = vid.id;

  var root = await getApplicationDocumentsDirectory();

  var ytbFile = File('${root.path}/album_images/ytb.jpg');

  if (!(await ytbFile.exists())) {
    ByteData data = await rootBundle.load('$imgs/youtube.png');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await ytbFile.writeAsBytes(bytes);
  }

  var file = File('${root.path}/album_images/$id.jpg');

  if (await file.exists()) return;

  file = await file.create(recursive: true);

  var uri = Uri.parse(vid.thumbnail);

  var res = await http.get(uri);
  var srcImg = image.decodeImage(res.bodyBytes);
  var blurredImage = image.Image.from(srcImg);
  image.gaussianBlur(blurredImage, 15);

  var srcW = srcImg.width;
  var srcH = srcImg.height;

  var img = image.Image(srcW, srcW);
  image.drawImage(img, blurredImage,
      dstX: 0,
      dstY: 0,
      dstW: srcW,
      dstH: srcW,
      srcX: (srcW - srcH) ~/ 2,
      srcY: 0,
      srcW: srcH,
      srcH: srcH);

  image.drawImage(img, srcImg,
      dstX: 0,
      dstY: (srcW - srcH) ~/ 2,
      dstW: srcW,
      dstH: srcH,
      srcX: 0,
      srcY: 0,
      srcW: srcW,
      srcH: srcH);

  await file.writeAsBytes(image.encodeJpg(img));
  print('Done $id');
}
