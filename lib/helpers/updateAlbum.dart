import 'package:path_provider/path_provider.dart';

import 'package:music/global_providers/database.dart';
import 'package:music/models/models.dart';

import './napster.dart' show getAlbumInfo;

Future<void> updateAlbum(
  String albumId,
  String artist,
  DatabaseFunctions db,
) async {
  var isYtAlbum = albumId == 'ytb';
  var root = await getApplicationDocumentsDirectory();
  var imagePath = '${root.path}/album_images/$albumId.jpg';

  var count = await db.getNumSongs(albumId);

  if (count > 0) {
    await db.update(
      Tables.Albums,
      {'numSongs': count + 1},
      where: 'id LIKE ?',
      whereArgs: [albumId],
    );

    return;
  }

  String name;

  if (isYtAlbum) {
    name = 'Youtube';
  } else {
    var albumInfo = await getAlbumInfo(albumId);

    if (albumInfo == null) {
      print('Failed album $albumId');
    }

    name = albumInfo.name;
  }

  print('Adding album $name.');

  var album = AlbumData(
    id: albumId,
    name: name,
    imagePath: imagePath,
    numSongs: 1,
    artist: artist,
  );

  await db.insertAlbum(album);
}
