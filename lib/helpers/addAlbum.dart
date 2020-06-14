import "./napster.dart" show getAlbumInfo;
import "./downloader.dart" show downloadImage;
import "../dataClasses.dart";

/// addAlbum()
///
/// @param {string} albumId The id of the album
/// @param {string} artist The name of the artist who made it
/// @param numSongs the number of songs in the album, defaults to 1
///
/// Adds an album and downloads the image for the album if they dont exist
Future<void> addAlbum(String albumId, String artist, {int numSongs = 1}) async {
  var imagePath = "file://album_images/$albumId.jpg"; // todo proper file

  downloadImage(albumId);

  // if (await db.exists(albumId)) {
  //   db.incrementNumSongs(albumId);
  //   return;
  // }

  var albumInfo = await getAlbumInfo(albumId);

  if (albumId != albumInfo.id) {
    print("Failed album $albumId");
  }

  print("Adding album ${albumInfo.name}.");

  var album = Album(
    id: albumInfo.id,
    name: albumInfo.name,
    imagePath: imagePath,
    numSongs: numSongs,
    artist: artist,
  );

  // db.addAlbum(album);
}
