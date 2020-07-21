import "package:path_provider/path_provider.dart";

import "package:Music/sync.dart";
import "package:Music/global_providers/database.dart";
import "package:Music/models/models.dart";

import "./napster.dart" show getAlbumInfo;

Future<void> updateAlbum(
  String albumId,
  String artist,
  DatabaseFunctions db,
  FirestoreSync syncDb, {
  int numSongs = 1,
}) async {
  var root = await getApplicationDocumentsDirectory();
  var imagePath = "${root.path}/album_images/$albumId.jpg";

  var count = await db.getNumSongs(albumId);

  if (count > 0) {
    await db.update(
      Tables.Albums,
      {"numSongs": count + 1},
      where: "id LIKE ?",
      whereArgs: [albumId],
    );
    syncDb.update(SyncTables.Albums, albumId, {"numSongs": count + 1});

    return;
  }

  var albumInfo = await getAlbumInfo(albumId);

  if (albumInfo == null) {
    print("Failed album $albumId");
  }

  print("Adding album ${albumInfo.name}.");

  var album = AlbumData(
    id: albumInfo.id,
    name: albumInfo.name,
    imagePath: imagePath,
    numSongs: numSongs,
    artist: artist,
  );

  await Future.wait([
    db.insertAlbum(album),
    syncDb.insertAlbum(album),
  ]);
}
